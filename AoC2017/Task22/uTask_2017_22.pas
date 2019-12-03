unit uTask_2017_22;

interface

uses
  uTask, uForm_2017_22;

type
  TTask_AoC = class (TTask)
  private
    procedure InitializeCarrier(Carrier: TCarrier);
    function CountInfections(const N: Integer; const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Types;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.CountInfections(const N, Part: Integer): Integer;
var
  I: Integer;
  Carrier: TCarrier;
begin
  Carrier := TCarrier.Create(Part);
  try
    InitializeCarrier(Carrier);

    for I := 1 to N do
      begin
        Carrier.Step;
        fForm_2017_22.DrawMap(Carrier, I mod (N div 100) = 1);
      end;
    fForm_2017_22.DrawMap(Carrier, True);

    Result := Carrier.Infected;
  finally
    Carrier.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  fForm_2017_22 := TfForm_2017_22.Create(nil);
  fForm_2017_22.Show;
  OK('Part 1: %d, Part 2: %d', [ CountInfections(10000, 1), CountInfections(10000000, 2) ]);
end;

procedure TTask_AoC.InitializeCarrier(Carrier: TCarrier);
var
  I, J: Integer;
begin
  with Input do
    try
      Carrier.Position := TPoint.Create(Count div 2, Count div 2);
      for I := 0 to Count - 1 do
        for J := 1 to Strings[I].Length do
          if Strings[I][J] = '#' then
            Carrier.Map.Add(TPoint.Create(J - 1, I), nsInfected);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 22, 'Sporifica Virus');

finalization
  GTask.Free;

end.
