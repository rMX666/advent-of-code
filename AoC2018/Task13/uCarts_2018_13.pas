unit uCarts_2018_13;

interface

uses
  System.Types, System.Generics.Collections, System.Classes;

type
  TPathItem = ( piNone, piHorizontal, piVertical, piIntersection
              , piCornerUL // Up left corner
              , piCornerUR // Up right corner
              , piCornerBL // Bottom left corner
              , piCornerBR // Bottom right corner
              );
  TMap = TDictionary<TPoint,TPathItem>;

  TTurnDirection = ( tdLeft, tdStraight, tdRight );
  TCartDirection = ( cdNone, cdUp, cdDown, cdLeft, cdRight );
  TCart = class
  private
    FMap: TMap;
    FPos: TPoint;
    FDirection: TCartDirection;
    FTurnDirection: TTurnDirection;
    procedure TakeTurn;
  public
    constructor Create(const AMap: TMap; const X, Y: Integer; const ADirection: TCartDirection);
    procedure MoveCart;
    property Pos: TPoint read FPos;
  end;

  TCarts = class(TObjectList<TCart>)
  private
    FCollisions: TList<TPoint>;
    FOnStepCarts: TNotifyEvent;
    procedure DoOnStepCarts;
    function GetFirstCollision: TPoint;
  public
    constructor Create;
    destructor Destroy; override;
    function StepCarts: Boolean;
    property Collision: TPoint read GetFirstCollision;
    property Collisions: TList<TPoint> read FCollisions;
    property OnStepCarts: TNotifyEvent read FOnStepCarts write FOnStepCarts;
  end;

implementation

uses
  System.Generics.Defaults;

{ TCart }

constructor TCart.Create(const AMap: TMap; const X, Y: Integer; const ADirection: TCartDirection);
begin
  FMap := AMap;
  FPos := TPoint.Create(X, Y);
  FDirection := ADirection;
  FTurnDirection := tdLeft;
end;

procedure TCart.MoveCart;

  function CornerDir(const Value, Eq, IfEq, IfNEq: TCartDirection): TCartDirection;
  begin
    if Value = Eq then
      Result := IfEq
    else
      Result := IfNEq;
  end;

begin
  case FDirection of
    cdUp:    Dec(FPos.Y);
    cdDown:  Inc(FPos.Y);
    cdLeft:  Dec(FPos.X);
    cdRight: Inc(FPos.X);
  end;

  case FMap[FPos] of
    piIntersection:
      begin
        TakeTurn;
        FTurnDirection := TTurnDirection((Integer(FTurnDirection) + 1) mod 3);
      end;
    piCornerUL: FDirection := CornerDir(FDirection, cdUp,   cdRight, cdDown);
    piCornerUR: FDirection := CornerDir(FDirection, cdUp,   cdLeft,  cdDown);
    piCornerBL: FDirection := CornerDir(FDirection, cdDown, cdRight, cdUp);
    piCornerBR: FDirection := CornerDir(FDirection, cdDown, cdLeft,  cdUp);
    // piHorizontal, piVertical - just move
  end;
end;

procedure TCart.TakeTurn;
begin
  case FDirection of
    cdUp:
      case FTurnDirection of
        tdLeft:  FDirection := cdLeft;
        tdRight: FDirection := cdRight;
      end;
    cdDown:
      case FTurnDirection of
        tdLeft:  FDirection := cdRight;
        tdRight: FDirection := cdLeft;
      end;
    cdLeft:
      case FTurnDirection of
        tdLeft:  FDirection := cdDown;
        tdRight: FDirection := cdUp;
      end;
    cdRight:
      case FTurnDirection of
        tdLeft:  FDirection := cdUp;
        tdRight: FDirection := cdDown;
      end;
  end;
end;

{ TCarts }

constructor TCarts.Create;
begin
  // We need to walk through carts from top to bottom
  inherited Create(TComparer<TCart>.Construct(function (const Left, Right: TCart): Integer
    begin
      Result := Left.Pos.Y - Right.Pos.Y;
      if Result = 0 then
        Result := Left.Pos.X - Right.Pos.X;
    end), True);

  FCollisions := TList<TPoint>.Create;
end;

destructor TCarts.Destroy;
begin
  FCollisions.Free;
  inherited;
end;

procedure TCarts.DoOnStepCarts;
begin
  if Assigned(FOnStepCarts) then
    FOnStepCarts(Self);
end;

function TCarts.GetFirstCollision: TPoint;
begin
  if FCollisions.Count = 0 then
    Exit(TPoint.Zero);

  Result := FCollisions[0];
end;

function TCarts.StepCarts: Boolean;

  function IsCrash(const Index: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to Count - 1 do
      if (I <> Index) and (Items[Index].Pos = Items[I].Pos) then
        Exit(True);
  end;

  function EliminateCollision(const Index: Integer): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to Count - 1 do
      if (I <> Index) and (Items[Index].Pos = Items[I].Pos) then
        begin
          Result := Index - I;
          if Index > I then
            begin
              Delete(Index);
              Delete(I);
            end
          else
            begin
              Delete(I);
              Delete(Index);
            end;
          Exit;
        end;
  end;

var
  I: Integer;
begin
  Result := True;

  // We need to walk through carts from top to bottom
  Sort;

  I := 0;
  while I < Count do
    begin
      Items[I].MoveCart;
      if IsCrash(I) then
        begin
          FCollisions.Add(Items[I].FPos);
          if EliminateCollision(I) > 0 then
            Dec(I);
        end
      else
        Inc(I);
    end;

  if Count = 1 then
    Exit(False);

  DoOnStepCarts;
end;

end.
