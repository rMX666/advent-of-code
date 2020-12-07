unit uTask_2020_07;

interface

uses
  System.Generics.Collections, uTask;

type
  TBag = record
    Color: String;
    Count: Integer;
  end;

  TBagRule = record
  private
    FContents: TArray<TBag>;
    FColor: String;
    function GetContents(const Index: Integer): TBag;
    function GetCount: Integer;
  public
    constructor Create(Rule: String);
    property Color: String read FColor;
    property Count: Integer read GetCount;
    property Contents[const Index: Integer]: TBag read GetContents; default;
  end;

  TRules = TDictionary<String,TBagRule>;

  TTask_AoC = class (TTask)
  private
    const MY_BAG = 'shiny gold';
  private
    FRules: TRules;
    procedure LoadRules;
    function CountContainersForMyBag: Integer;
    function CountContentsOfMyBag: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TBagRule }

constructor TBagRule.Create(Rule: String);
var
  A: TArray<String>;
  I, P: Integer;
begin
  FColor := Rule.Substring(0, Rule.IndexOf(' bags contain'));
  Rule := Rule.Replace(FColor + ' bags contain ', '').Replace('.', '').Replace(' bags', '').Replace(' bag', '');
  A := Rule.Split([', ']);
  SetLength(FContents, Length(A));
  for I := 0 to Length(A) - 1 do
    if not A[I].StartsWith('no') then
      begin
        P := A[I].IndexOf(' ');
        FContents[I].Color := A[I].Substring(P + 1);
        FContents[I].Count := A[I].Substring(0, P).ToInteger;
      end
    else
      SetLength(FContents, 0);
end;

function TBagRule.GetContents(const Index: Integer): TBag;
begin
  Result := FContents[Index];
end;

function TBagRule.GetCount: Integer;
begin
  Result := Length(FContents);
end;

{ TTask_AoC }

function TTask_AoC.CountContentsOfMyBag: Integer;

  function GetProduct(const Bag: String): Integer;
  var
    I: Integer;
  begin
    Result := 1;
    with FRules[Bag] do
      for I := 0 to Count - 1 do
        Inc(Result, Contents[I].Count * GetProduct(Contents[I].Color));
  end;

begin
  Result := GetProduct(MY_BAG) - 1;
end;

function TTask_AoC.CountContainersForMyBag: Integer;
var
  Colors: TList<String>;

  function DirectlyContain(const Bag: String): TArray<String>;
  var
    Rule: TBagRule;
    I, L: Integer;
  begin
    L := 0;
    SetLength(Result, L);
    for Rule in FRules.Values do
      if Rule.Count > 0 then
        for I := 0 to Rule.Count - 1 do
          if Rule[I].Color = Bag then
            begin
              SetLength(Result, L + 1);
              Result[L] := Rule.Color;
              Inc(L);
            end;
  end;

  procedure IndirectlyContain(const Bag: String);
  var
    Parents: TArray<String>;
    I: Integer;
  begin
    Parents := DirectlyContain(Bag);
    for I := 0 to Length(Parents) - 1 do
      if not Colors.Contains(Parents[I]) then
        begin
          Colors.Add(Parents[I]);
          IndirectlyContain(Parents[I]);
        end;
  end;
begin
  Colors := TList<String>.Create;
  try
    IndirectlyContain(MY_BAG);
    Result := Colors.Count;
  finally
    Colors.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    LoadRules;
    Ok('Part 1: %d, Part 2: %d', [ CountContainersForMyBag, CountContentsOfMyBag ]);
  finally
    FRules.Free;
  end;
end;

procedure TTask_AoC.LoadRules;
var
  I: Integer;
  Rule: TBagRule;
begin
  FRules := TRules.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          Rule := TBagRule.Create(Strings[I]);
          FRules.Add(Rule.Color, Rule);
        end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 7, 'Handy Haversacks');

finalization
  GTask.Free;

end.
