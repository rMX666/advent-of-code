unit uTask_2018_11;

interface

uses
  System.Types, System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FRackSerial: Integer;
    FPowerLevels: array [1..300, 1..300] of Integer;
    function GetPowerLevel(const X, Y: Integer): Integer;
    function Max3x3Region: TPoint;
    function MaxRegion(out Size: Integer): TPoint;
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
var
  Part1, Part2: TPoint;
  Part2Size: Integer;
begin
  with Input do
    try
      FRackSerial := Text.Trim.ToInteger;
    finally
      Free;
    end;

  FillChar(FPowerLevels, SizeOf(FPowerLevels), 0);
  Part1 := Max3x3Region;
  Part2 := MaxRegion(Part2Size);

  OK(Format('Part 1: %d,%d, Part 2: %d,%d,%d', [ Part1.X, Part1.Y, Part2.X, Part2.Y, Part2Size ]));
end;

function TTask_AoC.GetPowerLevel(const X, Y: Integer): Integer;
begin
  if FPowerLevels[X, Y] <> 0 then
    Exit(FPowerLevels[X, Y]);

  Result := (((X + 10) * Y + FRackSerial) * (X + 10) div 100 mod 10) - 5;
  FPowerLevels[X, Y] := Result;
end;

function TTask_AoC.Max3x3Region: TPoint;
const
  Directions: array [1..9] of TPoint =
    (
      ( X: 0 ; Y: 0 ),
      ( X: 0 ; Y: 1 ),
      ( X: 0 ; Y: 2 ),
      ( X: 1 ; Y: 0 ),
      ( X: 1 ; Y: 1 ),
      ( X: 1 ; Y: 2 ),
      ( X: 2 ; Y: 0 ),
      ( X: 2 ; Y: 1 ),
      ( X: 2 ; Y: 2 )
    );

  function GetRegionPowerLevel(P: TPoint): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 1 to 9 do
      begin
        P := P + Directions[I];
        Inc(Result, GetPowerLevel(P.X, P.Y));
      end;
  end;

var
  PowerLevel, MaxPowerLevel, X, Y: Integer;
begin
  MaxPowerLevel := 0;

  for X := 1 to 298 do
    for Y := 1 to 298 do
      begin
        PowerLevel := GetRegionPowerLevel(TPoint.Create(X, Y));
        if MaxPowerLevel < PowerLevel then
          begin
            MaxPowerLevel := PowerLevel;
            Result := TPoint.Create(X, Y);
          end;
      end;
end;

function TTask_AoC.MaxRegion(out Size: Integer): TPoint;

  function GetRegionPowerLevel(const X, Y, Size: Integer): Integer;
  var
    I, J: Integer;
  begin
    Result := 0;
    for I := 0 to Size - 1 do
      for J := 0 to Size - 1 do
        Inc(Result, FPowerLevels[X + I, Y + J]);
  end;

var
  PowerLevel, MaxPowerLevel, X, Y, S: Integer;
begin
  MaxPowerLevel := 0;

  for X := 1 to 300 do
    for Y := 1 to 300 do
      for S := 1 to Min(301 - X, 301 - Y) do
        begin
          PowerLevel := GetRegionPowerLevel(X, Y, S);
          if MaxPowerLevel < PowerLevel then
            begin
              MaxPowerLevel := PowerLevel;
              Result := TPoint.Create(X, Y);
              Size := S;
            end;
        end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 11, 'Chronal Charge');

finalization
  GTask.Free;

end.
