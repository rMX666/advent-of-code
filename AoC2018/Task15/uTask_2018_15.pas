unit uTask_2018_15;

interface

uses
  System.Types, System.Generics.Collections, uTask;

type
  TUnitType = ( utElf, utGoblin );

  TUnit = record
    UnitType: TUnitType;
    P: TPoint;
    HP, Power: Integer;
    constructor Create(const AUnitType: TUnitType; const X, Y, AHP, APower: Integer);
  end;

  TMap = TDictionary<TPoint,Boolean>;

  TTask_AoC = class (TTask)
  private
    FMap: TMap;
    procedure LoadMap;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TUnit }

constructor TUnit.Create(const AUnitType: TUnitType; const X, Y, AHP, APower: Integer);
begin
  UnitType := AUnitType;
  P := TPoint.Create(X, Y);
  HP := AHP;
  Power := APower;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadMap;
  finally
    FMap.Free;
  end;
end;

procedure TTask_AoC.LoadMap;
var
  X, Y: Integer;
begin
  FMap := TMap.Create;

  with Input do
    try
      for Y := 0 to Count - 1 do
        for X := 1 to Strings[Y].Length do
          FMap.Add(TPoint.Create(X - 1, Y), Strings[Y][X] <> '#');
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 15, 'Beverage Bandits');

finalization
  GTask.Free;

end.
