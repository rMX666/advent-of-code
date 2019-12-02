unit uTask_2019_02;

interface

uses
  uTask, IntCode;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
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
  try
    LoadProgram;
    State := FInitialState.Clone;
    OK(Format('Part 1: %d, Part 2: %d', [ State.Execute(12, 2), FindNounAndVerb(19690720) ]));
  finally
    State.Free;
    FInitialState.Free;
  end;
end;


function TTask_AoC.FindNounAndVerb(const ExpectedResult: Integer): Integer;
var
  I, J: Integer;
begin
  Result := -1;
  for I := 0 to 99 do
    for J := 0 to 99 do
      with FInitialState.Clone do
        try
          if Execute(I, J) = ExpectedResult then
            Exit(I * 100 + J);
        finally
          Free;
        end;
end;

procedure TTask_AoC.LoadProgram;
var
  A: TArray<String>;
  I: Integer;
begin
  with Input do
    try
      A := Text.Trim.Split([',']);
    finally
      Free;
    end;

  FInitialState := TIntCode.Create;
  for I := 0 to Length(A) - 1 do
    FInitialState.Add(A[I].ToInteger);
end;

initialization
  GTask := TTask_AoC.Create(2019, 2, '1202 Program Alarm');

finalization
  GTask.Free;

end.
