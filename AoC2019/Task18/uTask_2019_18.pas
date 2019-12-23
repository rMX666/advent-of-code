unit uTask_2019_18;

interface

uses
  uTask, System.Types, System.Generics.Collections, Generics.PriorityQueue;

type
  TMaze = TDictionary<TPoint,Char>;
  TTargets = TDictionary<Char,TPoint>;
  TMazePath = TArray<TPoint>;

  TQueueItem = record
    Current, Previous: TPoint;
    Steps, Heuristics: Integer;
    constructor Create(const Current, Previous: TPoint; const Steps, Heuristics: Integer);
    function CompareTo(Right: TQueueItem): Integer;
  end;

  TTask_AoC = class (TTask)
  private
    FStart: TPoint;
    FKeys: TTargets;
    FMaze: TMaze;
    function AStar(const Start, Finish: TPoint): TMazePath;
    function WalkMaze: Integer;
    procedure LoadMaze;
    procedure DrawMaze;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Generics.Defaults, uHeuristics, uForm_2019_18;

var
  GTask: TTask_AoC;

{ TQueueItem }

function TQueueItem.CompareTo(Right: TQueueItem): Integer;
begin
  Result := (Steps + Heuristics) - (Right.Steps + Right.Heuristics);
end;

constructor TQueueItem.Create(const Current, Previous: TPoint; const Steps, Heuristics: Integer);
begin
  Self.Current := Current;
  Self.Previous := Previous;
  Self.Steps := Steps;
  Self.Heuristics := Heuristics;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadMaze;
  try
    OK('Part 1: %d', [ WalkMaze ]);
    DrawMaze;
  finally
    FMaze.Free;
    FKeys.Free;
  end;
end;

procedure TTask_AoC.DrawMaze;
begin
  fForm_2019_18 := TfForm_2019_18.Create(nil);
  fForm_2019_18.DrawMaze(FMaze);
  fForm_2019_18.ShowModal;
end;

procedure TTask_AoC.LoadMaze;
var
  Y, X: Integer;
  C: Char;
  P: TPoint;
begin
  FMaze := TMaze.Create;
  FKeys := TTargets.Create;
  with Input do
    try
      for Y := 0 to Count - 1 do
        for X := 1 to Strings[Y].Length do
          begin
            C := Strings[Y][X];
            P := TPoint.Create(X - 1, Y);
            if C <> '#' then
              FMaze.Add(P, C);
            case C of
              '@':      FStart := P;
              'a'..'z': FKeys.Add(C, P);
            end;
          end;
    finally
      Free;
    end;
end;

function TTask_AoC.AStar(const Start, Finish: TPoint): TMazePath;
var
  Queue: TPriorityQueue<TQueueItem>;
  Visited: TDictionary<TPoint,TQueueItem>;
  Current: TQueueItem;

  procedure EnqueueNeighbours;
  const
    Directions: array [0..3] of TPoint =
      (
        ( X: -1; Y:  0 )
      , ( X:  1; Y:  0 )
      , ( X:  0; Y: -1 )
      , ( X:  0; Y:  1 )
      );
  var
    I: Integer;
    NextP: TPoint;
    Next: TQueueItem;
  begin
    for I := 0 to 3 do
      begin
        NextP := Current.Current + Directions[I];

        if not FMaze.ContainsKey(NextP) then
          Continue;

        Next := TQueueItem.Create(NextP, Current.Current, Current.Steps + 1, Heuristic(NextP, Finish));

        if Visited.ContainsKey(NextP) then
          begin
            if Visited[NextP].Steps > Next.Steps then
              Visited[NextP] := Next;
            Continue;
          end;

        Queue.Push(Next);
        Visited.Add(NextP, Next);
      end;
  end;

  function Traceback: TMazePath;
  begin
    SetLength(Result, 1);
    Result[0] := Current.Current;
    while Visited.ContainsKey(Current.Previous) and (Current.Previous <> Current.Current) do
      begin
        Current := Visited[Current.Previous];
        Insert(Current.Current, Result, 0);
      end;
  end;

begin
  Queue := TPriorityQueue<TQueueItem>.Create(TComparer<TQueueItem>.Construct(function (const Left, Right: TQueueItem): Integer
    begin
      Result := Left.CompareTo(Right);
    end));
  Visited := TDictionary<TPoint,TQueueItem>.Create;
  Queue.Push(TQueueItem.Create(Start, Start, 0, Heuristic(Start, Finish)));
  Visited.Add(Start, Queue.Peek);
  SetLength(Result, 0);

  try
    while not Queue.IsEmpty do
      begin
        Current := Queue.Pop;
        if Current.Current = Finish then
          Exit(Traceback);
        EnqueueNeighbours;
      end;
  finally
    Queue.Free;
    Visited.Free;
  end;
end;

function TTask_AoC.WalkMaze: Integer;
begin

end;

initialization
  GTask := TTask_AoC.Create(2019, 18, 'Many-Worlds Interpretation');

finalization
  GTask.Free;

end.
