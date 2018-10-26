program AoCLauncher;

uses
  Vcl.Forms,
  uTask in 'uTask.pas',
  uMain in 'uMain.pas' {fMain},
  uTask_2015_01 in 'AoC2015\Task01\uTask_2015_01.pas',
  uTask_2015_02 in 'AoC2015\Task02\uTask_2015_02.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
