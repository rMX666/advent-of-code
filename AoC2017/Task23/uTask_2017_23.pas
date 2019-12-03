unit uTask_2017_23;

interface

uses
  System.Generics.Collections, uTask;

type
  TInstructionType = ( itNone, itSet, itSub, itMul, itJnz );

  TCoProcessor = class;

  TInstruction = record
  private
    FOwner: TCoProcessor;
    A, B: String;
    function Val(const S: String): Integer;
  public
    InstructionType: TInstructionType;
    constructor Create(const Owner: TCoProcessor; const S: String);
    function ValA: Integer;
    function ValB: Integer;
  end;

  TCoProcessor = class(TList<TInstruction>)
  private
    FRegisters: TDictionary<Char,Integer>;
    FIndex: Integer;
    FStatistics: TDictionary<TInstructionType,Integer>;
    function GetStat(const InstructionType: TInstructionType): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddInstruction(const S: String);
    function Step: Boolean;
    property Stat[const InstructionType: TInstructionType]: Integer read GetStat;
  end;

  TTask_AoC = class (TTask)
  private
    function GetMulExcutions: Integer;
    function OptimizedPart2: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TInstruction }

constructor TInstruction.Create(const Owner: TCoProcessor; const S: String);
var
  A: TArray<String>;
begin
  FOwner := Owner;

  A := S.Split([' ']);
  if      A[0] = 'set' then InstructionType := itSet
  else if A[0] = 'sub' then InstructionType := itSub
  else if A[0] = 'mul' then InstructionType := itMul
  else if A[0] = 'jnz' then InstructionType := itJnz;
  Self.A := A[1];
  Self.B := A[2];
end;

function TInstruction.Val(const S: String): Integer;
begin
  if not TryStrToInt(S, Result) then
    Result := FOwner.FRegisters[S[1]];
end;

function TInstruction.ValA: Integer;
begin
  Result := Val(A);
end;

function TInstruction.ValB: Integer;
begin
  Result := Val(B);
end;

{ TCoProcessor }

procedure TCoProcessor.AddInstruction(const S: String);
begin
  Add(TInstruction.Create(Self, S));
end;

constructor TCoProcessor.Create;
var
  C: Char;
  I: TInstructionType;
begin
  inherited Create;

  FRegisters := TDictionary<Char,Integer>.Create;
  for C := 'a' to 'h' do
    FRegisters.Add(C, 0);

  FIndex := 0;

  FStatistics := TDictionary<TInstructionType,Integer>.Create;
  for I := itSet to itJnz do
    FStatistics.Add(I, 0);
end;

destructor TCoProcessor.Destroy;
begin
  FRegisters.Free;
  FStatistics.Free;
  inherited;
end;

function TCoProcessor.GetStat(const InstructionType: TInstructionType): Integer;
begin
  Result := FStatistics[InstructionType];
end;

function TCoProcessor.Step: Boolean;
var
  I: TInstruction;
begin
  if (FIndex < 0) or (FIndex >= Count) then
    Exit(False);

  Result := True;

  I := Items[FIndex];
  case I.InstructionType of
    itSet:
      FRegisters[I.A[1]] := I.ValB;
    itSub:
      FRegisters[I.A[1]] := FRegisters[I.A[1]] - I.ValB;
    itMul:
      FRegisters[I.A[1]] := FRegisters[I.A[1]] * I.ValB;
    itJnz:
      if I.ValA <> 0 then
        Inc(FIndex, I.ValB)
      else
        Inc(FIndex);
  end;

  FStatistics[I.InstructionType] := FStatistics[I.InstructionType] + 1;

  if I.InstructionType <> itJnz then
    Inc(FIndex);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  OK('Part 1: %d, Part 2: %d', [ GetMulExcutions, OptimizedPart2 ]);
end;

function TTask_AoC.GetMulExcutions: Integer;
var
  P: TCoProcessor;
  I: Integer;
begin
  P := TCoProcessor.Create;
  try
    with Input do
      try
        for I := 0 to Count - 1 do
          P.AddInstruction(Strings[I]);
      finally
        Free;
      end;

    while P.Step do;

    Result := P.Stat[itMul];
  finally
    P.Free;
  end;
end;

function TTask_AoC.OptimizedPart2: Integer;
var
  I, J: Integer;
begin
  Result := 0;

  I := 106500;
  while I <= 123500 do
    begin
      // IsPrime
      for J := 2 to I div 2 do
        if I mod J = 0 then
          begin
            Inc(Result);
            Break;
          end;

      Inc(I, 17);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 23, 'Coprocessor Conflagration');

finalization
  GTask.Free;

end.
