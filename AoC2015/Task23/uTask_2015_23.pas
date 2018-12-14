unit uTask_2015_23;

interface

uses
  System.Generics.Collections, System.Classes, uTask;

type
  TState = class;

  TRegisterType = ( rtNone, rtRegA, rtRegB );
  TInstructionType = ( itNone, itHlf, itTpl, itInc, itJmp, itJie, itJio );
  TInstruction = record
    Owner: TState;
    InstructionType: TInstructionType;
    RegisterType: TRegisterType;
    Offset: Integer;
    constructor Create(const AOwner: TState; const Cmd: String);
    procedure Execute;
  end;

  TInstructions = TList<TInstruction>;

  TState = class
  private
    FReg: array [TRegisterType] of Integer;
    FInstructions: TInstructions;
    FOffset: Integer;
    procedure Step;
    function GetReg(const Index: TRegisterType): Integer;
  public
    constructor Create(const ARegA: Integer; const AInstructions: TStrings);
    destructor Destroy; override;
    procedure Run;
    property Instructions: TInstructions read FInstructions;
    property RegA: Integer index rtRegA read GetReg;
    property RegB: Integer index rtRegB read GetReg;
  end;

  TTask_AoC = class (TTask)
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TInstruction }

constructor TInstruction.Create(const AOwner: TState; const Cmd: String);

  function GetInstructionType(const S: String): TInstructionType;
  begin
    Result := itNone;
    if S = 'hlf' then
      Result := itHlf
    else if S = 'tpl' then
      Result := itTpl
    else if S = 'inc' then
      Result := itInc
    else if S = 'jmp' then
      Result := itJmp
    else if S = 'jio' then
      Result := itJio
    else if S = 'jie' then
      Result := itJie;
  end;

  function GetRegisterType(const S: String): TRegisterType;
  begin
    Result := rtNone;
    if S = 'a' then
      Result := rtRegA
    else if S = 'b' then
      Result := rtRegB;
  end;

var
  A: TArray<String>;
begin
  Owner := AOwner;
  Offset := 0;

  A := Cmd.Split([', ', ' ']);
  InstructionType := GetInstructionType(A[0]);
  case InstructionType of
    itHlf: RegisterType := GetRegisterType(A[1]);
    itTpl: RegisterType := GetRegisterType(A[1]);
    itInc: RegisterType := GetRegisterType(A[1]);
    itJmp: Offset := A[1].ToInteger;
    itJie:
      begin
        RegisterType := GetRegisterType(A[1]);
        Offset := A[2].ToInteger;
      end;
    itJio:
      begin
        RegisterType := GetRegisterType(A[1]);
        Offset := A[2].ToInteger;
      end;
  end;
end;

procedure TInstruction.Execute;
var
  IncOffset: Boolean;
begin
  IncOffset := True;

  case InstructionType of
    itHlf: Owner.FReg[RegisterType] := Owner.FReg[RegisterType] div 2;
    itTpl: Owner.FReg[RegisterType] := Owner.FReg[RegisterType] * 3;
    itInc: Inc(Owner.FReg[RegisterType]);
    itJmp:
      begin
        Inc(Owner.FOffset, Offset);
        IncOffset := False;
      end;
    itJie:
      if Owner.FReg[RegisterType] mod 2 = 0 then
        begin
          Inc(Owner.FOffset, Offset);
          IncOffset := False;
        end;
    itJio:
      if Owner.FReg[RegisterType] = 1 then
        begin
          Inc(Owner.FOffset, Offset);
          IncOffset := False;
        end;
  end;

  if IncOffset then
    Inc(Owner.FOffset);
end;

{ TState }

constructor TState.Create(const ARegA: Integer; const AInstructions: TStrings);
var
  I: Integer;
begin
  FReg[rtRegA] := ARegA;
  FReg[rtRegB] := 0;

  FOffset := 0;

  FInstructions := TInstructions.Create;
  if Assigned(AInstructions) then
    for I := 0 to AInstructions.Count - 1 do
      FInstructions.Add(TInstruction.Create(Self, AInstructions[I]));
end;

destructor TState.Destroy;
begin
  FreeAndNil(FInstructions);
  inherited;
end;

function TState.GetReg(const Index: TRegisterType): Integer;
begin
  Result := FReg[Index];
end;

procedure TState.Run;
begin
  while FOffset < FInstructions.Count do
    Step;
end;

procedure TState.Step;
begin
  FInstructions[FOffset].Execute;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;

  function RunState(const RegA: Integer; const Instructions: TStrings): Integer;
  begin
    with TState.Create(RegA, Instructions) do
      try
        Run;
        Result := RegB;
      finally
        Free;
      end;
  end;

var
  Part1, Part2: Integer;
  Instructions: TStrings;
begin
  Instructions := Input;
  with Instructions do
    try
      Part1 := RunState(0, Instructions);
      Part2 := RunState(1, Instructions);
    finally
      Free;
    end;

  OK(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
end;

initialization
  GTask := TTask_AoC.Create(2015, 23, 'Opening the Turing Lock');

finalization
  GTask.Free;

end.
