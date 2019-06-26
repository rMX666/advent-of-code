unit uTask_Tpl;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    //
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
  try

  finally

  end;
end;


initialization
  GTask := TTask_AoC.Create(0, 0, '');

finalization
  GTask.Free;

end.
