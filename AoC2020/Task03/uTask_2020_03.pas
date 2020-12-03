unit uTask_2020_03;

interface

uses
  System.Generics.Collections, System.Types, uTask;

type
  TMapItem = (miNone, miEmpty, miTree);
  TMap = class (TDictionary<TPoint,TMapItem>)
  private
    FWidth, FHeight: Integer;
  public
    constructor Create(const AWidth, AHeight: Integer);
    function ItemAtPoint(const Point: TPoint): TMapItem;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

  TTask_AoC = class (TTask)
  private
    FMap: TMap;
    procedure LoadMap;
    function CountTreesOnSlope(const Dir: TPoint): Integer;
    function CheckAllSlopes: Int64;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TMap }

constructor TMap.Create(const AWidth, AHeight: Integer);
begin
  inherited Create;
  FWidth := AWidth;
  FHeight := AHeight;
end;

function TMap.ItemAtPoint(const Point: TPoint): TMapItem;
var
  P: TPoint;
begin
  P := TPoint.Create(Point.X mod FWidth, Point.Y);
  if not TryGetValue(P, Result) then
    Result := miNone;
end;

{ TTask_AoC }

function TTask_AoC.CheckAllSlopes: Int64;
const
  SLOPES: array [0..4] of TPoint =
    (
      ( X: 1; Y: 1 )
    , ( X: 3; Y: 1 )
    , ( X: 5; Y: 1 )
    , ( X: 7; Y: 1 )
    , ( X: 1; Y: 2 )
    );
var
  I: Integer;
begin
  Result := 1;
  for I := 0 to 4 do
    Result := Result * CountTreesOnSlope(SLOPES[I]);
end;

function TTask_AoC.CountTreesOnSlope(const Dir: TPoint): Integer;
var
  Position: TPoint;
begin
  Result := 0;
  Position := TPoint.Zero;
  while Position.Y < FMap.Height do
    begin
      Position := Position + Dir;
      case FMap.ItemAtPoint(Position) of
        miNone: Break;
        miTree: Inc(Result);
      end;
    end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    LoadMap;
    Ok('Part 1: %d, Part 2: %d', [ CountTreesOnSlope(TPoint.Create(3, 1)), CheckAllSlopes ]);
  finally
    FMap.Free;
  end;
end;

procedure TTask_AoC.LoadMap;
var
  X, Y: Integer;
begin
  with Input do
    try
      FMap := TMap.Create(Strings[0].Length, Count);
      for Y := 0 to Count - 1 do
        for X := 1 to Strings[Y].Length do
          FMap.Add(TPoint.Create(X - 1, Y), TMapItem(Integer(Strings[Y][X] = '#') + 1));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 3, 'Toboggan Trajectory');

finalization
  GTask.Free;

end.
