unit uTask_2019_02;

interface

uses
  uTask, IntCode;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function CalcNounAndVerb(const Noun, Verb: Integer): Integer;
    function FindNounAndVerb(const ExpectedResult: Integer): Integer;
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
  State: TIntCode;
begin
  LoadProgram;
  State := FInitialState.Clone;
  try
    OK('Part 1: %d, Part 2: %d', [ CalcNounAndVerb(12, 2), FindNounAndVerb(19690720) ]);
  finally
    State.Free;
    FInitialState.Free;
  end;
end;

function TTask_AoC.CalcNounAndVerb(const Noun, Verb: Integer): Integer;
begin
  Result := -1;
  with FInitialState.Clone do
    try
      Items[1] := Noun;
      Items[2] := Verb;
      if Execute = erHalt then
        Result := Items[0];
    finally
      Free;
    end;
end;

function TTask_AoC.FindNounAndVerb(const ExpectedResult: Integer): Integer;
var
  I, J: Integer;
begin
  Result := -1;
  for I := 0 to 99 do
    for J := 0 to 99 do
      if CalcNounAndVerb(I, J) = ExpectedResult then
        Exit(I * 100 + J);
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TIntCode.LoadProgram(Text);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 2, '1202 Program Alarm');

finalization
  GTask.Free;

end.
