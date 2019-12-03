unit uTask_2019_03;

interface

uses
  uTask, System.Types, System.Generics.Collections;

type
  TPath = TList<TPoint>;
  TIntersections = TDictionary<TPoint,Integer>; // Cordinate + Total path length

  TTask_AoC = class (TTask)
  private
    FPath1, FPath2: TPath;
    FIntersections: TIntersections;
    procedure LoadPaths;
    function GetClosestIntersectionDistance: Integer;
    function GetBestIntersectionPathLength: Integer;
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
  FPath1 := TPath.Create;
  FPath2 := TPath.Create;
  FIntersections := TIntersections.Create;
  try
    LoadPaths;
    OK(Format('Part 1: %d, Part 2: %d', [ GetClosestIntersectionDistance, GetBestIntersectionPathLength ]));
  finally
    FPath1.Free;
    FPath2.Free;
    FIntersections.Free;
  end;
end;


function TTask_AoC.GetBestIntersectionPathLength: Integer;
var
  Value: Integer;
begin
  Result := 0;
  for Value in FIntersections.Values do
    if (Result = 0) or (Value < Result) then
      Result := Value;
end;

function TTask_AoC.GetClosestIntersectionDistance: Integer;
var
  Dist: Integer;
  Key: TPoint;
begin
  Result := 0;
  for Key in FIntersections.Keys do
    begin
      with Key do
        Dist := Abs(X) + Abs(Y);
      if (Result = 0) or (Dist < Result) then
        Result := Dist;
    end;
end;

procedure TTask_AoC.LoadPaths;

  function Dist(const P: TPoint): Integer;
  begin
    with P do
      Result := Abs(X) + Abs(Y);
  end;

  procedure TracePath(const A: TArray<String>; const PathLoad, PathCheck: TPath);
  var
    I, J, PathLength, CutLength, PathLengthC, CutLengthC: Integer;
    Current, Previous, C1, C2, Intersection: TPoint;
  begin
    Current := TPoint.Zero;
    PathLoad.Add(Current);
    PathLength := 0;

    for I := 0 to Length(A) - 1 do
      begin
        Previous := Current;
        CutLength := A[I].Substring(1).ToInteger;
        case A[I][1] of
          'U': Current := TPoint.Create(Current.X, Current.Y - CutLength);
          'D': Current := TPoint.Create(Current.X, Current.Y + CutLength);
          'L': Current := TPoint.Create(Current.X - CutLength, Current.Y);
          'R': Current := TPoint.Create(Current.X + CutLength, Current.Y);
        end;
        PathLoad.Add(Current);
        Inc(PathLength, CutLength);

        PathLengthC := 0;
        for J := 0 to PathCheck.Count - 2 do
          begin
            C1 := PathCheck[J];
            C2 := PathCheck[J + 1];
            CutLengthC := Dist(C2 - C1);
            Inc(PathLengthC, CutLengthC);

            // Parallel lines
            if ((C1.X = C2.X) and (Current.X = Previous.X)) or ((C1.Y = C2.Y) and (Current.Y = Previous.Y)) then
              Continue;

            if InRange(C1.Y, Min(Current.Y, Previous.Y), Max(Current.Y, Previous.Y)) and InRange(Current.X, Min(C1.X, C2.X), Max(C1.X, C2.X))
            or InRange(C1.X, Min(Current.X, Previous.X), Max(Current.X, Previous.X)) and InRange(Current.Y, Min(C1.Y, C2.Y), Max(C1.Y, C2.Y))
            then
              begin
                // Get intersection depending on wether the checked line is vertical or horizontal
                if C1.Y = C2.Y then
                  Intersection := TPoint.Create(Current.X, C1.Y)
                else if C1.X = C2.X then
                  Intersection := TPoint.Create(C1.X, Current.Y);

                if not FIntersections.ContainsKey(Intersection) then
                  FIntersections.Add(Intersection, PathLength - Dist(Current - Intersection) + PathLengthC - Dist(C2 - Intersection));
              end;
          end;
      end;
  end;

var
  A1, A2: TArray<String>;
begin
  with Input do
    try
      A1 := Strings[0].Trim.Split([',']);
      A2 := Strings[1].Trim.Split([',']);
    finally
      Free;
    end;

  TracePath(A1, FPath1, FPath2);
  TracePath(A2, FPath2, FPath1);
end;

initialization
  GTask := TTask_AoC.Create(2019, 3, 'Crossed Wires');

finalization
  GTask.Free;

end.
