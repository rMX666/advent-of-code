unit uTask_2019_09;

interface

uses
  uTask, IntCode;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function TestRun: Int64;
    function BoostRun: Int64;
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
  LoadProgram;
  try
    OK('Part 1: %d, Part 2: %d', [ TestRun, BoostRun ]);
  finally
    FInitialState.Free;
  end;
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

function TTask_AoC.TestRun: Int64;
var
  S: String;
  I: Integer;
begin
  Result := 0;

  with FInitialState.Clone do
    try
      AddInput(1);

      if Execute = erHalt then
        begin
          if Output.Count = 1 then
            Result := Output[0]
          else
            begin
              S := 'Wrong output count:'#13#10;
              for I := 0 to Output.Count - 1 do
                S := Format('%s%d - %d'#13#10, [ S, I, Output[I] ]);
              raise Exception.Create(S);
            end;
        end;
    finally
      Free;
    end;
end;

function TTask_AoC.BoostRun: Int64;
begin
  Result := 0;

  with FInitialState.Clone do
    try
      AddInput(2);

      if Execute = erHalt then
        Result := Output[0];
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 9, 'Sensor Boost');

finalization
  GTask.Free;

end.
