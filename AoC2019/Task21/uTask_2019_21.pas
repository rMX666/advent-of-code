unit uTask_2019_21;

interface

uses
  uTask, IntCode;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    procedure GetHullDamageAmount;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uForm_2019_21;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadProgram;
  try
    GetHullDamageAmount;
  finally
    FInitialState.Free;
  end;
end;

procedure TTask_AoC.GetHullDamageAmount;
begin
  fForm_2019_21 := TfForm_2019_21.Create(nil);
  fForm_2019_21.SetRobot(FInitialState);
  fForm_2019_21.ShowModal;
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
  GTask := TTask_AoC.Create(2019, 21, 'Springdroid Adventure');

finalization
  GTask.Free;

end.
