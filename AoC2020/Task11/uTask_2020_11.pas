unit uTask_2020_11;

interface

uses
  System.Types, System.Generics.Collections, uTask;

type
  TSeatState = ( ssNone, ssFloor, ssFree, ssOccupied );

  TMap = class
  private
    FItems: TArray<TSeatState>;
    FWidth: Integer;
    FHeight: Integer;
    function GetState(const Key: TPoint): TSeatState;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetItem(const Index: Integer): TSeatState;
    function GetKey(const Key: TPoint): Integer;
    function GetCount: Integer;
    procedure SetItem(const Index: Integer; const Value: TSeatState);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Key: TPoint; const Value: TSeatState);
    procedure Assign(const Source: TMap);
    function Clone: TMap;
    function IsWithinMap(const Key: TPoint): Boolean;
    function ContainsKey(const Key: TPoint): Boolean;
    function ToKey(const Index: Integer): TPoint;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Count: Integer read GetCount;
    property Items[const Index: Integer]: TSeatState read GetItem write SetItem;
    property State[const Key: TPoint]: TSeatState read GetState;
  end;

  TTask_AoC = class (TTask)
  private
    FMap: TMap;
    procedure LoadMap;
    function SimulationStep(const Part: Integer; const Current, Previous: TMap): Boolean;
    function GetOppupiedAmountAfterStabilization(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TMap }

procedure TMap.Add(const Key: TPoint; const Value: TSeatState);
begin
  FItems[GetKey(Key)] := Value;
end;

procedure TMap.Assign(const Source: TMap);
begin
  FItems := Copy(Source.FItems, 0, Source.Count);
end;

function TMap.Clone: TMap;
begin
  Result := TMap.Create;
  Result.FItems := Copy(FItems, 0, Length(FItems));
  Result.FWidth := FWidth;
  Result.FHeight := FHeight;
end;

function TMap.ContainsKey(const Key: TPoint): Boolean;
var
  K: Integer;
begin
  if not IsWithinMap(Key) then
    Exit(False);

  K := GetKey(Key);

  Result := (K < Length(FItems)) and (FItems[K] <> ssNone);
end;

constructor TMap.Create;
begin
  SetLength(FItems, 0);
end;

destructor TMap.Destroy;
begin
  SetLength(FItems, 0);
  inherited;
end;

function TMap.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TMap.GetItem(const Index: Integer): TSeatState;
begin
  Result := FItems[Index];
end;

function TMap.GetKey(const Key: TPoint): Integer;
begin
  Result := Key.X + Key.Y * FWidth;
end;

function TMap.GetState(const Key: TPoint): TSeatState;
begin
  if not IsWithinMap(Key) then
    Exit(ssNone);

  Result := ssFloor;

  if ContainsKey(Key) then
    Result := Items[GetKey(Key)];
end;

function TMap.IsWithinMap(const Key: TPoint): Boolean;
begin
  with Key do
    Result := (X >= 0) and (Y >= 0) and (X < FWidth) and (Y < FHeight);
end;

procedure TMap.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  SetLength(FItems, FHeight * FWidth);
end;

procedure TMap.SetItem(const Index: Integer; const Value: TSeatState);
begin
  FItems[Index] := Value;
end;

procedure TMap.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  SetLength(FItems, FHeight * FWidth);
end;

function TMap.ToKey(const Index: Integer): TPoint;
begin
  Result := TPoint.Create(Index mod FWidth, Index div FWidth);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadMap;
    Ok('Part 1: %d, Part 2: %d', [ GetOppupiedAmountAfterStabilization(1), GetOppupiedAmountAfterStabilization(2) ]);
  finally
    FMap.Free;
  end;
end;

function TTask_AoC.GetOppupiedAmountAfterStabilization(const Part: Integer): Integer;
var
  Current, Previous: TMap;
  I: Integer;
begin
  Result := 0;

  Current := FMap.Clone;
  Previous := FMap.Clone;

  try
    while SimulationStep(Part, Current, Previous) do
      Previous.Assign(Current);

    for I := 0 to Current.Count - 1 do
      if Current.Items[I] = ssOccupied then
        Inc(Result);
  finally
    FreeAndNil(Current);
    FreeAndNil(Previous);
  end;
end;

procedure TTask_AoC.LoadMap;
var
  X, Y: Integer;
begin
  FMap := TMap.Create;
  with Input do
    try
      FMap.Width := Strings[0].Length;
      FMap.Height := Count;

      for Y := 0 to Count - 1 do
        for X := 1 to Strings[Y].Length do
          case Strings[Y][X] of
            'L': FMap.Add(TPoint.Create(X - 1, Y), ssFree);
            '.': FMap.Add(TPoint.Create(X - 1, Y), ssFloor);
          end;
    finally
      Free;
    end;
end;

function TTask_AoC.SimulationStep(const Part: Integer; const Current, Previous: TMap): Boolean;
const
  DIRECTIONS: array [0..7] of TPoint =
    (
      ( X: -1; Y: -1 )
    , ( X: -1; Y:  0 )
    , ( X: -1; Y:  1 )
    , ( X:  0; Y: -1 )
    , ( X:  0; Y:  1 )
    , ( X:  1; Y: -1 )
    , ( X:  1; Y:  0 )
    , ( X:  1; Y:  1 )
    );

  function CheckSiblings(const Seat: TPoint; const Map: TMap): Integer;
  var
    I, Occupied: Integer;
    Sibling: TPoint;
    SeatState: TSeatState;
  begin
    Result := 0;
    Occupied := 0;
    SeatState := Map.State[Seat];

    for I := 0 to Length(DIRECTIONS) - 1 do
      begin
        Sibling := Seat + DIRECTIONS[I];
        case Part of
          1:
            if Map.State[Sibling] = ssOccupied then
              Inc(Occupied);
          2:
            while Map.IsWithinMap(Sibling) do
              begin
                if Map.State[Sibling] = ssFloor then
                  begin
                    Sibling := Sibling + DIRECTIONS[I];
                    Continue;
                  end;

                if Map.State[Sibling] = ssOccupied then
                  Inc(Occupied);
                Break;
              end;
        end;

        // Small optimization, better then nothing.
        // May exit the cycle a bit earlier.
        if (SeatState = ssOccupied) and (Occupied >= 3 + Part) then
          Exit(-1);
      end;

    if (SeatState = ssFree) and (Occupied = 0) then
      Exit(1);
  end;

var
  I: Integer;
begin
  Result := False;

  for I := 0 to Current.Count - 1 do
    if Current.Items[I] in [ ssFree, ssOccupied ] then
      case CheckSiblings(Current.ToKey(I), Previous) of
        -1:
          begin
            Current.Items[I] := ssFree;
            Result := True;
          end;
        1:
          begin
            Current.Items[I] := ssOccupied;
            Result := True;
          end;
      end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 11, 'Seating System');

finalization
  GTask.Free;

end.
