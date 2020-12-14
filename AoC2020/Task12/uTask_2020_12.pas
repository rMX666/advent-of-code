unit uTask_2020_12;

interface

uses
  System.Classes, System.Types, uTask;

type
  TDirection = (dNorth, dEast, dSouth, dWest);
  TShip = record
    Pos: TPoint;
    Dir: TDirection;
  end;

  TShipWaypoint = record
    Ship, Waypoint: TPoint;
  end;

  TTask_AoC = class (TTask)
  private
    FInstructions: TStrings;
    function ProcessInstruction1(const Ship: TShip; const Inst: String): TShip;
    function ProcessInstruction2(const Ship: TShipWaypoint; const Inst: String): TShipWaypoint;
    function GetDistanceToFinish1: Integer;
    function GetDistanceToFinish2: Integer;
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
    FInstructions := Input;
    Ok('Part 1: %d, Part 2: %d', [ GetDistanceToFinish1, GetDistanceToFinish2 ]);
  finally
    FInstructions.Free;
  end;
end;

function TTask_AoC.GetDistanceToFinish1: Integer;
var
  I: Integer;
  Ship: TShip;
begin
  Ship.Pos := TPoint.Zero;
  Ship.Dir := dEast;
  for I := 0 to FInstructions.Count - 1 do
    Ship := ProcessInstruction1(Ship, FInstructions[I]);

  with Ship.Pos do
    Result := Abs(X) + Abs(Y);
end;

function TTask_AoC.GetDistanceToFinish2: Integer;
var
  I: Integer;
  Ship: TShipWaypoint;
begin
  Ship.Ship := TPoint.Zero;
  Ship.Waypoint := TPoint.Create(10, -1);

  for I := 0 to FInstructions.Count - 1 do
    Ship := ProcessInstruction2(Ship, FInstructions[I]);

  with Ship.Ship do
    Result := Abs(X) + Abs(Y);
end;

function TTask_AoC.ProcessInstruction1(const Ship: TShip; const Inst: String): TShip;

  function TurnRight(const Dir: TDirection; const Value: Integer): TDirection;
  begin
    Result := TDirection((Integer(Dir) + Value div 90) mod 4);
  end;

var
  V: Integer;
begin
  V := Inst.Substring(1).ToInteger;
  Result := Ship;

  case Inst[1] of
    'N': Dec(Result.Pos.Y, V);
    'S': Inc(Result.Pos.Y, V);
    'W': Dec(Result.Pos.X, V);
    'E': Inc(Result.Pos.X, V);
    'L': Result.Dir := TurnRight(Ship.Dir, 360 - V);
    'R': Result.Dir := TurnRight(Ship.Dir, V);
    'F':
      case Ship.Dir of
        dNorth: Dec(Result.Pos.Y, V);
        dSouth: Inc(Result.Pos.Y, V);
        dWest:  Dec(Result.Pos.X, V);
        dEast:  Inc(Result.Pos.X, V);
      end;
  end;
end;

function TTask_AoC.ProcessInstruction2(const Ship: TShipWaypoint; const Inst: String): TShipWaypoint;

  function TurnRight(const Waypoint: TPoint; const Value: Integer): TPoint;
  begin
    case Value of
      90:
        begin
          Result.X := -Waypoint.Y;
          Result.Y := Waypoint.X;
        end;
      180:
        begin
          Result.X := -Waypoint.X;
          Result.Y := -Waypoint.Y;
        end;
      270:
        begin
          Result.X := Waypoint.Y;
          Result.Y := -Waypoint.X;
        end;
    end;
  end;

var
  V: Integer;
begin
  V := Inst.Substring(1).ToInteger;
  Result := Ship;

  case Inst[1] of
    'N': Dec(Result.Waypoint.Y, V);
    'S': Inc(Result.Waypoint.Y, V);
    'W': Dec(Result.Waypoint.X, V);
    'E': Inc(Result.Waypoint.X, V);
    'L': Result.Waypoint := TurnRight(Ship.Waypoint, 360 - V);
    'R': Result.Waypoint := TurnRight(Ship.Waypoint, V);
    'F':
      begin
        Inc(Result.Ship.X, Ship.Waypoint.X * V);
        Inc(Result.Ship.Y, Ship.Waypoint.Y * V);
      end;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 12, 'Rain Risk');

finalization
  GTask.Free;

end.
