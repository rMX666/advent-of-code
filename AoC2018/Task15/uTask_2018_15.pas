unit uTask_2018_15;

interface

uses
  System.Types, System.Generics.Collections, System.Generics.Defaults, uTask;

type
  TUnitType = ( utElf, utGoblin );

  PUnit = ^TUnit;
  TUnit = record
    UnitType: TUnitType;
    P: TPoint;
    HP, Power: Integer;
    Width: Integer;
    constructor Create(const AUnitType: TUnitType; const X, Y, AHP, APower, AWidth: Integer);
    class function Pointer(const AUnitType: TUnitType; const X, Y, AHP, APower, AWidth: Integer): PUnit; static;
    function IsDead: Boolean;
    function IsEnemy(const U: PUnit): Boolean;
    procedure Attack(const Enemy: PUnit);
    function IntPosition: Integer;
  end;

  TNeighbours = TList<TPoint>;
  TMap = TObjectDictionary<TPoint,TNeighbours>;
  TUnits = class(TList<PUnit>)
  public
    function ByPoint(const P: TPoint): PUnit;
    function HasEnemyInRange(const P: TPoint; const U: PUnit): Boolean;
  end;

  TUnitComparer = class(TCustomComparer<PUnit>)
  protected
    function Compare(const Left, Right: PUnit): Integer;  override;
    function Equals(const Left, Right: PUnit): Boolean; reintroduce; overload; override;
    function GetHashCode(const Value: PUnit): Integer; reintroduce; overload; override;
  end;

  TTask_AoC = class (TTask)
  strict private type
    TStepResult = ( stContinue, stStopFull, stStopUnfinished, stElfDied );
  private
    FMap: TMap;
    FWidth: Integer;
    FUnits: TUnits;
    FComparer: TUnitComparer;
    procedure LoadMap(const ElfsPower: Integer);
    function Step(const ElfsMustWin: Boolean): TStepResult;
    procedure StepUnit(const U: PUnit);
    function Battle(const ElfsPower: Integer = 3; const ElfsMustWin: Boolean = False): Integer;
    function ElfsWinningBattle: Integer;
    procedure Draw;
  protected
    procedure DoRun; override;
  public
    property Map: TMap read FMap;
    property Units: TUnits read FUnits;
    property Width: Integer read FWidth;
  end;

implementation

uses
  System.SysUtils, System.Math, uForm_2018_15, Vcl.Forms;

const
  Directions: array [0..3] of TPoint =
    (
      ( X:  0; Y: -1 ) // Up
    , ( X: -1; Y:  0 ) // Left
    , ( X:  1; Y:  0 ) // Right
    , ( X:  0; Y:  1 ) // Down
    );

var
  GTask: TTask_AoC;

{ TUnit }

procedure TUnit.Attack(const Enemy: PUnit);
begin
  Dec(Enemy.HP, Power);
end;

constructor TUnit.Create(const AUnitType: TUnitType; const X, Y, AHP, APower, AWidth: Integer);
begin
  UnitType := AUnitType;
  P := TPoint.Create(X, Y);
  HP := AHP;
  Power := APower;
  Width := AWidth;
end;

function TUnit.IntPosition: Integer;
begin
  Result := P.Y * Width + P.X;
end;

function TUnit.IsDead: Boolean;
begin
  Result := HP <= 0;
end;

function TUnit.IsEnemy(const U: PUnit): Boolean;
begin
  Result := U.UnitType <> UnitType;
end;

class function TUnit.Pointer(const AUnitType: TUnitType; const X, Y, AHP, APower, AWidth: Integer): PUnit;
begin
  New(Result);
  Result^ := TUnit.Create(AUnitType, X, Y, AHP, APower, AWidth);
end;

{ TUnitComparer }

function TUnitComparer.Compare(const Left, Right: PUnit): Integer;
begin
  if Left.IsDead and Right.IsDead then
    Exit(0);
  if Left.IsDead then
    Exit(-1);
  if Right.IsDead then
    Exit(1);

  Result := Sign(Left.IntPosition - Right.IntPosition);
end;

function TUnitComparer.Equals(const Left, Right: PUnit): Boolean;
begin
  Result := Left.P = Right.P;
end;

function TUnitComparer.GetHashCode(const Value: PUnit): Integer;
begin
  Result := Integer(Value);
end;

{ TUnits }

function TUnits.ByPoint(const P: TPoint): PUnit;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if (P = Items[I].P) and not Items[I].IsDead then
      Exit(Items[I]);
end;

function TUnits.HasEnemyInRange(const P: TPoint; const U: PUnit): Boolean;
var
  I: Integer;
  Next: TPoint;
  Candidate: PUnit;
begin
  Result := False;

  for I := 0 to 3 do
    begin
      Next := P + Directions[I];
      Candidate := ByPoint(Next);
      if Assigned(Candidate) and Candidate.IsEnemy(U) and not Candidate.IsDead then
        Exit(True);
    end;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  fForm_2018_15 := TfForm_2018_15.Create(nil);
  fForm_2018_15.Show;

  OK(Format('Part 1: %d, Part 2: %d', [ Battle, ElfsWinningBattle ]));
end;

procedure TTask_AoC.Draw;
begin
  fForm_2018_15.DrawMap(Self);
end;

procedure TTask_AoC.LoadMap(const ElfsPower: Integer);
var
  X, Y, I: Integer;
  Key, Candidate: TPoint;
begin
  FMap := TMap.Create([doOwnsValues]);
  FComparer := TUnitComparer.Create;
  FUnits := TUnits.Create(FComparer);

  with Input do
    try
      FWidth := Count;
      for Y := 0 to Count - 1 do
        for X := 1 to Strings[Y].Length do
          if Strings[Y][X] <> '#' then
            begin
              FMap.Add(TPoint.Create(X - 1, Y), TNeighbours.Create);
              case Strings[Y][X] of
                'E': FUnits.Add(TUnit.Pointer(utElf,    X - 1, Y, 200, ElfsPower, FWidth));
                'G': FUnits.Add(TUnit.Pointer(utGoblin, X - 1, Y, 200, 3, FWidth));
              end;
            end;
    finally
      Free;
    end;

  // Cache open neighbours
  for Key in FMap.Keys do
    for I := 0 to 3 do
      begin
        Candidate := Key + Directions[I];
        if FMap.ContainsKey(Candidate) then
          FMap[Key].Add(Candidate);
      end;
end;

function TTask_AoC.ElfsWinningBattle: Integer;
var
  Power: Integer;
begin
  Power := 3;
  repeat
    Result := Battle(Power, True);
    Inc(Power);
  until Result <> -1;
end;

function TTask_AoC.Battle(const ElfsPower: Integer; const ElfsMustWin: Boolean): Integer;
var
  I, HP: Integer;
  StepResult: TStepResult;
begin
  try
    LoadMap(ElfsPower);

    Result := 0;
    Draw;
    repeat
      StepResult := Step(ElfsMustWin);
      if StepResult = stElfDied then
        Exit(-1);
      if StepResult <> stStopUnfinished then
        Inc(Result);
      Draw;
    until StepResult <> stContinue;

    HP := 0;
    for I := 0 to FUnits.Count - 1 do
      if not FUnits[I].IsDead then
        Inc(HP, FUnits[I].HP);

    Result := Result * HP;
  finally
    FMap.Free;
    for I := 0 to FUnits.Count - 1 do
      Dispose(FUnits[I]);
    FUnits.Free;
    FComparer.Free;
  end;
end;

function TTask_AoC.Step(const ElfsMustWin: Boolean): TStepResult;

  function StopFight: Boolean;
  var
    I, Elfs, Goblins: Integer;
  begin
    Elfs := 0;
    Goblins := 0;
    for I := 0 to FUnits.Count - 1 do
      if not FUnits[I].IsDead then
        case FUnits[I].UnitType of
          utElf:    Inc(Elfs);
          utGoblin: Inc(Goblins);
        end;

    Result := (Elfs = 0) or (Goblins = 0);
  end;

  function HasUndeadTeammatesAfter(I: Integer): Boolean;
  var
    U: PUnit;
  begin
    U := FUnits[I];
    Inc(I);
    Result := False;
    while I < FUnits.Count do
      if not FUnits[I].IsDead and (FUnits[I].UnitType = U.UnitType) then
        Exit(True)
      else
        Inc(I);
  end;

var
  I: Integer;
begin
  Result := stContinue;

  for I := 0 to FUnits.Count - 1 do
    begin
      StepUnit(FUnits[I]);
      if StopFight then
        begin
          if HasUndeadTeammatesAfter(I) then
            Result := stStopUnfinished
          else
            Result := stStopFull;
          Break;
        end;
    end;

  I := 0;
  while I < FUnits.Count do
    if FUnits[I].IsDead then
      begin
        if ElfsMustWin and (FUnits[I].UnitType = utElf) then
          Exit(stElfDied);
        Dispose(FUnits[I]);
        FUnits.Delete(I);
      end
    else
      Inc(I);

  FUnits.Sort;
end;

procedure TTask_AoC.StepUnit(const U: PUnit);
type
  TPath = TArray<TPoint>;

  function FindEnemy(out Enemy: PUnit): Boolean;
  var
    I: Integer;
    Candidate: PUnit;
  begin
    Enemy := nil;

    for I := 0 to 3 do
      begin
        Candidate := FUnits.ByPoint(U.P + Directions[I]);
        if Assigned(Candidate) and not Candidate.IsDead and Candidate.IsEnemy(U) then
          begin
            // Find the weakest enemy in range
            if Enemy = nil then
              Enemy := Candidate
            else if Enemy.HP > Candidate.HP then
              Enemy := Candidate;
          end;
      end;

    Result := Assigned(Enemy);
  end;

  function ChooseDirection(const A, B: TPoint): Integer;
  begin
    Result := (A.Y * FWidth + A.X) - (B.Y * FWidth + B.X);
  end;

  function BFS(const Start: TPoint): TPath;
  const
    NIL_POINT: TPoint = ( X: -1; Y: -1 );
  type
    TVisited = TDictionary<TPoint,TPoint>;
    TVisitQueue = TQueue<TPoint>;
  var
    Visited: TVisited;
    Queue: TVisitQueue;
    Current, Next: TPoint;
    Path: TPath;
    L: Integer;

    function GetPath(P: TPoint): TPath;
    begin
      SetLength(Result, 0);
      while P <> NIL_POINT do
        begin
          Insert(P, Result, 0);
          P := Visited[P];
        end;
    end;

  begin
    SetLength(Result, 0);
    Visited := TVisited.Create;
    Queue := TVisitQueue.Create;

    try
      Visited.Add(Start, NIL_POINT);
      Queue.Enqueue(Start);

      while Queue.Count > 0 do
        begin
          Current := Queue.Dequeue;

          for Next in FMap[Current] do
            begin
              if Visited.ContainsKey(Next) then
                Continue;
              Visited.Add(Next, Current);

              if FUnits.ByPoint(Next) <> nil then
                Continue;

              if FUnits.HasEnemyInRange(Next, U) then
                begin
                  Path := GetPath(Next);

                  // First result, or new path is shorter - use it
                  if (Length(Result) = 0) or (Length(Result) > Length(Path)) then
                    Result := Path
                  // If new path is of the same length - break the tie in reading order
                  else if Length(Result) = Length(Path) then
                    begin
                      L := Length(Result);
                      if ChooseDirection(Result[L - 1], Path[L - 1]) > 0 then
                        Result := Path;
                    end;
                end;

              if Length(Result) = 0 then
                Queue.Enqueue(Next);
            end;
        end;
    finally
      Visited.Free;
      Queue.Free;
    end;
  end;

var
  Enemy: PUnit;
  Path: TPath;
begin
  if U.IsDead then
    Exit;

  // If in range - attack
  if FindEnemy(Enemy) then
    begin
      U.Attack(Enemy);
      Exit;
    end;

  // Try to move
  Path := BFS(U.P);
  // No path, don't move
  if Length(Path) < 2 then
    Exit;

  U.P := Path[1];
  // If in range - attack
  if FindEnemy(Enemy) then
    U.Attack(Enemy);
end;

initialization
  GTask := TTask_AoC.Create(2018, 15, 'Beverage Bandits');

finalization
  GTask.Free;

end.
