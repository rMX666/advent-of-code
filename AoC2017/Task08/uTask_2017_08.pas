unit uTask_2017_08;

interface

uses
  System.Generics.Collections, uTask;

type
  TRegisters = TDictionary<String,Integer>;

  TTask_AoC = class (TTask)
  private
    FRegisters: TRegisters;
    FMaxRegister: Integer;
    procedure ProcessInstruction(const S: String);
    function MaxRegister: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  I, LastMax: Integer;
begin
  FRegisters := TRegisters.Create;
  FMaxRegister := 0;

  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          ProcessInstruction(Strings[I]);
          LastMax := MaxRegister;
          if FMaxRegister < LastMax then
            FMaxRegister := LastMax;
        end;
    finally
      OK(Format('Part 1: %d, Part 2: %d', [ MaxRegister, FMaxRegister ]));
      FRegisters.Free;
      Free;
    end;
end;

function TTask_AoC.MaxRegister: Integer;
var
  Value: Integer;
begin
  Result := 0;
  for Value in FRegisters.Values do
    if Value > Result then
      Result := Value;
end;

procedure TTask_AoC.ProcessInstruction(const S: String);

  procedure DoOp(const Reg, Op: String; const Val: Integer);
  begin
    if Op = 'inc' then
      FRegisters[Reg] := FRegisters[Reg] + Val
    else if Op = 'dec' then
      FRegisters[Reg] := FRegisters[Reg] - Val;
  end;

var
  A: TArray<String>;
  RegA, RegB, Comp, Op: String;
  ValI, ValC, RegBVal: Integer;
  CompRes: Boolean;
begin
  A := S.Split([' ']);

  RegA := A[0];
  Op   := A[1];
  ValI := A[2].ToInteger;
  RegB := A[4];
  Comp := A[5];
  ValC := A[6].ToInteger;

  if not FRegisters.ContainsKey(RegA) then
    FRegisters.Add(RegA, 0);
  if not FRegisters.ContainsKey(RegB) then
    FRegisters.Add(RegB, 0);

  RegBVal := FRegisters[RegB];

  CompRes := False;
  if      Comp = '==' then CompRes := RegBVal =  ValC
  else if Comp = '!=' then CompRes := RegBVal <> ValC
  else if Comp = '>'  then CompRes := RegBVal >  ValC
  else if Comp = '<'  then CompRes := RegBVal <  ValC
  else if Comp = '>=' then CompRes := RegBVal >= ValC
  else if Comp = '<=' then CompRes := RegBVal <= ValC;

  if CompRes then
    DoOp(RegA, Op, ValI);
end;

initialization
  GTask := TTask_AoC.Create(2017, 8, 'I Heard You Like Registers');

finalization
  GTask.Free;

end.
