unit uTask_2017_15;

interface

uses
  uTask;

const
  GEN_A_FACTOR: Int64 = 16807;
  GEN_B_FACTOR: Int64 = 48271;
  MOD_BASE: Int64     = 2147483647;

type
  TTask_AoC = class (TTask)
  private
    FGenAInitial, FGenBInitial: Integer;
    procedure InitializeGenerators;
    function GetNextValue(const Value, Factor: Int64): Int64; inline;
    function Judge(const Part: Integer): Integer;
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
begin
  InitializeGenerators;

  OK('Part 1: %d, Part 2: %d', [ Judge(1), Judge(2) ]);
end;

function TTask_AoC.GetNextValue(const Value, Factor: Int64): Int64;
begin
  Result := Value * Factor mod MOD_BASE;
end;

procedure TTask_AoC.InitializeGenerators;

  function Parse(const S: String): Integer;
  begin
    Result := S.Split([' '])[4].ToInteger;
  end;

begin
  with Input do
    try
      FGenAInitial := Parse(Strings[0]);
      FGenBInitial := Parse(Strings[1]);
    finally
      Free;
    end;
end;

function TTask_AoC.Judge(const Part: Integer): Integer;
var
  Rounds: Integer;
  GenA, GenB: Int64;
begin
  case Part of
    1: Rounds := 40000000;
    2: Rounds :=  5000000;
    else Rounds := -1;
  end;

  Result := 0;
  GenA := FGenAInitial;
  GenB := FGenBInitial;
  while Rounds > 0 do
    begin
      GenA := GetNextValue(GenA, GEN_A_FACTOR);
      GenB := GetNextValue(GenB, GEN_B_FACTOR);
      if Part = 2 then
        begin
          while GenA mod 4 <> 0 do
            GenA := GetNextValue(GenA, GEN_A_FACTOR);
          while GenB mod 8 <> 0 do
            GenB := GetNextValue(GenB, GEN_B_FACTOR);
        end;

      if Word(GenA) = Word(GenB) then
        Inc(Result);

      Dec(Rounds);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 15, 'Dueling Generators');

finalization
  GTask.Free;

end.
