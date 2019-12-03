unit uTask_2017_11;

interface

uses
  System.Generics.Collections, System.Types, uTask;

type
  TDirections = TList<TPoint>;

  TTask_AoC = class (TTask)
  private
    FDirections: TDirections;
    procedure LoadDirections;
    function GetDistance(const P: TPoint): Integer;
    procedure FindDistances(out EndDist, FurtherDist: Integer);
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
  Part1, Part2: Integer;
begin
  FDirections := TDirections.Create;
  try
    LoadDirections;
    FindDistances(Part1, Part2);
    OK('Part 1: %d, Part 2: %d', [ Part1, Part2 ]);
  finally
    FDirections.Free;
  end;
end;

procedure TTask_AoC.FindDistances(out EndDist, FurtherDist: Integer);
var
  I: Integer;
  P: TPoint;
begin
  P := TPoint.Zero;
  FurtherDist := 0;
  for I := 0 to FDirections.Count - 1 do
    begin
      P := P + FDirections[I];
      EndDist := GetDistance(P);
      if FurtherDist < EndDist then
        FurtherDist := EndDist;
    end;
end;

function TTask_AoC.GetDistance(const P: TPoint): Integer;
begin
  Result := Abs(Abs(P.X) - Abs(P.Y)) div 2 + Abs(P.Y);
end;

procedure TTask_AoC.LoadDirections;
var
  I: Integer;
  A: TArray<String>;
  Dir: TDictionary<String,TPoint>;
begin
  Dir := TDictionary<String,TPoint>.Create;
  Dir.Add('n',  TPoint.Create( 2,  0));
  Dir.Add('nw', TPoint.Create( 1, -1));
  Dir.Add('ne', TPoint.Create( 1,  1));
  Dir.Add('s',  TPoint.Create(-2,  0));
  Dir.Add('sw', TPoint.Create(-1, -1));
  Dir.Add('se', TPoint.Create(-1,  1));

  with Input do
    try
      A := Text.Trim.Split([',']);
      for I := 0 to Length(A) - 1 do
        FDirections.Add(Dir[A[I]]);
    finally
      Free;
      Dir.Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 11, 'Hex Ed');

finalization
  GTask.Free;

end.
