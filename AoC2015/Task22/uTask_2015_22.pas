unit uTask_2015_22;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FBossHealth, FBossDamage: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uGame_2015_22;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Integer;
begin
  with Input do
    try
      FBossHealth := Strings[0].Split([': '])[1].ToInteger;
      FBossDamage := Strings[1].Split([': '])[1].ToInteger;
    finally
      Free;
    end;

  Part1 := TSimulator.Simulate(FBossHealth, FBossDamage, False);
  Part2 := TSimulator.Simulate(FBossHealth, FBossDamage, True);

  OK('Part 1: %d, Part 2: %d', [ Part1, Part2 ]);
end;

initialization
  GTask := TTask_AoC.Create(2015, 22, 'Wizard Simulator 20XX');

finalization
  GTask.Free;

end.
