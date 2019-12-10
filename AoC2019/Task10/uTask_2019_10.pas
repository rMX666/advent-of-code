unit uTask_2019_10;

interface

uses
  uTask, System.Types, System.Generics.Collections;

type
  TSightCache = TDictionary<TPoint,Boolean>;
  TMap = class
  private
    FCache: TObjectDictionary<TPoint,TSightCache>;
    FMap: TArray<TArray<Integer>>;
    FWidth, FHeight: Integer;
    function GetInSight(const X, Y: Integer): Integer;
    procedure SetInSight(const X, Y, Value: Integer);
    function GetIsAsteroid(const X, Y: Integer): Boolean;
    procedure SetIsAsteriod(const X, Y: Integer; const Value: Boolean);
    function GetSightCache(const X, Y: Integer): TSightCache;
    function GetIsEvaporated(const X, Y: Integer): Boolean;
    procedure SetIsEvaporated(const X, Y: Integer; const Value: Boolean);
    function CanBeSeen(const SrcX, SrcY, TgtX, TgtY: Integer): Boolean;
    function IsInCache(const P1, P2: TPoint; const Value: Boolean): Boolean;
    procedure AddToCache(const P1, P2: TPoint; const Value: Boolean);
  public
    constructor Create(const Width, Height: Integer);
    destructor Destroy; override;
    property IsAsteroid[const X, Y: Integer]: Boolean read GetIsAsteroid write SetIsAsteriod;
    property InSight[const X, Y: Integer]: Integer read GetInSight write SetInSight;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property SightCache[const X, Y: Integer]: TSightCache read GetSightCache;
    property IsEvaporated[const X, Y: Integer]: Boolean read GetIsEvaporated write SetIsEvaporated;
  end;

  TTask_AoC = class (TTask)
  private
    FMap: TMap;
    FLaserPosition: TPoint;
    procedure LoadMap;
    function GetMaxInSight: Integer;
    function FindNthVaporized(const Index: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uForm_2019_10;

var
  GTask: TTask_AoC;

{ TMap }

constructor TMap.Create(const Width, Height: Integer);
var
  I, J: Integer;
begin
  FWidth  := Width;
  FHeight := Height;

  SetLength(FMap, FWidth);
  for I := 0 to FWidth - 1 do
    begin
      SetLength(FMap[I], FHeight);
      for J := 0 to FHeight - 1 do
        FMap[I][J] := -1;
    end;

  FCache := TObjectDictionary<TPoint,TSightCache>.Create([ doOwnsValues ]);
end;

destructor TMap.Destroy;
begin
  FreeAndNil(FCache);
  inherited;
end;

procedure TMap.AddToCache(const P1, P2: TPoint; const Value: Boolean);

  procedure CheckAdd(const P1, P2: TPoint);
  begin
    if not FCache.ContainsKey(P1) then
      FCache.Add(P1, TSightCache.Create);
    if not FCache[P1].ContainsKey(P2) then
      FCache[P1].Add(P2, Value);
  end;

begin
  CheckAdd(P1, P2);
  CheckAdd(P2, P1);
end;

function TMap.IsInCache(const P1, P2: TPoint; const Value: Boolean): Boolean;
begin
  if not FCache.ContainsKey(P1) then
    Exit(False);

  if not FCache[P1].ContainsKey(P2) then
    Exit(False);

  Result := FCache[P1][P2] = Value;
end;

function TMap.CanBeSeen(const SrcX, SrcY, TgtX, TgtY: Integer): Boolean;
var
  SrcP, TgtP: TPoint;
  X, Dx, Y, Dy: Integer;
  Yr: Real;

  procedure CheckAndCache(const X, Y: Integer);
  begin
    if IsAsteroid[X, Y] then
      begin
        AddToCache(SrcP, TPoint.Create(X, Y), Result);
        Result := False;
      end;
  end;

begin
  SrcP := TPoint.Create(SrcX, SrcY);
  TgtP := TPoint.Create(TgtX, TgtY);

  // Source and target should not be the same point
  if SrcP = TgtP then
    Exit(False);

  // Cached as invisible from the given point
  if IsInCache(SrcP, TgtP, False) then
    Exit(False);

  // Cached as visible from given point
  if IsInCache(SrcP, TgtP, True) then
    Exit(True);

  // Nothing in cache => walk asteroids between two given points and cache the visibility
  Result := True;

  // If it's a vertical line then it's the special case.
  // Just walk vertically and check all asreroids by the way.
  if SrcX = TgtX then
    begin
      // Find direction of line
      Y := SrcY;
      Dy := Sign(TgtY - SrcY);
      while Y <> TgtY do
        begin
          Inc(Y, Dy);
          CheckAndCache(SrcX, Y);
        end;
    end
  else
    begin
      // Find direction of line
      X := SrcX;
      Dx := Sign(TgtX - SrcX);

      while X <> TgtX do
        begin
          Inc(X, Dx);
          // Line equation
          Yr := (X - SrcX) * (TgtY - SrcY) / (TgtX - SrcX) + SrcY;
          // If it's not an integer number, go further
          if Abs(Yr) - Floor(Abs(Yr)) > 0 then
            Continue;
          // Otherwise check if there's an asteroid in the sight
          CheckAndCache(X, Floor(Yr));
        end;
    end;
end;

function TMap.GetInSight(const X, Y: Integer): Integer;
var
  I, J: Integer;
  Value: Boolean;
begin
  if not IsAsteroid[X, Y] or (FMap[X][Y] > 0) then
    Exit(FMap[X][Y] and not (1 shl 16));

  Result := 0;
  for I := 0 to FWidth - 1 do
    for J := 0 to FHeight - 1 do
      if IsAsteroid[I, J] and CanBeSeen(X, Y, I, J) then
        Inc(Result);

  // Align result with cache
  if Result > 0 then
    begin
      Result := 0;
      with FCache[TPoint.Create(X, Y)] do
        for Value in Values do
          if Value then
            Inc(Result);
    end;

  FMap[X][Y] := Result;
end;

procedure TMap.SetInSight(const X, Y, Value: Integer);
begin
  FMap[X][Y] := Value;
end;

function TMap.GetIsAsteroid(const X, Y: Integer): Boolean;
begin
  Result := FMap[X][Y] >= 0;
end;

procedure TMap.SetIsAsteriod(const X, Y: Integer; const Value: Boolean);
begin
  if Value = IsAsteroid[X, Y] then
    Exit;

  FMap[X][Y] := Integer(Value) - 1;
end;

function TMap.GetIsEvaporated(const X, Y: Integer): Boolean;
begin
  if not IsAsteroid[X, Y] then
    Exit(False);
  Result := (FMap[X][Y] shr 16) and 1 = 1;
end;

procedure TMap.SetIsEvaporated(const X, Y: Integer; const Value: Boolean);
begin
  if IsAsteroid[X, Y] then
    case Value of
      True:
        FMap[X][Y] := FMap[X][Y] or (1 shl 16);
      False:
        FMap[X][Y] := FMap[X][Y] and not (1 shl 16);
    end;
end;

function TMap.GetSightCache(const X, Y: Integer): TSightCache;
begin
  if not IsAsteroid[X, Y] then
    Exit(nil);

  Result := FCache[TPoint.Create(X, Y)];
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadMap;
  try
    OK('Part 1: %d, Part 2: %d', [ GetMaxInSight, FindNthVaporized(200) ]);

    fForm_2019_10 := TfForm_2019_10.Create(nil);
    fForm_2019_10.DrawMap(FMap, FLaserPosition);
    fForm_2019_10.ShowModal;
  finally
    FMap.Free;
  end;
end;

function TTask_AoC.FindNthVaporized(const Index: Integer): Integer;

  function GetAngle(const P: TPoint): Real;
  var
    Dx, Dy: Integer;
  begin
    Dx := P.X - FLaserPosition.X;
    Dy := FLaserPosition.Y - P.Y;
    if Dx = 0 then
      case Sign(Dy) of
        -1: Exit(270);
         1: Exit(450);
      end;

    Result := RadToDeg(ArcTan(Abs(Dy / Dx)));
    if      (Dx > 0) and (Dy >  0) then Result := 360 + Result
    else if (Dx < 0) and (Dy >  0) then Result := 180 - Result
    else if (Dx < 0) and (Dy <= 0) then Result := 180 + Result
    else if (Dx > 0) and (Dy <= 0) then Result := 360 - Result;
  end;

  procedure BinInsert(const Value: TPoint; var A: TArray<TPoint>);
  var
    Angle: Real;
    S, E, M: Integer;
  begin
    Angle := GetAngle(Value);
    S := 0;
    M := 0;
    E := Length(A) - 1;
    while E - S > 1 do
      begin
        M := S + (E - S) div 2;
        if Angle < GetAngle(A[M]) then
          S := M
        else
          E := M;
      end;
    System.Insert(Value, A, M);
  end;

var
  P: TPoint;
  I, EvaporatedAmount: Integer;
  InSight: TArray<TPoint>;
begin
  Result := 0;
  EvaporatedAmount := 0;
  while EvaporatedAmount < Index do
    begin
      // Fill asteriods visible from the laset spot and order them by angle from 90 clockwise
      SetLength(InSight, 0);
      with FMap.SightCache[FLaserPosition.X, FLaserPosition.Y] do
        for P in Keys do
          if Items[P] then
            BinInsert(P, InSight);

      for I := 0 to Length(InSight) - 1 do
        begin
          P := InSight[I];
          FMap.IsEvaporated[P.X, P.Y] := True;
          Inc(EvaporatedAmount);
          if EvaporatedAmount >= Index then
            Exit(P.X * 100 + P.Y);
        end;
      // TODO: For the full solution we need to clear evaporated asteroids,
      //       enumerate asteroids in sight and start from the very beginning.
      //       In my case one iteration is enough.
    end;
end;

function TTask_AoC.GetMaxInSight: Integer;
var
  X, Y: Integer;
begin
  Result := 0;
  for X := 0 to FMap.Width - 1 do
    for Y := 0 to FMap.Height - 1 do
      if Result < FMap.InSight[X, Y] then
        begin
          Result := FMap.InSight[X, Y];
          FLaserPosition := TPoint.Create(X, Y);
        end;
end;

procedure TTask_AoC.LoadMap;
var
  X, Y: Integer;
begin
  with Input do
    if Count > 0 then
      try
        FMap := TMap.Create(Strings[0].Length, Count);
        for Y := 0 to Count - 1 do
          for X := 1 to Strings[Y].Length do
            FMap.IsAsteroid[X - 1, Y] := Strings[Y][X] = '#';
      finally
        Free;
      end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 10, 'Monitoring Station');

finalization
  GTask.Free;

end.
