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
  TExecuteResult = ( erNone, erOk, erNoInc, erHalt, erWaitForInput );
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
    function Execute: TExecuteResult;
    property Params[const Index: Integer]: Integer read GetParams write SetParams;
    property ParamCount: Integer read GetParamCount;
  end;

  TIntCode = class(TList<Integer>)
  private
    FInstructionPointer: Integer;
    FProgramLabel: String;
    FInputQueue: TQueue<Integer>;
    FOutput: TList<Integer>;
  protected
    property InstructionPointer: Integer read FInstructionPointer write FInstructionPointer;
  public
    constructor Create;
    destructor Destroy; override;
    class function LoadProgram(const Input: String): TIntCode;
    function Execute: TExecuteResult;
    function Clone: TIntCode;
    procedure AddInput(const Value: Integer);
    function GetInput: Integer;
    property Output: TList<Integer> read FOutput;
    property ProgramLabel: String read FProgramLabel;
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

function TInstruction.Execute: TExecuteResult;
begin
  Result := erOk;

  case FInstructionType of
    itAdd:
      Params[2] := Params[0] + Params[1];
    itMul:
      Params[2] := Params[0] * Params[1];
    itIn:
      try
        Params[0] := FOwner.GetInput;
      except
        Exit(erWaitForInput);
      end;
    itOut:
      FOwner.Output.Add(Params[0]);
    itJNZ:
      if Params[0] <> 0 then
        begin
          FOwner.InstructionPointer := Params[1];
          Result := erNoInc;
        end;
    itJZ:
      if Params[0] = 0 then
        begin
          FOwner.InstructionPointer := Params[1];
          Result := erNoInc;
        end;
    itLT:
      Params[2] := Integer(Params[0] < Params[1]);
    itEq:
      Params[2] := Integer(Params[0] = Params[1]);
    //
    itHalt:
      Exit(erHalt);
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

constructor TIntCode.Create;
begin
  inherited Create;
  FInputQueue := TQueue<Integer>.Create;
  FOutput := TList<Integer>.Create;
end;

destructor TIntCode.Destroy;
begin
  FreeAndNil(FInputQueue);
  FreeAndNil(FOutput);
  inherited;
end;

function TIntCode.GetInput: Integer;
begin
  Result := FInputQueue.Dequeue;
end;

procedure TIntCode.AddInput(const Value: Integer);
begin
  FInputQueue.Enqueue(Value);
end;

function TIntCode.Clone: TIntCode;
begin
  Result := TIntCode.Create;
  Result.AddRange(ToArray);
end;

function TIntCode.Execute: TExecuteResult;
var
  E: TExecuteResult;
begin
  InstructionPointer := 0;
  Result := erNone;

  while FInstructionPointer < Count do
    with TInstruction.Create(Self, InstructionPointer) do
      begin
        E := Execute;
        case E of
          erOk:
            Inc(FInstructionPointer, 1 + ParamCount);
          erNoInc:
            ; // Do not shift the instruction pointer
          erHalt,
          erWaitForInput:
            Exit(E);
          else
            raise Exception.CreateFmt('Wrong instruction execute result code: %d', [ Integer(E) ]);
        end;
      end;
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
