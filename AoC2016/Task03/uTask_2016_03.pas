unit uTask_2016_03;

interface

uses
  System.Generics.Collections, uTask;

type
  TTriangle = record
    A, B, C: Integer;
    constructor Create(const S: String); overload;
    constructor Create(const A, B, C: Integer); overload;
  end;

  TTask_AoC = class (TTask)
  private
    FTriangles: TList<TTriangle>;
    function IsValid(const T: TTriangle): Boolean;
    function GetValidCount: Integer;
    function GetValidCountVert: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTriangle }

constructor TTriangle.Create(const S: String);
var
  Ar: TArray<String>;
begin
  Ar := S.Trim.Replace('  ', ' ').Replace('  ', ' ').Split([' ']);
  A := Ar[0].ToInteger;
  B := Ar[1].ToInteger;
  C := Ar[2].ToInteger;
end;

constructor TTriangle.Create(const A, B, C: Integer);
begin
  Self.A := A;
  Self.B := B;
  Self.C := C;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  I, Part1, Part2: Integer;
begin
  FTriangles := TList<TTriangle>.Create;

  try
    with Input do
      try
        for I := 0 to Count - 1 do
          FTriangles.Add(TTriangle.Create(Strings[I]));
      finally
        Free;
      end;

    Part1 := GetValidCount;
    Part2 := GetValidCountVert;
  finally
    FTriangles.Free;
  end;

  OK('Part 1: %d, Part 2: %d', [ Part1, Part2 ]);
end;

function TTask_AoC.GetValidCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FTriangles.Count - 1 do
    if IsValid(FTriangles[I]) then
      Inc(Result);
end;

function TTask_AoC.GetValidCountVert: Integer;
var
  T1, T2, T3: TTriangle;
  I: Integer;
begin
  Result := 0;
  I := 0;
  while I < FTriangles.Count do
    begin
      T1 := FTriangles[I];
      T2 := FTriangles[I + 1];
      T3 := FTriangles[I + 2];

      if IsValid(TTriangle.Create(T1.A, T2.A, T3.A)) then
        Inc(Result);
      if IsValid(TTriangle.Create(T1.B, T2.B, T3.B)) then
        Inc(Result);
      if IsValid(TTriangle.Create(T1.C, T2.C, T3.C)) then
        Inc(Result);

      Inc(I, 3);
    end;
end;

function TTask_AoC.IsValid(const T: TTriangle): Boolean;
begin
  with T do
    Result := (A + B > C) and (A + C > B) and (B + C > A);
end;

initialization
  GTask := TTask_AoC.Create(2016, 3, 'Squares With Three Sides');

finalization
  GTask.Free;

end.
