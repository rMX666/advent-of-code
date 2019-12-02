unit IntCode;

interface

uses
  SysUtils, System.Generics.Collections;

type
  TIntCode = class;

  TInstructionType = ( itNone = 0
                     , itAdd  = 1
                     , itMul  = 2
                     , itHalt = 99
                     );
  TInstruction = record
  private
    FOwner: TIntCode;
    FParamCount: Integer;
    function GetParamCount: Integer;
    procedure RaiseWrongInstructionTypeException;
  public
    FInstructionType: TInstructionType;
    FParams: TArray<Integer>;
    constructor Create(const AOwner: TIntCode; const AIndex: Integer);
    function Execute: Boolean;
    property ParamCount: Integer read GetParamCount;
  end;

  TIntCode = class(TList<Integer>)
  public
    function Execute(const Noun, Verb: Integer): Integer;
    function Clone: TIntCode;
  public
    type
      TEnum = class(TEnumerator<TInstruction>)
      private
        FOwner: TIntCode;
        FIndex: Integer;
        FCurrent: TInstruction;
        function GetCurrent: TInstruction;
      protected
        function DoGetCurrent: TInstruction; override;
        function DoMoveNext: Boolean; override;
      public
        constructor Create(const AOwner: TIntCode);
        property Current: TInstruction read GetCurrent;
        function MoveNext: Boolean;
      end;
    function GetEnumerator: TEnum; reintroduce; inline;
  end;

implementation


{ TInstruction }

constructor TInstruction.Create(const AOwner: TIntCode; const AIndex: Integer);
begin
  FParamCount := -1;
  FOwner := AOwner;
  FInstructionType := TInstructionType(FOwner[AIndex]);
  FParams := Copy(FOwner.ToArray, AIndex + 1, ParamCount);
end;

function TInstruction.Execute: Boolean;
begin
  Result := True;

  case FInstructionType of
    itAdd: FOwner[FParams[2]] := FOwner[FParams[0]] + FOwner[FParams[1]];
    itMul: FOwner[FParams[2]] := FOwner[FParams[0]] * FOwner[FParams[1]];
    itHalt: Exit(False);
    else RaiseWrongInstructionTypeException;
  end;
end;

function TInstruction.GetParamCount: Integer;
begin
  if FParamCount = -1 then
    case FInstructionType of
      itAdd:  FParamCount := 3;
      itMul:  FParamCount := 3;
      itHalt: FParamCount := 1;
      else RaiseWrongInstructionTypeException;
    end;

  Result := FParamCount;
end;

procedure TInstruction.RaiseWrongInstructionTypeException;
begin
  raise Exception.CreateFmt('Wrong instruction type: %d', [ Integer(FInstructionType) ]);
end;

{ TMemoryState.TEnum }

constructor TIntCode.TEnum.Create(const AOwner: TIntCode);
begin
  FOwner := AOwner;
  FIndex := 0;
  FCurrent := TInstruction.Create(FOwner, FIndex);
end;

function TIntCode.TEnum.DoGetCurrent: TInstruction;
begin
  Result := GetCurrent;
end;

function TIntCode.TEnum.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TIntCode.TEnum.GetCurrent: TInstruction;
begin
  Result := FCurrent;
end;

function TIntCode.TEnum.MoveNext: Boolean;
begin
  Result := True;
  Inc(FIndex, 1 + FCurrent.ParamCount);
  if FIndex < FOwner.Count then
    FCurrent := TInstruction.Create(FOwner, FIndex)
  else
    Result := False;
end;

{ TMemoryState }

function TIntCode.Clone: TIntCode;
begin
  Result := TIntCode.Create;
  Result.AddRange(ToArray);
end;

function TIntCode.Execute(const Noun, Verb: Integer): Integer;
var
  I: TInstruction;
begin
  Items[1] := Noun;
  Items[2] := Verb;
  for I in Self do
    if not I.Execute then
      Break;

  Result := Items[0];
end;

function TIntCode.GetEnumerator: TEnum;
begin
  Result := TEnum.Create(Self);
end;

end.
