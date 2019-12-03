unit uTask_2017_21;

interface

uses
  uTask, uForm_2017_21;

type
  TTask_AoC = class (TTask)
  private
    FGrid: TGrid;
    procedure LoadReplacements;
    function Iterate(const N: Integer): Integer;
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
    FGrid := TGrid.Create('.#./..#/###');
    LoadReplacements;

    fForm_2017_21 := TfForm_2017_21.Create(nil);
    fForm_2017_21.Show;
    OK('Part 1: %d, Part 2: %d', [ Iterate(5), Iterate(18 - 5) ]);
  finally
    FGrid.Free;
    fForm_2017_21.Free;
  end;
end;


function TTask_AoC.Iterate(const N: Integer): Integer;
var
  I, J, DotSize: Integer;
begin
  Result := 0;

  if N < 10 then
    DotSize := 4
  else
    DotSize := 1;

  fForm_2017_21.DrawGrid(FGrid);
  for I := 1 to N do
    begin
      FGrid.Step;
      fForm_2017_21.DrawGrid(FGrid, DotSize);
    end;

  for I := 0 to FGrid.Size - 1 do
    for J := 0 to FGrid.Size - 1 do
      if FGrid[I, J] = '#' then
        Inc(Result);
end;

procedure TTask_AoC.LoadReplacements;
var
  I: Integer;
begin
  with Input do
    try
      for I := 0 to Count - 1 do
        FGrid.AddReplacement(Strings[I]);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 21, 'Fractal Art');

finalization
  GTask.Free;

end.
