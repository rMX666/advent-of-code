program AoCLauncher;

uses
  Vcl.Forms,
  uTask in 'uTask.pas',
  uMain in 'uMain.pas' {fMain},
  uTask_2015_01 in 'AoC2015\Task01\uTask_2015_01.pas',
  uTask_2015_02 in 'AoC2015\Task02\uTask_2015_02.pas',
  uTask_2015_03 in 'AoC2015\Task03\uTask_2015_03.pas',
  uTask_2015_04 in 'AoC2015\Task04\uTask_2015_04.pas',
  uTask_2015_05 in 'AoC2015\Task05\uTask_2015_05.pas',
  uTask_2015_06 in 'AoC2015\Task06\uTask_2015_06.pas',
  uTask_2015_07 in 'AoC2015\Task07\uTask_2015_07.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
