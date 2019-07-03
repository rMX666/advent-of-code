unit uTask_2016_22;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  protected
    procedure DoRun; override;
  end;

implementation

uses
  uForm_2016_22;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  fForm_2016_22 := TfForm_2016_22.Create(nil);
  with Input do
    try
      Delete(0);
      Delete(0);
      fForm_2016_22.mmNodes.Text := Text;
    finally
      Free;
    end;
  fForm_2016_22.ShowModal;
end;


initialization
  GTask := TTask_AoC.Create(2016, 22, 'Grid Computing');

finalization
  GTask.Free;

end.
