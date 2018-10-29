program AoCLauncher;

uses
  Vcl.Forms,
  uTask in 'uTask.pas',
  uUtil in 'uUtil.pas',
  uMain in 'uMain.pas' {fMain},
  uTask_2015_01 in 'AoC2015\Task01\uTask_2015_01.pas',
  uTask_2015_02 in 'AoC2015\Task02\uTask_2015_02.pas',
  uTask_2015_03 in 'AoC2015\Task03\uTask_2015_03.pas',
  uTask_2015_04 in 'AoC2015\Task04\uTask_2015_04.pas',
  uTask_2015_05 in 'AoC2015\Task05\uTask_2015_05.pas',
  uTask_2015_06 in 'AoC2015\Task06\uTask_2015_06.pas',
  uTask_2015_07 in 'AoC2015\Task07\uTask_2015_07.pas',
  uTask_2015_08 in 'AoC2015\Task08\uTask_2015_08.pas',
  uTask_2015_09 in 'AoC2015\Task09\uTask_2015_09.pas',
  uForm_2015_09 in 'AoC2015\Task09\uForm_2015_09.pas' {fForm_2015_09},
  uTask_2015_10 in 'AoC2015\Task10\uTask_2015_10.pas',
  uTask_2015_11 in 'AoC2015\Task11\uTask_2015_11.pas',
  uTask_2015_12 in 'AoC2015\Task12\uTask_2015_12.pas',
  uForm_2015_12 in 'AoC2015\Task12\uForm_2015_12.pas' {fMain_2015_12},
  uJSON_2015_12 in 'AoC2015\Task12\uJSON_2015_12.pas',
  uTask_2015_13 in 'AoC2015\Task13\uTask_2015_13.pas',
  uTask_2015_14 in 'AoC2015\Task14\uTask_2015_14.pas',
  uTask_2015_15 in 'AoC2015\Task15\uTask_2015_15.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
