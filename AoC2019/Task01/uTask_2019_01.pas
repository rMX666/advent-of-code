unit uTask_2019_01;

interface

uses
  uTask, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FMasses: TList<Integer>;
    procedure LoadMasses;
    function GetFuelSum: Integer;
    function GetFuelWithFuelSum: Integer;
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
    LoadMasses;
    OK('Part 1: %d, Part 2: %d', [ GetFuelSum, GetFuelWithFuelSum ]);
  finally
    FMasses.Free;
  end;
end;


function TTask_AoC.GetFuelSum: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FMasses.Count - 1 do
    Inc(Result, FMasses[I] div 3 - 2);
end;

function TTask_AoC.GetFuelWithFuelSum: Integer;

  function CalcFuelSum(const Mass, Sum: Integer): Integer;
  var
    FuelMass: Integer;
  begin
    FuelMass := Mass div 3 - 2;
    if FuelMass <= 0 then
      Exit(Sum);

    Result := CalcFuelSum(FuelMass, Sum + FuelMass);
  end;

var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FMasses.Count - 1 do
    Inc(Result, CalcFuelSum(FMasses[I], 0));
end;

procedure TTask_AoC.LoadMasses;
var
  I: Integer;
begin
  FMasses := TList<Integer>.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FMasses.Add(Strings[I].ToInteger);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 1, 'The Tyranny of the Rocket Equation');

finalization
  GTask.Free;

end.
