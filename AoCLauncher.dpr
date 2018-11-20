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
  uTask_2015_15 in 'AoC2015\Task15\uTask_2015_15.pas',
  uTask_2015_16 in 'AoC2015\Task16\uTask_2015_16.pas',
  uTask_2015_17 in 'AoC2015\Task17\uTask_2015_17.pas',
  uTask_2015_18 in 'AoC2015\Task18\uTask_2015_18.pas',
  uForm_2015_18 in 'AoC2015\Task18\uForm_2015_18.pas' {fMain_2015_18},
  uTask_2015_19 in 'AoC2015\Task19\uTask_2015_19.pas',
  uTask_2015_20 in 'AoC2015\Task20\uTask_2015_20.pas',
  uTask_2015_21 in 'AoC2015\Task21\uTask_2015_21.pas',
  uTask_2015_22 in 'AoC2015\Task22\uTask_2015_22.pas',
  uGame_2015_22 in 'AoC2015\Task22\uGame_2015_22.pas',
  uTask_2015_23 in 'AoC2015\Task23\uTask_2015_23.pas',
  uTask_2015_24 in 'AoC2015\Task24\uTask_2015_24.pas',
  uTask_2015_25 in 'AoC2015\Task25\uTask_2015_25.pas',
  uTask_2016_01 in 'AoC2016\Task01\uTask_2016_01.pas',
  uTask_2016_02 in 'AoC2016\Task02\uTask_2016_02.pas',
  uTask_2016_03 in 'AoC2016\Task03\uTask_2016_03.pas',
  uTask_2016_04 in 'AoC2016\Task04\uTask_2016_04.pas',
  uTask_2016_05 in 'AoC2016\Task05\uTask_2016_05.pas',
  uForm_2016_05 in 'AoC2016\Task05\uForm_2016_05.pas' {fMain_2016_05},
  uTask_2016_06 in 'AoC2016\Task06\uTask_2016_06.pas',
  uTask_2016_07 in 'AoC2016\Task07\uTask_2016_07.pas',
  uTask_2016_08 in 'AoC2016\Task08\uTask_2016_08.pas',
  uForm_2016_08 in 'AoC2016\Task08\uForm_2016_08.pas' {fMain_2016_08},
  uTask_2016_09 in 'AoC2016\Task09\uTask_2016_09.pas',
  uTask_2016_10 in 'AoC2016\Task10\uTask_2016_10.pas';

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
