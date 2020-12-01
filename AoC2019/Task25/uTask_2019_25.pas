unit uTask_2019_25;

interface

uses
  uTask, IntCode;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uForm_2019_25;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadProgram;
  try
    fForm_2019_25 := TfForm_2019_25.Create(nil);
    fForm_2019_25.SetRobot(TIntCode.Create(FInitialState));
    fForm_2019_25.ShowModal;
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
  GTask := TTask_AoC.Create(2019, 25, 'Cryostasis');

finalization
  GTask.Free;

end.
