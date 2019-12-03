unit uTask_2015_03;

interface

uses
  uTask, System.Types, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FDirections: TDictionary<Char,TPoint>;
    procedure Solve(const Part: Integer);
  protected
    procedure DoRun; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

constructor TTask_AoC.Create;
begin
  inherited;

  // Fill directions
  FDirections := TDictionary<Char,TPoint>.Create(4);
  with FDirections do
    begin
      Add('^', TPoint.Create(0, -1));
      Add('v', TPoint.Create(0, 1));
      Add('<', TPoint.Create(-1, 0));
      Add('>', TPoint.Create(1, 0));
    end;
end;

destructor TTask_AoC.Destroy;
begin
  FDirections.Free;
  inherited;
end;

procedure TTask_AoC.DoRun;
begin
  Solve(1);
  Solve(2);
end;

procedure TTask_AoC.Solve(const Part: Integer);
var
  I: Integer;
  Point: TPoint;
  Points: Array of TPoint;
  Houses: TDictionary<TPoint,Integer>;
begin
  with Input do
    try
      Houses := TDictionary<TPoint,Integer>.Create;

      try
        Houses.Add(TPoint.Zero, 2);

        SetLength(Points, Part);
        for I := 0 to Part - 1 do
          Points[I] := TPoint.Zero;

        for I := 1 to Text.Trim.Length do
          begin
            Point := Points[I mod Part] + FDirections[Text[I]];
            if Houses.ContainsKey(Point) then
              Houses[Point] := Houses[Point] + 1
            else
              Houses.Add(Point, 1);

            Points[I mod Part] := Point;
          end;

        OK('Part %d: %d', [ Part, Houses.Count ]);
      finally
        Houses.Free;
      end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 3, 'Perfectly Spherical Houses in a Vacuum');

finalization
  GTask.Free;

end.
