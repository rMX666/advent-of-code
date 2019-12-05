unit IntCode;

interface

uses
  SysUtils, System.Generics.Collections;

type
  TIntCode = class;

  TInstructionType = ( itNone = 0
                     , itAdd  = 1
                     , itMul  = 2
                     , itIn   = 3
                     , itOut  = 4
                     , itJNZ  = 5
                     , itJZ   = 6
                     , itLT   = 7
                     , itEq   = 8
                     , itHalt = 99
                     );
  TParameterMode = ( pmPosition
                   , pmImmediate
                   );
  TInstructionExecuteResult = ( ierOk, ierNoInc, ierHalt );
  TParameterModes = array [0..2] of TParameterMode;
  TInstruction = record
  private
    FIndex: Integer;
    FOwner: TIntCode;
    FParamCount: Integer;
    FParameterModes: TParameterModes;
    function GetParamCount: Integer;
    procedure RaiseWrongInstructionTypeException;
    function GetParams(const Index: Integer): Integer;
    procedure SetParams(const Index, Value: Integer);
  public
    FInstructionType: TInstructionType;
    FParams: TArray<Integer>;
    constructor Create(const AOwner: TIntCode; const AIndex: Integer);
    function Execute: TInstructionExecuteResult;
    property Params[const Index: Integer]: Integer read GetParams write SetParams;
    property ParamCount: Integer read GetParamCount;
  end;

  TOnInputHandler  = procedure (const Sender: TIntCode; out Value: Integer) of object;
  TOnOutputHandler = procedure (const Sender: TIntCode; const Value: Integer) of object;

  TIntCode = class(TList<Integer>)
  private
    FInstructionPointer: Integer;
    FOnInput: TOnInputHandler;
    FOnOutput: TOnOutputHandler;
  protected
    procedure DoOnInput(var Value: Integer);
    procedure DoOnOutput(const Value: Integer);
    property InstructionPointer: Integer read FInstructionPointer write FInstructionPointer;
  public
    class function LoadProgram(const Input: String): TIntCode;
    function Execute: Integer; overload;
    function Execute(const Noun, Verb: Integer): Integer; overload;
    function Clone: TIntCode;
    property OnInput: TOnInputHandler read FOnInput write FOnInput;
    property OnOutput: TOnOutputHandler read FOnOutput write FOnOutput;
  end;

implementation


{ TInstruction }

constructor TInstruction.Create(const AOwner: TIntCode; const AIndex: Integer);
begin
  FParamCount := -1;
  FIndex := AIndex;
  FOwner := AOwner;
  FInstructionType := TInstructionType(FOwner[FIndex] mod 100);
  FParams := Copy(FOwner.ToArray, FIndex + 1, ParamCount);

  FParameterModes[0] := TParameterMode((FOwner[FIndex] div 100)   mod 10);
  FParameterModes[1] := TParameterMode((FOwner[FIndex] div 1000)  mod 10);
  FParameterModes[2] := TParameterMode((FOwner[FIndex] div 10000) mod 10);
end;

function TInstruction.Execute: TInstructionExecuteResult;
var
  Tmp: Integer;
begin
  Result := ierOk;

  case FInstructionType of
    itAdd:
      Params[2] := Params[0] + Params[1];
    itMul:
      Params[2] := Params[0] * Params[1];
    itIn:
      begin
        FOwner.DoOnInput(Tmp);
        Params[0] := Tmp;
      end;
    itOut:
      FOwner.DoOnOutput(Params[0]);
    itJNZ:
      if Params[0] <> 0 then
        begin
          FOwner.InstructionPointer := Params[1];
          Result := ierNoInc;
        end;
    itJZ:
      if Params[0] = 0 then
        begin
          FOwner.InstructionPointer := Params[1];
          Result := ierNoInc;
        end;
    itLT:
      Params[2] := Integer(Params[0] < Params[1]);
    itEq:
      Params[2] := Integer(Params[0] = Params[1]);
    //
    itHalt:
      Exit(ierHalt);
    else
      RaiseWrongInstructionTypeException;
  end;
end;

function TInstruction.GetParams(const Index: Integer): Integer;
begin
  Result := 0;
  case FParameterModes[Index] of
    pmPosition:
      Result := FOwner[FParams[Index]];
    pmImmediate:
      Result := FParams[Index];
  end;
end;

procedure TInstruction.SetParams(const Index, Value: Integer);
begin
  case FParameterModes[Index] of
    pmPosition:
      FOwner[FParams[Index]] := Value;
    pmImmediate:
      begin
        FParams[Index] := Value;
        FOwner[FIndex + Index + 1] := Value;
      end;
  end;
end;

function TInstruction.GetParamCount: Integer;
begin
  if FParamCount = -1 then
    case FInstructionType of
      itAdd:  FParamCount := 3;
      itMul:  FParamCount := 3;
      itIn:   FParamCount := 1;
      itOut:  FParamCount := 1;
      itJNZ:  FParamCount := 2;
      itJZ:   FParamCount := 2;
      itLT:   FParamCount := 3;
      itEq:   FParamCount := 3;
      //
      itHalt: FParamCount := 0;
      else RaiseWrongInstructionTypeException;
    end;

  Result := FParamCount;
end;

procedure TInstruction.RaiseWrongInstructionTypeException;
begin
  raise Exception.CreateFmt('Wrong instruction type: %d', [ Integer(FInstructionType) ]);
end;

{ TIntCode }

function TIntCode.Clone: TIntCode;
begin
  Result := TIntCode.Create;
  Result.AddRange(ToArray);
  Result.FOnInput := FOnInput;
  Result.FOnOutput := FOnOutput;
end;

procedure TIntCode.DoOnInput(var Value: Integer);
begin
  if Assigned(FOnInput) then
    FOnInput(Self, Value);
end;

procedure TIntCode.DoOnOutput(const Value: Integer);
begin
  if Assigned(FOnOutput) then
    FOnOutput(Self, Value);
end;

function TIntCode.Execute: Integer;
begin
  InstructionPointer := 0;

  while FInstructionPointer < Count do
    with TInstruction.Create(Self, InstructionPointer) do
      case Execute of
        ierOk:
          InstructionPointer := InstructionPointer + 1 + ParamCount;
        ierNoInc:
          ; // Dummy
        ierHalt:
          Break;
      end;

  Result := Items[0];
end;

function TIntCode.Execute(const Noun, Verb: Integer): Integer;
begin
  Items[1] := Noun;
  Items[2] := Verb;

  Result := Execute;
end;

class function TIntCode.LoadProgram(const Input: String): TIntCode;
var
  A: TArray<String>;
  I: Integer;
begin
  A := Input.Trim.Split([',']);

  Result := TIntCode.Create;
  for I := 0 to Length(A) - 1 do
    Result.Add(A[I].ToInteger);
end;

end.
