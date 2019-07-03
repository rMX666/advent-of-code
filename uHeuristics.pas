unit uHeuristics;

interface

uses
  System.Types;

type
  THeuristicsType = ( htNone, htManhattan, htEuclidian, htChebishev, htOctile );

function Heuristic(const Dx, Dy: Integer; HeuristicsType: THeuristicsType = htManhattan): Integer; overload;
function Heuristic(const Left, Right: TPoint; HeuristicsType: THeuristicsType = htManhattan): Integer; overload;

implementation

uses
  System.Math;

const
  SQRT2 = 1.414213562373095;
  OctileF = SQRT2 - 1;

function Manhattan(const Dx, Dy: Integer): Integer;
begin
  Result := Dx + Dy;
end;

function Euclidian(const Dx, Dy: Integer): Integer;
begin
  Result := Round(Sqrt(Dx * Dx + Dy * Dy) * 1000);
end;

function Chebishev(const Dx, Dy: Integer): Integer;
begin
  Result := Max(Dx, Dy);
end;

function Octile(const Dx, Dy: Integer): Integer;
begin
  if Dx < Dy then
    Result := Round((OctileF * Dx + Dy) * 1000)
  else
    Result := Round((OctileF * Dy + Dx) * 1000)
end;

function Heuristic(const Dx, Dy: Integer; HeuristicsType: THeuristicsType): Integer;
begin
  case HeuristicsType of
    htNone:      Result := 0;
    htManhattan: Result := Manhattan(Dx, Dy);
    htEuclidian: Result := Euclidian(Dx, Dy);
    htChebishev: Result := Chebishev(Dx, Dy);
    htOctile:    Result := Octile(Dx, Dy);
  end;
end;

function Heuristic(const Left, Right: TPoint; HeuristicsType: THeuristicsType): Integer;
begin
  Result := Heuristic(Abs(Right.X - Left.X), Abs(Right.Y - Left.Y), HeuristicsType);
end;

end.
