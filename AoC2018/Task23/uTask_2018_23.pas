unit uTask_2018_23;

interface

uses
  System.Generics.Collections, uTask;

type
  TPoint3D = record
    X, Y, Z: Integer;
    constructor Create(const Ax, Ay, Az: Integer);
    class operator Equal(const A, B: TPoint3D): Boolean;
    class operator GreaterThan(const A, B: TPoint3D): Boolean;
    class operator GreaterThanOrEqual(const A, B: TPoint3D): Boolean;
    class operator LessThan(const A, B: TPoint3D): Boolean;
    class operator LessThanOrEqual(const A, B: TPoint3D): Boolean;
    class operator Add(const A, B: TPoint3D): TPoint3D;
    class operator Subtract(const A, B: TPoint3D): TPoint3D;
    class operator Divide(const A: TPoint3D; const B: Integer): TPoint3D;
    function DistanceTo(const P: TPoint3D): Integer;
    function Abs: TPoint3D;
  end;

  TBot = record
    P: TPoint3D;
    R: Integer;
    constructor Create(const S: String); overload;
    constructor Create(const P: TPoint3D; const R: Integer); overload;
    function DistanceTo(const Bot: TBot): Integer;
    function InRange(const Bot: TBot): Boolean;
    function IntersectsBot(const Bot: TBot): Boolean;
    function Split: TArray<TBot>;
    class operator Equal(const A, B: TBot): Boolean;
  end;

  TBots = TList<TBot>;

  TTask_AoC = class (TTask)
  private
    FBots: TBots;
    procedure LoadBots;
  protected
    procedure DoRun; override;
    function StrongestBotInRange: Integer;
    function BestLocationDistance: Integer;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TPoint3D }

function TPoint3D.Abs: TPoint3D;
begin
  Result := TPoint3D.Create(System.Abs(X), System.Abs(Y), System.Abs(Z));
end;

constructor TPoint3D.Create(const Ax, Ay, Az: Integer);
begin
  X := Ax;
  Y := Ay;
  Z := Az;
end;

function TPoint3D.DistanceTo(const P: TPoint3D): Integer;
begin
  Result := System.Abs(X - P.X) + System.Abs(Y - P.Y) + System.Abs(Z - P.Z);
end;

class operator TPoint3D.Add(const A, B: TPoint3D): TPoint3D;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
  Result.Z := A.Z + B.Z;
end;

class operator TPoint3D.Subtract(const A, B: TPoint3D): TPoint3D;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
  Result.Z := A.Z - B.Z;
end;

class operator TPoint3D.Divide(const A: TPoint3D; const B: Integer): TPoint3D;
begin
  Result.X := A.X div B;
  Result.Y := A.Y div B;
  Result.Z := A.Z div B;
end;

class operator TPoint3D.Equal(const A, B: TPoint3D): Boolean;
begin
  Result := (A.X = B.X) and (A.Y = B.Y) and (A.Z = B.Z);
end;

class operator TPoint3D.GreaterThan(const A, B: TPoint3D): Boolean;
begin
  Result := (A.X > B.X) and (A.Y > B.Y) and (A.Z > B.Z);
end;

class operator TPoint3D.GreaterThanOrEqual(const A, B: TPoint3D): Boolean;
begin
  Result := (A > B) or (A = B);
end;

class operator TPoint3D.LessThan(const A, B: TPoint3D): Boolean;
begin
  Result := not (A >= B);
end;

class operator TPoint3D.LessThanOrEqual(const A, B: TPoint3D): Boolean;
begin
  Result := not (A > B);
end;

{ TBot }

constructor TBot.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Replace('pos=<', '').Replace('>', '').Replace(' r=', '').Split([',']);
  P := TPoint3D.Create(A[0].ToInteger, A[1].ToInteger, A[2].ToInteger);
  R := A[3].ToInteger;
end;

{
  We're working not with cubes, but with octahedrons.
  So we place smaller ochahedrons on cube sides.
  They would cover a bit more then needed, but more is better then less :)
}
function TBot.Split: TArray<TBot>;
var
  NewR: Integer;
begin
  SetLength(Result, 15);
  NewR  := R div 2;
  // Center
  Result[0]  := TBot.Create(TPoint3D.Create(P.X, P.Y, P.Z), NewR);
  // Center sides
  Result[1]  := TBot.Create(TPoint3D.Create(P.X - NewR, P.Y, P.Z), NewR);
  Result[2]  := TBot.Create(TPoint3D.Create(P.X + NewR, P.Y, P.Z), NewR);
  Result[3]  := TBot.Create(TPoint3D.Create(P.X, P.Y - NewR, P.Z), NewR);
  Result[4]  := TBot.Create(TPoint3D.Create(P.X, P.Y + NewR, P.Z), NewR);
  Result[5]  := TBot.Create(TPoint3D.Create(P.X, P.Y, P.Z - NewR), NewR);
  Result[6]  := TBot.Create(TPoint3D.Create(P.X, P.Y, P.Z + NewR), NewR);
  // Corners
  Result[7]  := TBot.Create(TPoint3D.Create(P.X - NewR, P.Y - NewR, P.Z - NewR), NewR);
  Result[8]  := TBot.Create(TPoint3D.Create(P.X + NewR, P.Y - NewR, P.Z - NewR), NewR);
  Result[9]  := TBot.Create(TPoint3D.Create(P.X - NewR, P.Y + NewR, P.Z - NewR), NewR);
  Result[10] := TBot.Create(TPoint3D.Create(P.X + NewR, P.Y + NewR, P.Z - NewR), NewR);
  Result[11] := TBot.Create(TPoint3D.Create(P.X - NewR, P.Y - NewR, P.Z + NewR), NewR);
  Result[12] := TBot.Create(TPoint3D.Create(P.X + NewR, P.Y - NewR, P.Z + NewR), NewR);
  Result[13] := TBot.Create(TPoint3D.Create(P.X - NewR, P.Y + NewR, P.Z + NewR), NewR);
  Result[14] := TBot.Create(TPoint3D.Create(P.X + NewR, P.Y + NewR, P.Z + NewR), NewR);
end;

constructor TBot.Create(const P: TPoint3D; const R: Integer);
begin
  Self.P := P;
  Self.R := R;
end;

function TBot.DistanceTo(const Bot: TBot): Integer;
begin
  Result := P.DistanceTo(Bot.P);
end;

class operator TBot.Equal(const A, B: TBot): Boolean;
begin
  Result := (A.P = B.P) and (A.R = B.R);
end;

function TBot.InRange(const Bot: TBot): Boolean;
begin
  Result := R >= DistanceTo(Bot);
end;

function TBot.IntersectsBot(const Bot: TBot): Boolean;
begin
  Result := P.DistanceTo(Bot.P) <= R + Bot.R - 1; // -1 to compensate own position when we come to R = 1
end;

{ TTask_AoC }

function TTask_AoC.BestLocationDistance: Integer;

  function IntersectionCount(const Bot: TBot): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to FBots.Count - 1 do
      if FBots[I].IntersectsBot(Bot) then
        Inc(Result);
  end;

  // Binary search by splitting octahedrons
  function BestBotLocation(const Bot: TBot): Integer;
  var
    Bots: TArray<TBot>;
    BestCnt, BestI, Cnt, I: Integer;
  begin
    Bots := Bot.Split;

    // Find the octahedron with the most intersections
    BestCnt := 0;
    BestI := -1;
    for I := 0 to Length(Bots) - 1 do
      begin
        Cnt := IntersectionCount(Bots[I]);
        if BestCnt < Cnt then
          begin
            BestCnt := Cnt;
            BestI := I;
          end;
      end;

    if BestI = -1 then
      raise Exception.Create('No intersections!');

    // No more splits available, here we got an answer
    if Bots[BestI].R = 1 then
      Exit(Bots[BestI].P.DistanceTo(TPoint3D.Create(0, 0, 0)));

    Result := BestBotLocation(Bots[BestI]);
  end;

var
  BoxSize: Integer;
  I, MaxD: Integer;
begin
  // Make an octahedron to cover all bots
  MaxD := 0;
  for I := 0 to FBots.Count - 1 do
    with FBots[I].P do
      begin
        if MaxD < System.Abs(X) then MaxD := System.Abs(X);
        if MaxD < System.Abs(Y) then MaxD := System.Abs(Y);
        if MaxD < System.Abs(Z) then MaxD := System.Abs(Z);
      end;
  BoxSize := 1;
  while BoxSize < MaxD do
    BoxSize := BoxSize * 2;

  Result := BestBotLocation(TBot.Create(TPoint3D.Create(0, 0, 0), BoxSize));
end;

procedure TTask_AoC.DoRun;
begin
  LoadBots;

  try
    OK(Format('Part 1: %d, Part2: %d', [ StrongestBotInRange, BestLocationDistance ]));
  finally
    FBots.Free;
  end;
end;

procedure TTask_AoC.LoadBots;
var
  I: Integer;
begin
  FBots := TBots.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FBots.Add(TBot.Create(Strings[I]));
    finally
      Free;
    end;
end;

function TTask_AoC.StrongestBotInRange: Integer;
var
  BestR: Integer;
  I, BestI: Integer;
begin
  BestR := 0;
  BestI := -1;

  for I := 0 to FBots.Count - 1 do
    if BestR < FBots[I].R then
      begin
        BestR := FBots[I].R;
        BestI := I;
      end;

  Result := 0;
  for I := 0 to FBots.Count - 1 do
    if FBots[BestI].InRange(FBots[I]) then
      Inc(Result);
end;

initialization
  GTask := TTask_AoC.Create(2018, 23, 'Experimental Emergency Teleportation');

finalization
  GTask.Free;

end.
