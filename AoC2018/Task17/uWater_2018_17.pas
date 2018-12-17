unit uWater_2018_17;

interface

uses
  System.Types, System.Generics.Collections, System.Classes;

type
  TSquareType = ( stSand, stClay, stWaterSource, stWater, stWetSand );
  TSquareTypes = set of TSquareType;
  TFlowDirection = ( fdDown, fdLeft, fdRight );

  TMap = class
  private
    FMap: TArray<TArray<TSquareType>>;
    FBounds: TRect;
    FOnSimulationStep: TNotifyEvent;
    procedure DoOnSimulationStep;
    function GetSquare(const X, Y: Integer): TSquareType;
    procedure SetSquare(const X, Y: Integer; const Value: TSquareType);
  public
    constructor Create(const ABounds: TRect);
    function Exists(const X, Y: Integer): Boolean;
    procedure Simulate;
    property Squares[const X, Y: Integer]: TSquareType read GetSquare write SetSquare; default;
    function WaterSource: TPoint;
    function CountOf(const Types: TSquareTypes): Integer;
    property Bounds: TRect read FBounds;
    property OnSimulationStep: TNotifyEvent read FOnSimulationStep write FOnSimulationStep;
  end;

implementation

uses
  System.SysUtils;

{ TMap }

function TMap.CountOf(const Types: TSquareTypes): Integer;
var
  X, Y: Integer;
begin
  Result := 0;
  for X := 0 to Length(FMap) - 1 do
    for Y := 0 to Length(FMap[X]) - 1 do
      if FMap[X][Y] in Types then
        Inc(Result);
end;

constructor TMap.Create(const ABounds: TRect);
var
  I: Integer;
begin
  FBounds := ABounds;
  FBounds.Left   := FBounds.Left;
  FBounds.Top    := FBounds.Top;
  FBounds.Right  := FBounds.Right;
  FBounds.Bottom := FBounds.Bottom;

  SetLength(FMap, FBounds.Width);
  for I := 0 to FBounds.Width - 1 do
    SetLength(FMap[I], FBounds.Height);
end;

procedure TMap.DoOnSimulationStep;
begin
  if Assigned(FOnSimulationStep) then
    FOnSimulationStep(Self);
end;

function TMap.Exists(const X, Y: Integer): Boolean;
begin
  Result := (X >= 0) and (X < FBounds.Width) and (Y >= 0) and (Y < FBounds.Height);
end;

function TMap.GetSquare(const X, Y: Integer): TSquareType;
begin
  Result := FMap[X][Y];
end;

procedure TMap.SetSquare(const X, Y: Integer; const Value: TSquareType);
begin
  FMap[X][Y] := Value;
end;

procedure TMap.Simulate;
var
  Source: TPoint;
  Queue: TQueue<TPoint>;
  StepNo: Integer;

  function CanGo(const P: TPoint; const D: TFlowDirection): Boolean;
  begin
    Result := False;
    case D of
      fdDown:
        if Exists(P.X, P.Y + 1) then
          Result := FMap[P.X][P.Y + 1] in [ stSand, stWetSand ];
      fdLeft:
        if Exists(P.X - 1, P.Y) then
          Result := FMap[P.X - 1][P.Y] in [ stSand, stWetSand ];
      fdRight:
        if Exists(P.X + 1, P.Y) then
          Result := FMap[P.X + 1][P.Y] in [ stSand, stWetSand ];
    end;
  end;

  procedure FloodBox(Source: TPoint);
  var
    I, J: Integer;
    P, PL, PR: TPoint;
    Box: TRect;
    FoundTop, WaterFalls: Boolean;
  begin
    P := Source;

    // Detect box bottom
    while CanGo(P, fdDown) do
      begin
        if FMap[P.X][P.Y] <> stWaterSource then
          FMap[P.X][P.Y] := stWetSand;
        Inc(P.Y);
      end;
    Box.Bottom := P.Y;

    // Detect end of screen
    if not Exists(P.X, P.Y + 1) then
      Exit;

    WaterFalls := False;

    // Detect box left side
    PL := P;
    while CanGo(PL, fdLeft) do
      begin
        FMap[PL.X][PL.Y] := stWetSand;
        Dec(PL.X);
        // Detect fall (water drops on edge)
        if CanGo(PL, fdDown) then
          begin
            Queue.Enqueue(PL);
            WaterFalls := True;
            Break;
          end;
      end;
    Box.Left := PL.X;

    // Detect box right side
    PR := P;
    while CanGo(PR, fdRight) do
      begin
        FMap[PR.X][PR.Y] := stWetSand;
        Inc(PR.X);
        // Detect fall (water drops on edge)
        if CanGo(PR, fdDown) then
          begin
            Queue.Enqueue(PR);
            WaterFalls := True;
            Break;
          end;
      end;
    Box.Right := PR.X;

    if WaterFalls then
      Exit;

    // Detect box top side
    FoundTop := False;
    while not FoundTop do
      if CanGo(PL, fdLeft) or CanGo(PR, fdRight) then
        begin
          // We're ouside of the box, make wet send on top of it
          if CanGo(PL, fdLeft) and CanGo(PR, fdRight) then
            for I := PL.X to PR.X do
              FMap[I][PL.Y] := stWetSand
          else
            Queue.Enqueue(Source);

          for I := PL.X to Source.X do
            FMap[I][PL.Y] := stWetSand;
          if CanGo(PL, fdLeft) then
            begin
              FMap[PL.X - 1][PL.Y] := stWetSand;
              Dec(PL.X, 2);
              if CanGo(PL, fdDown) then
                Queue.Enqueue(PL);
            end;

          for I := Source.X to PR.X do
            FMap[I][PR.Y] := stWetSand;
          if CanGo(PR, fdRight) then
            begin
              FMap[PR.X + 1][PR.Y] := stWetSand;
              Inc(PR.X, 2);
              if CanGo(PR, fdDown) then
                Queue.Enqueue(PR);
            end;

          Inc(PL.Y);
          Inc(PR.Y);
          FoundTop := True;
        end
      else
        begin
          for I := PL.X to PR.X do
            if FMap[I][PL.Y - 1] = stClay then
              begin
                FoundTop := True;
                Queue.Enqueue(Source);
                Break;
              end;

          if not FoundTop then
            begin
              Dec(PL.Y);
              Dec(PR.Y);
            end;
        end;
    Box.Top := PL.Y;

    // Flood the Box
    for I := Box.Left to Box.Right do
      for J := Box.Top to Box.Bottom do
        if FMap[I][J] <> stClay then
          FMap[I][J] := stWater;
  end;

begin
  StepNo := 0;
  try
    Source := WaterSource;
    Queue := TQueue<TPoint>.Create;
    Queue.Enqueue(Source);
    while Queue.Count > 0 do
      begin
        FloodBox(Queue.Dequeue);
        Inc(StepNo);
        DoOnSimulationStep;
      end;
  finally
    Queue.Free;
  end;
end;

function TMap.WaterSource: TPoint;
var
  X, Y: Integer;
begin
  Result := TPoint.Zero;
  for X := 0 to Length(FMap) - 1 do
    for Y := 0 to Length(FMap[X]) - 1 do
      if FMap[X][Y] = stWaterSource then
        Exit(TPoint.Create(X, Y));
end;

end.
