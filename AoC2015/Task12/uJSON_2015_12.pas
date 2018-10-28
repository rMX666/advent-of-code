unit uJSON_2015_12;

interface

uses
  System.Generics.Collections, System.SysUtils;

type
  TJSONItem = class;

  TJSONType = ( jsonNone, jsonNumber, jsonString, jsonObject, jsonArray );
  TJSONNumber = Integer;
  TJSONString = String;
  TJSONObject = TDictionary<String, TJSONItem>;
  TJSONArray = TList<TJSONItem>;

  TOnJSONTraverseEvent = procedure (const Item: TJSONItem; var AllowGoDeeper: Boolean) of object;

  TJSONItem = class
  private
    FObjectType: TJSONType;
    FValue: Pointer;
    FOnJSONTraverse: TOnJSONTraverseEvent;
    function GetAsNumber: TJSONNumber;
    function GetAsString: TJSONString;
    procedure WrongJsonType(const Got: TJSONType);
    function GetAsList: TJSONArray;
    function GetAsObject: TJSONObject;
  protected
    procedure DoOnJSONTraverse(const Item: TJSONItem; var AllowGoDeeper: Boolean);
  public
    constructor Create(const AObjectType: TJSONType; const AValue: Pointer); overload;
    procedure Traverse;
    function ToString: String;
    property ObjectType: TJSONType read FObjectType;
    property AsNumber: TJSONNumber read GetAsNumber;
    property AsString: TJSONString read GetAsString;
    property AsObject: TJSONObject read GetAsObject;
    property AsList: TJSONArray read GetAsList;
    property OnJSONTraverse: TOnJSONTraverseEvent read FOnJSONTraverse write FOnJSONTraverse;
  end;

  TJSONItemBuilder = class
  private
    FObjectType: TJSONType;
    FValue: Pointer;
    constructor Create;
  public
    class function GetBuilder: TJSONItemBuilder;
    procedure SetObjectType(const AObjectType: TJSONType);
    procedure SetValue(const AValue: Pointer);
    function Build: TJSONItem;
  end;

  TJSONParser = class
  private
    FStr: String;
  private
    function Parse(var Pos: Integer): TJSONItem; overload;
  public
    constructor Create(const S: String);
    function Parse: TJSONItem; overload;
    class function Parse(const S: String): TJSONItem; overload;
  end;

implementation

type
  EWrongJSONType = Exception;
  EBuilder_ObjectTypeUnset = Exception;
  EBuilder_ValueUnset = Exception;

const
  E_WRONG_JSON_TYPE = 'Wrong JSON data-type. Expected %d, got %d';

{ TJSONItem }

constructor TJSONItem.Create(const AObjectType: TJSONType; const AValue: Pointer);
begin
  FObjectType := AObjectType;
  FValue := AValue;
end;

procedure TJSONItem.DoOnJSONTraverse(const Item: TJSONItem; var AllowGoDeeper: Boolean);
begin
  if Assigned(FOnJSONTraverse) then
    FOnJSONTraverse(Item, AllowGoDeeper);
end;

function TJSONItem.GetAsList: TJSONArray;
begin
  if FObjectType = jsonArray then
    Result := FValue
  else
    WrongJsonType(jsonArray);
end;

function TJSONItem.GetAsNumber: TJSONNumber;
begin
  if FObjectType = jsonNumber then
    Result := TJSONNumber(FValue^)
  else
    WrongJsonType(jsonNumber);
end;

function TJSONItem.GetAsObject: TJSONObject;
begin
  if FObjectType = jsonObject then
    Result := FValue
  else
    WrongJsonType(jsonObject);
end;

function TJSONItem.GetAsString: TJSONString;
begin
  if FObjectType = jsonString then
    Result := TJSONString(FValue^)
  else
    WrongJsonType(jsonString);
end;

function TJSONItem.ToString: String;
begin
  case FObjectType of
    jsonNumber:
      Result := IntToStr(AsNumber);
    jsonString:
      Result := AsString;
    jsonObject:
      Result := '[ Object ]';
    jsonArray:
      Result := '[ Array(' + IntToStr(AsList.Count) + ') ]'
  end;
end;

procedure TJSONItem.Traverse;
var
  Item: TJSONItem;
  AllowGoDeeper: Boolean;
begin
  AllowGoDeeper := True;

  case FObjectType of
    jsonNumber, jsonString:
      DoOnJSONTraverse(Self, AllowGoDeeper);
    jsonObject:
      with AsObject do
        begin
          DoOnJSONTraverse(Self, AllowGoDeeper);

          if AllowGoDeeper then
            for Item in Values do
              begin
                Item.OnJSONTraverse := FOnJSONTraverse;
                Item.Traverse
              end;
        end;
    jsonArray:
      begin
        DoOnJSONTraverse(Self, AllowGoDeeper);

        if AllowGoDeeper then
          for Item in AsList do
            begin
              Item.OnJSONTraverse := FOnJSONTraverse;
              Item.Traverse;
            end;
      end;
  end;
end;

procedure TJSONItem.WrongJsonType(const Got: TJSONType);
begin
  raise EWrongJSONType.CreateFmt(E_WRONG_JSON_TYPE, [ Integer(FObjectType), Integer(Got) ]);
end;

{ TJSONItemBuilder }

function TJSONItemBuilder.Build: TJSONItem;
begin
  if FValue = nil then
    raise EBuilder_ValueUnset.Create('Value unset');
  if FObjectType = jsonNone then
    raise EBuilder_ObjectTypeUnset.Create('Object type unset');

  Result := TJSONItem.Create(FObjectType, FValue);
end;

constructor TJSONItemBuilder.Create;
begin
  FValue := nil;
  FObjectType := jsonNone;
end;

class function TJSONItemBuilder.GetBuilder: TJSONItemBuilder;
begin
  Result := TJSONItemBuilder.Create;
end;

procedure TJSONItemBuilder.SetObjectType(const AObjectType: TJSONType);
begin
  FObjectType := AObjectType;
end;

procedure TJSONItemBuilder.SetValue(const AValue: Pointer);
begin
  FValue := AValue;
end;

{ TJSONParser }

constructor TJSONParser.Create(const S: String);
begin
  FStr := S;
end;

function TJSONParser.Parse(var Pos: Integer): TJSONItem;

  procedure SkipUntil(const C: Char);
  begin
    while FStr[Pos] <> C do
      Inc(Pos);
  end;

  function ReadString: TJSONString;
  begin
    Result := '';

    Inc(Pos);
    while (Pos < FStr.Length) and (FStr[Pos] <> '"') do
      begin
        Result := Result + FStr[Pos];
        Inc(Pos);
      end;
    Inc(Pos);
  end;

  function ReadNumber: TJSONNumber;
  var
    S: String;
  begin
    S := '';
    while FStr[Pos] in [ '-', '0' .. '9' ] do
      begin
        S := S + FStr[Pos];
        Inc(Pos);
      end;

    Result := StrToInt(S);
  end;

  function ReadObject: TJSONObject;
  var
    Key: String;
  begin
    Result := TJSONObject.Create;

    while FStr[Pos] <> '}' do
      begin
        SkipUntil('"');
        Key := ReadString;
        Result.Add(Key, Parse(Pos));
      end;
    Inc(Pos);
  end;

  function ReadArray: TJSONArray;
  begin
    Result := TJSONArray.Create;

    Inc(Pos);
    while FStr[Pos] <> ']' do
      Result.Add(Parse(Pos));

    Inc(Pos);
  end;

var
  StringValue: ^TJSONString;
  NumberValue: ^TJSONNumber;
begin
  with TJSONItemBuilder.GetBuilder do
    try
      while Pos <= FStr.Length do
        begin
          case FStr[Pos] of
            '[':
              begin
                SetObjectType(jsonArray);
                SetValue(ReadArray);
                Break;
              end;
            '{':
              begin
                SetObjectType(jsonObject);
                SetValue(ReadObject);
                Break;
              end;
            '"':
              begin
                New(StringValue);
                SetObjectType(jsonString);
                StringValue^ := ReadString;
                SetValue(StringValue);
                Break;
              end;
            '-', '0' .. '9':
              begin
                New(NumberValue);
                SetObjectType(jsonNumber);
                NumberValue^ := ReadNumber;
                SetValue(NumberValue);
                Break;
              end;
          end;

          Inc(Pos);
        end;

      Result := Build;
    finally
      Free;
    end;
end;

function TJSONParser.Parse: TJSONItem;
var
  Pos: Integer;
begin
  Pos := 1;
  Result := Parse(Pos);
end;

class function TJSONParser.Parse(const S: String): TJSONItem;
begin
  with TJSONParser.Create(S) do
    try
      Result := Parse;
    finally
      Free;
    end;
end;

end.
