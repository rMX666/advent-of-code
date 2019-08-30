unit uTask_2018_25;

interface

uses
  System.Generics.Collections, uTask;

type
  TStar = record
    A, B, C, D: Integer;
    constructor Create(const S: String);
    class operator Equal(const Left, Right: TStar): Boolean;
    class operator Subtract(const Left, Right: TStar): TStar;
    function Manhattan: Integer;
  end;

  TConstellation = class(TList<TStar>)
  private const
    DIST = 3;
  public
    function TryAddStar(const Star: TStar): Boolean;
  end;

  TTask_AoC = class (TTask)
  private
    FStars: TConstellation;
    FConstellations: TObjectList<TConstellation>;
    procedure LoadStars;
    function ConstellationCount: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TStar }

constructor TStar.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Split([',']);
  Self.A := A[0].ToInteger;
  Self.B := A[1].ToInteger;
  Self.C := A[2].ToInteger;
  Self.D := A[3].ToInteger;
end;

class operator TStar.Equal(const Left, Right: TStar): Boolean;
begin
  Result := (Left.A = Right.A)
        and (Left.B = Right.B)
        and (Left.C = Right.C)
        and (Left.D = Right.D);
end;

function TStar.Manhattan: Integer;
begin
  Result := Abs(A) + Abs(B) + Abs(C) + Abs(D);
end;

class operator TStar.Subtract(const Left, Right: TStar): TStar;
begin
  Result.A := Left.A - Right.A;
  Result.B := Left.B - Right.B;
  Result.C := Left.C - Right.C;
  Result.D := Left.D - Right.D;
end;

{ TConstellation }

function TConstellation.TryAddStar(const Star: TStar): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if (Star - Items[I]).Manhattan <= DIST then
      begin
        Add(Star);
        Exit(True);
      end;
end;

{ TTask_AoC }

function TTask_AoC.ConstellationCount: Integer;
var
  Constellation: TConstellation;
  I: Integer;
  Added: Boolean;
begin
  while FStars.Count > 0 do
    begin
      Constellation := TConstellation.Create;
      // Take first star in list as an initialization for constellation
      Constellation.Add(FStars.First);
      FStars.Delete(0);

      repeat
        Added := False;
        // Walk through the list of stars to find matching to constellation
        for I := 0 to FStars.Count - 1 do
          if Constellation.TryAddStar(FStars[I]) then
            begin
              // If matched, take the star and walk the list from the very beginning
              // as new star can connect others.
              // We could've try to merge the constallations later, but I don't want.
              Added := True;
              FStars.Delete(I);
              Break;
            end;
      until not Added;

      // Added all we could, add constellation to list, and find another one
      FConstellations.Add(Constellation);
    end;
  Result := FConstellations.Count;
end;

procedure TTask_AoC.DoRun;
begin
  try
    FConstellations := TObjectList<TConstellation>.Create;
    LoadStars;
    OK(Format('Part 1: %d', [ ConstellationCount ]));
  finally
    FStars.Free;
    FConstellations.Free;
  end;
end;

procedure TTask_AoC.LoadStars;
var
  I: Integer;
begin
  FStars := TConstellation.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FStars.Add(TStar.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 25, 'Four-Dimensional Adventure');

finalization
  GTask.Free;

end.
