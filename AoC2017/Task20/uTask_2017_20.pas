unit uTask_2017_20;

interface

uses
  System.Generics.Collections, uTask;

type
  TPoint3D = record
    X, Y, Z: Integer;
    constructor Create(const AX, AY, AZ: Integer);
    class operator Add(const P1, P2: TPoint3D): TPoint3D;
    class operator Subtract(const P1, P2: TPoint3D): TPoint3D;
    class operator Multiply(const P: TPoint3D; const T: Integer): TPoint3D; overload;
    class operator Multiply(const P1, P2: TPoint3D): TPoint3D; overload;
    class operator Divide(const P: TPoint3D; const T: Integer): TPoint3D;
  end;

  TParticle = record
    P, V, A: TPoint3D;
    constructor Create(const S: String); overload;
    constructor Create(const P, V, A: TPoint3D); overload;
    function Step(const T: Integer): TParticle;
    function DistanceFromZero: Integer;
    function CollidesWith(const Prt: TParticle): Boolean;
  end;

  TParticles = TList<TParticle>;

  TTask_AoC = class (TTask)
  private
    FParticles: TParticles;
    procedure LoadParticles;
    function FindClosestToZero: Integer;
    function CoundUncollided: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.RegularExpressions;

var
  GTask: TTask_AoC;

{ TPoint3D }

class operator TPoint3D.Add(const P1, P2: TPoint3D): TPoint3D;
begin
  Result.X := P1.X + P2.X;
  Result.Y := P1.Y + P2.Y;
  Result.Z := P1.Z + P2.Z;
end;

constructor TPoint3D.Create(const AX, AY, AZ: Integer);
begin
  X := AX;
  Y := AY;
  Z := AZ;
end;

class operator TPoint3D.Divide(const P: TPoint3D; const T: Integer): TPoint3D;
begin
  Result.X := P.X div T;
  Result.Y := P.Y div T;
  Result.Z := P.Z div T;
end;

class operator TPoint3D.Multiply(const P1, P2: TPoint3D): TPoint3D;
begin
  Result.X := P1.X * P2.X;
  Result.Y := P1.Y * P2.Y;
  Result.Z := P1.Z * P2.Z;
end;

class operator TPoint3D.Subtract(const P1, P2: TPoint3D): TPoint3D;
begin
  Result.X := P1.X - P2.X;
  Result.Y := P1.Y - P2.Y;
  Result.Z := P1.Z - P2.Z;
end;

class operator TPoint3D.Multiply(const P: TPoint3D; const T: Integer): TPoint3D;
begin
  Result.X := P.X * T;
  Result.Y := P.Y * T;
  Result.Z := P.Z * T;
end;

{ TParticle }

constructor TParticle.Create(const S: String);
begin
  with TRegEx.Match(S, '^p=<([0-9-]+),([0-9-]+),([0-9-]+)>, v=<([0-9-]+),([0-9-]+),([0-9-]+)>, a=<([0-9-]+),([0-9-]+),([0-9-]+)>$') do
    begin
      P := TPoint3D.Create(Groups[1].Value.ToInteger, Groups[2].Value.ToInteger, Groups[3].Value.ToInteger);
      V := TPoint3D.Create(Groups[4].Value.ToInteger, Groups[5].Value.ToInteger, Groups[6].Value.ToInteger);
      A := TPoint3D.Create(Groups[7].Value.ToInteger, Groups[8].Value.ToInteger, Groups[9].Value.ToInteger);
    end;
end;

function TParticle.CollidesWith(const Prt: TParticle): Boolean;

  // Just solve the Quadratic equation
  function HasRoots(const Px, Vx, Ax: Integer): Boolean;

    // We need positive integer value
    function IsOK(const X: Real): Boolean;
    begin
      Result := (X >= 0) and (Ceil(X) = Floor(X));
    end;

  var
    D, A, B, C: Integer;
    X1, X2, X3: Real;
  begin
    A := Ax;
    B := 2*Vx + Ax;
    C := 2*Px;
    D := B*B - 4*A*C;

    if (A <> 0) and (D >= 0) then
      begin
        X1 := (-B + Sqrt(D)) / (2*A);
        X2 := (-B - Sqrt(D)) / (2*A);
        Result := IsOK(X1) or IsOK(X2);
      end
    else if B <> 0 then
      begin
        X3 := -C / B;
        Result := IsOK(X3);
      end
    else
      Result := C = 0;
  end;

var
  X: TParticle;
begin
  X := TParticle.Create(P - Prt.P, V - Prt.V, A - Prt.A);

  Result := HasRoots(X.P.X, X.V.X, X.A.X)
        and HasRoots(X.P.Y, X.V.Y, X.A.Y)
        and HasRoots(X.P.Z, X.V.Z, X.A.Z);
end;

constructor TParticle.Create(const P, V, A: TPoint3D);
begin
  Self.P := P;
  Self.V := V;
  Self.A := A;
end;

function TParticle.DistanceFromZero: Integer;
begin
  Result := Abs(P.X) + Abs(P.Y) + Abs(P.Z);
end;

function TParticle.Step(const T: Integer): TParticle;
begin
  Result := TParticle.Create(P + V * T + A * T * T / 2, V + A * T, A);
end;

{ TTask_AoC }

function TTask_AoC.CoundUncollided: Integer;
var
  I, J: Integer;
begin
  Result := FParticles.Count;

  for I := 0 to FParticles.Count - 1 do
    for J := 0 to FParticles.Count - 1 do
      if (I <> J) and FParticles[I].CollidesWith(FParticles[J]) then
        begin
          Dec(Result);
          Break;
        end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    LoadParticles;

    OK(Format('Part 1: %d, Part 2: %d', [ FindClosestToZero, CoundUncollided ]));
  finally
    FParticles.Free;
  end;
end;

function TTask_AoC.FindClosestToZero: Integer;
var
  N, I, Dst, MinDst: Integer;
begin
  // In 1000 iterations all particles will fly far enough...
  N := 1000;

  // ...and then we just find the closest one
  MinDst := FParticles[0].Step(N).DistanceFromZero;
  Result := 0;
  for I := 1 to FParticles.Count - 1 do
    begin
      Dst := FParticles[I].Step(N).DistanceFromZero;
      if MinDst > Dst then
        begin
          MinDst := Dst;
          Result := I;
        end;
    end;
end;

procedure TTask_AoC.LoadParticles;
var
  I: Integer;
begin
  FParticles := TParticles.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FParticles.Add(TParticle.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 20, 'Particle Swarm');

finalization
  GTask.Free;

end.
