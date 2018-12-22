unit uTask_2018_20;

interface

uses
  System.Types, System.Generics.Collections, uTask;

type
  TNeighbours = TList<TPoint>;
  TMap = TObjectDictionary<TPoint, TNeighbours>;

  TTask_AoC = class (TTask)
  private
    FMap: TMap;
    FRegExp: String;
    procedure LoadRegExp;
    function GetLongestPath: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadRegExp;

  try
    OK(Format('Part 1: %d', [ GetLongestPath ]));
  finally
    FMap.Free;
  end;
end;

function TTask_AoC.GetLongestPath: Integer;
type
  TWalkedPoint = record
    P: TPoint;
    Path: Integer;
  end;

  function WalkedPoint(const P: TPoint; const Path: Integer): TWalkedPoint;
  begin
    Result.P := P;
    Result.Path := Path;
  end;

var
  Path: Integer;
  Queue: TQueue<TWalkedPoint>;
  Visited: TDictionary<TPoint,Integer>;

  procedure GetNeightbours(const WP: TWalkedPoint);
  var
    P: TPoint;
  begin
    if not Visited.ContainsKey(WP.P) then
      Visited.Add(WP.P, WP.Path)
    else
      if Visited[P] > WP.Path + 1 then
        Visited[P] := WP.Path + 1;

    for P in FMap[WP.P] do
      begin
        if Visited.ContainsKey(P) then
          begin
            if Visited[P] > WP.Path + 1 then
              Visited[P] := WP.Path + 1;
            Continue;
          end;

        Queue.Enqueue(WalkedPoint(P, WP.Path + 1));
      end;
  end;

begin
  Result := 0;

  Queue   := TQueue<TWalkedPoint>.Create;
  Visited := TDictionary<TPoint,Integer>.Create;

  try
    Queue.Enqueue(WalkedPoint(TPoint.Zero, 0));

    while Queue.Count > 0 do
      GetNeightbours(Queue.Dequeue);

    for Path in Visited.Values do
      if Result < Path then
        Result := Path;
  finally
    Queue.Free;
    Visited.Free;
  end;
end;

procedure TTask_AoC.LoadRegExp;
var
  Current: Integer;
  P: TPoint;

  procedure AddP(const P, CameFrom: TPoint);
  begin
    if not FMap.ContainsKey(P) then
      FMap.Add(P, TNeighbours.Create);
    if not FMap.ContainsKey(CameFrom) then
      FMap.Add(CameFrom, TNeighbours.Create);

    if not FMap[CameFrom].Contains(P) then
      FMap[CameFrom].Add(P);
  end;

  procedure WalkUntil(const S: String);
  var
    NextP: TPoint;
  begin
    while not S.Contains(FRegExp[Current]) do
      begin
        case FRegExp[Current] of
          'N': NextP := TPoint.Create(P.X, P.Y - 1);
          'S': NextP := TPoint.Create(P.X, P.Y + 1);
          'W': NextP := TPoint.Create(P.X - 1, P.Y);
          'E': NextP := TPoint.Create(P.X + 1, P.Y);
        end;
        AddP(NextP, P);
        P := NextP;
        Inc(Current);
      end;
  end;

  procedure WalkMap;
  begin
    while (Current <= FRegExp.Length) and (FRegExp[Current] <> ')') do
      case FRegExp[Current] of
        '(':
          begin
            Inc(Current);
            WalkMap;
          end;
        '|':
          begin
            Inc(Current);
            WalkUntil('(|)');
          end;
        else
          WalkUntil('(|)');
      end;
    Inc(Current);
  end;

begin
  with Input do
    try
      FRegExp := Text.Trim.Replace('^', '').Replace('$', '');
    finally
      Free;
    end;

  FMap := TMap.Create([ doOwnsValues ]);
  Current := 1;
  P := TPoint.Zero;
  WalkMap;
end;

initialization
  GTask := TTask_AoC.Create(2018, 20, 'A Regular Map');

finalization
  GTask.Free;

end.
