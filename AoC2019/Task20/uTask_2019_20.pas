unit uTask_2019_20;

interface

uses
  uTask, System.Types, System.Generics.Collections;

type
  TMazeTileType = ( mtWall, mtStart, mtFinish, mtOpen, mtPortal );
  TMazeTile = record
  public
    P: TPoint;
    TileType: TMazeTileType;
    Name: String;
    constructor Create(const X, Y: Integer; const TileType: TMazeTileType; const Name: String = '');
    class operator Equal(const Left, Right: TMazeTile): Boolean;
    class operator NotEqual(const Left, Right: TMazeTile): Boolean;
    function ToString: String;
  end;
  TMaze = TDictionary<TPoint,TMazeTile>;
  TPortals = TDictionary<TPoint,TPoint>;

  TTask_AoC = class (TTask)
  private
    FStart: TMazeTile;
    FMaze: TMaze;
    FPortals: TPortals;
    procedure LoadMaze;
    function GetSteps(const UseRecursion: Boolean): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Generics.Defaults, System.Hash;

var
  GTask: TTask_AoC;

{ TMazeTile }

constructor TMazeTile.Create(const X, Y: Integer; const TileType: TMazeTileType; const Name: String);
begin
  Self.P := TPoint.Create(X, Y);
  Self.TileType := TileType;
  Self.Name := Name;
end;

class operator TMazeTile.Equal(const Left, Right: TMazeTile): Boolean;
var
  I: Integer;
begin
  Result := (Left.P        = Right.P)
        and (Left.TileType = Right.TileType);
end;

class operator TMazeTile.NotEqual(const Left, Right: TMazeTile): Boolean;
begin
  Result := not (Left = Right);
end;

function TMazeTile.ToString: String;
var
  I: Integer;
begin
  Result := Format('%d,%d,%d,%s', [ P.X, P.Y, Integer(TileType), Name ]);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadMaze;
  try
    OK('Part 1: %d', [ GetSteps(False) ]);
    OK('Part 2: %d', [ GetSteps(True) ]);
  finally
    FMaze.Free;
    FPortals.Free;
  end;
end;

function TTask_AoC.GetSteps(const UseRecursion: Boolean): Integer;
const
  Directions: array [0..3] of TPoint =
    (
      ( X: -1; Y:  0 )
    , ( X:  1; Y:  0 )
    , ( X:  0; Y: -1 )
    , ( X:  0; Y:  1 )
    );
var
  Visited: TDictionary<TMazeTile,TMazeTile>;
  Queue: TQueue<TMazeTile>;
  Current: TMazeTile;

  function GetOpenNear(const P: TPoint; out OutP: TPoint): Boolean;
  var
    I: Integer;
    Next: TPoint;
  begin
    Result := False;
    for I := 0 to 3 do
      begin
        Next := P + Directions[I];
        if FMaze.ContainsKey(Next) then
          begin
            OutP := Next;
            Exit(True);
          end;
      end;
  end;

  function CanGo(const P: TPoint; out Tile: TMazeTile): Boolean;
  begin
    Result := True;

    if not FMaze.ContainsKey(P) then
      Exit(False);
    Tile := FMaze[P];

    if Visited.ContainsKey(Tile) then
      Exit(False);
    Visited.Add(Tile, Current);
  end;

  function InArray(const A: TArray<String>; const Value: String): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to Length(A) - 1 do
      if A[I] = Value then
        Exit(True);
  end;

  procedure EnqueueNeightbours;
  var
    NextP: TPoint;
    Next: TMazeTile;
    I: Integer;
    Name: String;
  begin
    for I := 0 to 3 do
      begin
        NextP := Current.P + Directions[I];
        if not CanGo(NextP, Next) then
          Continue;

        if Next.TileType = mtPortal then
          begin
            if not FPortals.ContainsKey(NextP) then
              raise Exception.Create('Portal error');

            NextP := FPortals[NextP];
            if not CanGo(NextP, Next) then
              Continue;
            Name := Next.Name;

            if not GetOpenNear(NextP, NextP) then
              Continue;

            if not CanGo(NextP, Next) then
              Continue;
          end;

        Queue.Enqueue(Next);
      end;
  end;

  function Traceback: Integer;
  begin
    LoggerEnabled := True;
    Logger.WriteLine('----');
    Result := 0;
    while Visited.ContainsKey(Current) and (Current <> Visited[Current]) do
      begin
        Logger.WriteLine('(%d, %d)', [ Current.P.X, Current.P.Y ]);
        Current := Visited[Current];
        Inc(Result);
      end;
  end;

begin
  Queue := TQueue<TMazeTile>.Create;
  Visited := TDictionary<TMazeTile,TMazeTile>.Create(TEqualityComparer<TMazeTile>.Construct(
    function (const Left, Right: TMazeTile): Boolean
      begin
        Result := Left = Right;
      end
  , function (const Value: TMazeTile): Integer
      begin
        Result := THashBobJenkins.GetHashValue(Value.ToString);
      end
  ));
  Result := -1;
  try
    if GetOpenNear(FStart.P, Current.P) then
      begin
        Current := FMaze[Current.P];
        Queue.Enqueue(Current);
        Visited.Add(FStart, FStart);
        Visited.Add(Current, Current);
      end;

    while Queue.Count > 0 do
      begin
        Current := Queue.Dequeue;
        if (Current.TileType = mtFinish) then
          Exit(Traceback - 1);
        EnqueueNeightbours;
      end;
  finally
    Queue.Free;
    Visited.Free;
  end;
end;

procedure TTask_AoC.LoadMaze;
var
  PortalCache: TObjectDictionary<String,TList<TPoint>>;

  procedure AppendMaze(const X, Y: Integer; const TileType: TMazeTileType);
  var
    P: TPoint;
    Tile: TMazeTile;
  begin
    P := TPoint.Create(X, Y);
    Tile := TMazeTile.Create(X, Y, TileType);
    if not FMaze.ContainsKey(P) then
      FMaze.Add(P, Tile);
    if TileType = mtStart then
      FStart := Tile;
  end;

  procedure AppendPortal(const X, Y: Integer; const TileType: TMazeTileType; const Name: String);
  var
    P: TPoint;
    Tile: TMazeTile;
  begin
    P := TPoint.Create(X, Y);
    Tile := TMazeTile.Create(X, Y, TileType, Name);
    if FMaze.ContainsKey(P) then
      FMaze[P] := Tile
    else
      FMaze.Add(P, Tile);
    if not PortalCache.ContainsKey(Name) then
      PortalCache.Add(Name, TList<TPoint>.Create);
    PortalCache[Name].Add(P);
  end;

var
  X, Y, X1, Y1: Integer;
  Name: String;
begin
  FMaze := TMaze.Create;
  FPortals := TPortals.Create;
  PortalCache := TObjectDictionary<String,TList<TPoint>>.Create([ doOwnsValues ]);
  with Input do
    try
      for Y := 0 to Count - 1 do
        for X := 1 to Strings[Y].Length do
          case Strings[Y][X] of
            ' ', '#':  // Ignore walls and empty space
              ;
            '.':       // Walkable tiles
              AppendMaze(X, Y, mtOpen);
            'A'..'Z':  // Portal labels or Start/Finish tile
              begin
                // 1. Labels can be vertical or horizontal.
                // 2. Labels are always two characters long.
                // 3. We read Labels only left-to-right and top-to-bottom.
                Name := Strings[Y][X];
                Y1 := Y;
                X1 := X;
                // It's horizontal label
                if (X < Strings[Y].Length) and CharInSet(Strings[Y][X + 1], [ 'A'..'Z' ]) then
                  begin
                    Name := Name + Strings[Y][X + 1];
                    Y1 := Y;
                    // The walkable tile is either on the right or left of the label
                    if (X > 1) and (Strings[Y][X - 1] = '.') then
                      X1 := X
                    else if (X < Strings[Y].Length - 1) and (Strings[Y][X + 2] = '.') then
                      X1 := X + 1;
                  end
                else if (Y < Count - 1) and (CharInSet(Strings[Y + 1][X], [ 'A'..'Z' ])) then
                  begin
                    Name := Name + Strings[Y + 1][X];
                    X1 := X;
                    // The walkable tile is either on the top of bottom of the label
                    if (Y > 0) and (Strings[Y - 1][X] = '.') then
                      Y1 := Y
                    else if (Y < Count - 2) and (Strings[Y + 2][X] = '.') then
                      Y1 := Y + 1;
                  end;

                if Name = 'AA' then
                  AppendMaze(X1, Y1, mtStart)
                else if Name = 'ZZ' then
                  AppendMaze(X1, Y1, mtFinish)
                else if Name.Length = 2 then
                  AppendPortal(X1, Y1, mtPortal, Name);
              end;
          end;

      for Name in PortalCache.Keys do
        with PortalCache[Name] do
          begin
            FPortals.Add(Items[0], Items[1]);
            FPortals.Add(Items[1], Items[0]);
          end;
    finally
      Free;
      PortalCache.Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 20, 'Donut Maze');

finalization
  GTask.Free;

end.
