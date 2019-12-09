unit IntCode;

interface

uses
  SysUtils, System.Generics.Collections;

type
  TIntCode = class;

  TInstructionType = ( itNone =  0 // Dummy
                     , itAdd  =  1 // Summ two values
                     , itMul  =  2 // Multiply two values
                     , itIn   =  3 // Request imput value
                     , itOut  =  4 // Output value
                     , itJNZ  =  5 // Jump if not zero
                     , itJZ   =  6 // Jump if zero
                     , itLT   =  7 // Less then check
                     , itEq   =  8 // Equality check
                     , itRelC =  9 // Change relative base value
                     , itHalt = 99 // Stop program execution
                     );
  TParameterMode = ( pmPosition
                   , pmImmediate
                   , pmRelative
                   );
  TExecuteResult = ( erNone, erOk, erNoInc, erHalt, erWaitForInput );
  TParameterModes = array [0..2] of TParameterMode;
  TInstruction = record
  private
    FInstructionType: TInstructionType;
    FParams: TArray<Int64>;
    FIndex: Integer;
    FOwner: TIntCode;
    FParamCount: Integer;
    FParameterModes: TParameterModes;
    function GetParamCount: Integer;
    procedure RaiseWrongInstructionTypeException;
    function GetParams(const Index: Integer): Int64;
    procedure SetParams(const Index: Integer; const Value: Int64);
  public
    constructor Create(const AOwner: TIntCode; const AIndex: Integer);
    function Execute: TExecuteResult;
    property Params[const Index: Integer]: Int64 read GetParams write SetParams;
    property ParamCount: Integer read GetParamCount;
  end;

  TIntCode = class(TList<Int64>)
  private
    FInstructionPointer: Integer;
    FInputQueue: TQueue<Int64>;
    FOutput: TList<Int64>;
    FRelativeBase: Integer;
    function GetItem(const Index: Integer): Int64;
    procedure SetItem(const Index: Integer; const Value: Int64);
  protected
    property InstructionPointer: Integer read FInstructionPointer write FInstructionPointer;
    property RelativeBase: Integer read FRelativeBase write FRelativeBase;
  public
    constructor Create;
    destructor Destroy; override;
    class function LoadProgram(const Input: String): TIntCode;
    function Execute: TExecuteResult;
    function Clone: TIntCode;
    procedure AddInput(const Value: Int64);
    function TryGetInput(out Value: Int64): Boolean;
    property Output: TList<Int64> read FOutput;
    property Items[const Index: Integer]: Int64 read GetItem write SetItem; default;
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
var
  Tmp: Int64;
begin
  Result := erOk;

  case FInstructionType of
    itAdd:
      Params[2] := Params[0] + Params[1];
    itMul:
      Params[2] := Params[0] * Params[1];
    itIn:
      if FOwner.TryGetInput(Tmp) then
        Params[0] := Tmp
      else
        Exit(erWaitForInput);
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
    itRelC:
      FOwner.RelativeBase := FOwner.RelativeBase + Params[0];
    //
    itHalt:
      Exit(erHalt);
    else
      RaiseWrongInstructionTypeException;
  end;
end;

function TInstruction.GetParams(const Index: Integer): Int64;
begin
  Result := 0;
  case FParameterModes[Index] of
    pmPosition:
      Result := FOwner[FParams[Index]];
    pmImmediate:
      Result := FParams[Index];
    pmRelative:
      Result := FOwner[FOwner.RelativeBase + FParams[Index]];
  end;
end;

procedure TInstruction.SetParams(const Index: Integer; const Value: Int64);
begin
  case FParameterModes[Index] of
    pmPosition:
      FOwner[FParams[Index]] := Value;
    pmImmediate:
      begin
        FParams[Index] := Value;
        FOwner[FIndex + Index + 1] := Value;
      end;
    pmRelative:
      FOwner[FOwner.RelativeBase + FParams[Index]] := Value;
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
      itRelC: FParamCount := 1;
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
end;

constructor TIntCode.Create;
begin
  inherited Create;
  FInputQueue := TQueue<Int64>.Create;
  FOutput := TList<Int64>.Create;
  FRelativeBase := 0;
  FInstructionPointer := 0;
end;

destructor TIntCode.Destroy;
begin
  FreeAndNil(FInputQueue);
  FreeAndNil(FOutput);
  inherited;
end;

function TIntCode.TryGetInput(out Value: Int64): Boolean;
begin
  Result := True;
  if FInputQueue.Count = 0 then
    Exit(False);

  Value := FInputQueue.Dequeue;
end;

procedure TIntCode.AddInput(const Value: Int64);
begin
  FInputQueue.Enqueue(Value);
end;

function TIntCode.GetItem(const Index: Integer): Int64;
begin
  while Count <= Index do
    Add(0);

  Result := inherited Items[Index];
end;

procedure TIntCode.SetItem(const Index: Integer; const Value: Int64);
begin
  while Count <= Index do
    Add(0);

  inherited Items[Index] := Value;
end;

function TIntCode.Execute: TExecuteResult;
var
  E: TExecuteResult;
begin
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
