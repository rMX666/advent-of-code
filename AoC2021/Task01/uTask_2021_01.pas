unit uTask_2021_01;

interface

uses
  uTask, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FReport: TList<Integer>;
    procedure LoadReport;
    function CountIncrements(const WindowSize: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.CountIncrements(const WindowSize: Integer): Integer;

  function WindowSum(const Start: Integer): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := Start to Start + WindowSize - 1 do
      Inc(Result, FReport[I]);
  end;

var
  I, A, B: Integer;
begin
  Result := 0;
  for I := 0 to FReport.Count - WindowSize - 1 do
    begin
      A := WindowSum(I);
      B := WindowSum(I + 1);

      if A < B then
       Inc(Result);
    end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    LoadReport;
    OK('Part 1: %d, Part 2: %d', [ CountIncrements(1), CountIncrements(3) ]);
  finally
    FReport.Free;
  end;
end;


procedure TTask_AoC.LoadReport;
var
  I: Integer;
begin
  FReport := TList<Integer>.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FReport.Add(Strings[I].ToInteger);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2021, 01, 'Sonar Sweep');

finalization
  GTask.Free;

end.
