unit uTask_2016_24;

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
  uMain_2016_24;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  fMain_2016_24 := TfMain_2016_24.Create(nil);
  fMain_2016_24.ShowModal;
end;


initialization
  GTask := TTask_AoC.Create(2016, 24, 'Air Duct Spelunking');

finalization
  GTask.Free;

end.
