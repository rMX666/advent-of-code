unit uTask_2019_13;

interface

uses
  uTask, IntCode;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function CountBlocks: Integer;
    function RunGame: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.CountBlocks: Integer;
var
  I: Integer;
begin
  Result := 0;

  with TIntCode.Create(FInitialState) do
    try
      if Execute = erHalt then
        begin
          I := 2;
          while I < Output.Count do
            begin
              if Output[I] = 2 then
                Inc(Result);
              Inc(I, 3);
            end;
        end;
    finally
      Free;
    end;
end;

function TTask_AoC.RunGame: Integer;
var
  State: TIntCode;
begin
  Randomize;
  State := TIntCode.Create(FInitialState);
  try
    State[0] := 2;
    while State.Execute <> erHalt do
      State.AddInput(Random(3) - 1);
  finally
    State.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  LoadProgram;
  try
    OK('Part 1: %d', [ CountBlocks, RunGame ]);
  finally
    FInitialState.Free;
  end;
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TIntCode.Create(Text);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 13, 'Care Package');

finalization
  GTask.Free;

end.
