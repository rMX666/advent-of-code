unit uTask_2019_05;

interface

uses
  uTask, IntCode, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function GetDiagnosticCode(const InputID: Integer): Integer;
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
    OK('Part 1: %d, Part 2: %d', [ GetDiagnosticCode(1), GetDiagnosticCode(5) ]);
  finally
    FInitialState.Free;
  end;
end;


function TTask_AoC.GetDiagnosticCode(const InputID: Integer): Integer;
var
  I: Integer;
begin
  with FInitialState.Clone do
    try
      AddInput(InputID);
      Execute;

      for I := 0 to Output.Count - 2 do
        if Output[I] <> 0 then
          raise Exception.CreateFmt('The output %d failed with %d', [ I, Output[I] ]);

      Result := Output[Output.Count - 1];
    finally
      Free;
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

initialization
  GTask := TTask_AoC.Create(2019, 5, 'Sunny with a Chance of Asteroids');

finalization
  GTask.Free;

end.
