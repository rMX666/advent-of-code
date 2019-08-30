unit uSolver_2016_22;

interface

uses
  System.SysUtils, System.Classes, System.RegularExpressions, System.Generics.Collections, System.Generics.Defaults,
  uHeuristics, System.Types;

type
  TSolver = class;

  TVisitedState = ( vsNone, vsVisited, vsRealPath );

  PNode = ^TNode;
  TNode = record
  public
    P: TPoint;
    Size, Used, Avail: Integer;
    Visited: TVisitedState;
    Target: Boolean;
    Source: Boolean;
    Weight: Real;
  public
    constructor Create(const S: String);
    class function Pointer(const S: String): PNode; static;
    class procedure Swap(A, B: PNode); static;
    class operator Equal(A, B: TNode): Boolean;
  end;

  TNodeGrid = TList<TList<PNode>>;
  TOnSolverNodeEvent = procedure (const Node: TNode) of object;
  TOnSolverEvent = procedure (const Solver: TSolver) of object;

  TSolver = class
  private
    FNodes: TNodeGrid;
    FPath: TList<PNode>;
    FPathHeuristics: THeuristicsType;
    FOnPathStep: TOnSolverNodeEvent;
    FOnPathTrace: TOnSolverNodeEvent;
    FOnTraceFinish: TOnSolverEvent;
    function GetNode(const Point: TPoint): PNode;
    function GetEmpty: PNode;
    function GetTarget: PNode;
    function GetSource: PNode;
    function AStar(const Source, Target: PNode): Integer;
  protected
    procedure DoOnPathStep(const Node: TNode);
    procedure DoOnPathTrace(const Node: TNode);
    procedure DoOnTraceFinish;
  public
    constructor Create(const ANodes: TStrings; const ASource, ATarget: TPoint);
    destructor Destroy; override;
    function ViableCount: Integer;
    function Solve: Integer;
    property Nodes: TNodeGrid read FNodes;
    property OnPathStep: TOnSolverNodeEvent read FOnPathStep write FOnPathStep;
    property OnPathTrace: TOnSolverNodeEvent read FOnPathTrace write FOnPathTrace;
    property OnTraceFinish: TOnSolverEvent read FOnTraceFinish write FOnTraceFinish;
    property PathHeuristics: THeuristicsType read FPathHeuristics write FPathHeuristics;
  end;

implementation

uses
  System.Math;

{ TNode }

constructor TNode.Create(const S: String);
begin
  with TRegEx.Match(S, 'node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)', [roNotEmpty, roCompiled]) do
    if Groups.Count >= 5 then
      begin
        P.X   := StrToInt(Groups[1].Value);
        P.Y   := StrToInt(Groups[2].Value);
        Size  := StrToInt(Groups[3].Value);
        Used  := StrToInt(Groups[4].Value);
        Avail := StrToInt(Groups[5].Value);
      end;
  Target := False;
  Source := False;
  Visited := vsNone;
end;

class operator TNode.Equal(A, B: TNode): Boolean;
begin
  Result := A.P = B.P;
end;

class function TNode.Pointer(const S: String): PNode;
begin
  New(Result);
  Result^ := TNode.Create(S);
end;

class procedure TNode.Swap(A, B: PNode);
var
  T: TNode;
begin
  T.Size   := A.Size;
  T.Used   := A.Used;
  T.Avail  := A.Avail;
  T.Target := A.Target;

  A.Size   := B.Size;
  A.Used   := B.Used;
  A.Avail  := B.Avail;
  A.Target := B.Target;

  B.Size   := T.Size;
  B.Used   := T.Used;
  B.Avail  := T.Avail;
  B.Target := T.Target;
end;

{ TSolver }

function TSolver.AStar(const Source, Target: PNode): Integer;
type
  TPathItem = record
    CurrentNode, PreviousNode: PNode;
    Cost, HeuristicCost: Integer;
  end;

var
  Visited: TList<TPathItem>;
  Queue: TList<TPathItem>;

  function PathItem(const CurrentNode, PreviousNode: PNode; const Cost, HeuristicCost: Integer): TPathItem;
  begin
    Result.CurrentNode := CurrentNode;
    Result.PreviousNode := PreviousNode;
    Result.Cost := Cost;
    Result.HeuristicCost := HeuristicCost;
  end;

  function IsVisited(const Point: TPoint): Integer;
  var
    I: Integer;
  begin
    for I := 0 to Visited.Count - 1 do
      if Visited[I].CurrentNode.P = Point then
        Exit(I);

    Result := -1;
  end;

  function IsOutOfBorder(const Point: TPoint): Boolean;
  begin
    with Point do
      Result := (X < 0) or (Y < 0) or (X >= FNodes.Count) or (Y >= FNodes[0].Count);
  end;

  function IsEnoughSpaceForSource(const Point: TPoint): Boolean;
  begin
    Result := GetNode(Point).Used <= Source.Avail;
  end;

  function GetNeighbours(const Item: TPathItem): TArray<TPathItem>;
  const
    Directions: Array [0..3] of TPoint =
      (
        ( X:  0; Y: -1 ), // U
        ( X:  0; Y:  1 ), // D
        ( X: -1; Y:  0 ), // L
        ( X:  1; Y:  0 )  // R
      );
  var
    I, VisitedIndex: Integer;
    VisitedItem: TPathItem;
    NextCost: Integer;
    NextPoint: TPoint;
  begin
    SetLength(Result, 0);

    for I := 0 to 3 do
      begin
        NextPoint := Item.CurrentNode.P + Directions[I];

        if IsOutOfBorder(NextPoint) then
          Continue;

        if not IsEnoughSpaceForSource(NextPoint) then
          Continue;

        NextCost := Item.Cost + 1;
        VisitedIndex := IsVisited(NextPoint);
        if VisitedIndex > -1 then
          begin
            VisitedItem := Visited[VisitedIndex];
            if VisitedItem.Cost > NextCost then
              begin
                VisitedItem.PreviousNode := Item.CurrentNode;
                VisitedItem.Cost := Item.Cost + 1;
                Visited[VisitedIndex] := VisitedItem;
              end;
            Continue;
          end;

        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := PathItem(GetNode(NextPoint), Item.CurrentNode, NextCost, Heuristic(Target.P, NextPoint, FPathHeuristics));
      end;
  end;

  var
    QueueSorter: TComparison<TPathItem>;

  procedure EnqueueNeightbours(const Item: TPathItem);
  var
    Neighbours: TArray<TPathItem>;
    I: Integer;
  begin
    Neighbours := GetNeighbours(Item);
    for I := 0 to Length(Neighbours) - 1 do
      begin
        Queue.Add(Neighbours[I]);
        Visited.Add(Neighbours[I]);
      end;

    if FPathHeuristics <> htNone then
      Queue.Sort(TComparer<TPathItem>.Construct(QueueSorter));
  end;

  function TraceBackPathCount(const Item: TPathItem): Integer;

    function FindNext(var Item: TPathItem): Boolean;
    var
      I: Integer;
    begin
      Result := False;

      if Item.PreviousNode = nil then
        Exit(False);

      for I := 0 to Visited.Count - 1 do
        if Visited[I].CurrentNode.P = Item.PreviousNode.P then
          begin
            Item := (Visited[I]);
            Exit(True);
          end;
    end;

  var
    NextItem: TPathItem;
  begin
    FPath.Clear;
    Result := 1;
    NextItem := Item;
    FPath.Add(NextItem.CurrentNode);
    DoOnPathTrace(NextItem.CurrentNode^);

    while FindNext(NextItem) do
      begin
        DoOnPathTrace(NextItem.CurrentNode^);
        FPath.Add(NextItem.CurrentNode);
        Inc(Result);
      end;
  end;

var
  CurrentItem: TPathItem;
begin
  QueueSorter := function (const Left, Right: TPathItem): Integer
    begin
      Result := Left.HeuristicCost - Right.HeuristicCost;
    end;

  Visited := TList<TPathItem>.Create;
  Queue := TList<TPathItem>.Create;

  try
    CurrentItem := PathItem(Source, nil, 0, 0);
    Visited.Add(CurrentItem);

    EnqueueNeightbours(CurrentItem);

    while Queue.Count > 0 do
      begin
        CurrentItem := Queue.First;
        Queue.Remove(CurrentItem);

        DoOnPathStep((CurrentItem.CurrentNode)^);

        if CurrentItem.CurrentNode.P = Target.P then
          Break;

        EnqueueNeightbours(CurrentItem);
      end;

    Result := TraceBackPathCount(CurrentItem);
  finally
    Visited.Free;
    Queue.Free;
  end;
end;

constructor TSolver.Create(const ANodes: TStrings; const ASource, ATarget: TPoint);
var
  I: Integer;
  Node: PNode;
begin
  FNodes := TList<TList<PNode>>.Create;
  for I := 0 to ANodes.Count - 1 do
    begin
      Node := TNode.Pointer(ANodes[I]);
      if FNodes.Count <= Node.P.X then
        FNodes.Add(TList<PNode>.Create);

      FNodes[Node.P.X].Add(Node);
    end;
  GetNode(ASource).Source := True;
  GetNode(ATarget).Target := True;

  FPath := TList<PNode>.Create;
end;

destructor TSolver.Destroy;
var
  I: Integer;
  J: Integer;
begin
  for I := 0 to FNodes.Count - 1 do
    begin
      for J := 0 to FNodes[I].Count - 1 do
        Dispose(FNodes[I][J]);

      FNodes[I].Free;
    end;

  FNodes.Free;
  FPath.Free;
  inherited;
end;

procedure TSolver.DoOnPathStep(const Node: TNode);
begin
  if Assigned(FOnPathStep) then
    FOnPathStep(Node);
end;

procedure TSolver.DoOnPathTrace(const Node: TNode);
begin
  if Assigned(FOnPathTrace) then
    FOnPathTrace(Node);
end;

procedure TSolver.DoOnTraceFinish;
begin
  if Assigned(FOnTraceFinish) then
    FOnTraceFinish(Self);
end;

function TSolver.GetEmpty: PNode;
var
  I, J: Integer;
begin
  Result := nil;
  for I := 0 to FNodes.Count - 1 do
    for J := 0 to FNodes[I].Count - 1 do
      if FNodes[I][J].Used = 0 then
        Exit(FNodes[I][J]);
end;

function TSolver.GetNode(const Point: TPoint): PNode;
begin
  Result := FNodes[Point.X][Point.Y];
end;

function TSolver.GetSource: PNode;
var
  I, J: Integer;
begin
  Result := nil;
  for I := 0 to FNodes.Count - 1 do
    for J := 0 to FNodes[I].Count - 1 do
      if FNodes[I][J].Source then
        Exit(FNodes[I][J]);
end;

function TSolver.GetTarget: PNode;
var
  I, J: Integer;
begin
  Result := nil;
  for I := 0 to FNodes.Count - 1 do
    for J := 0 to FNodes[I].Count - 1 do
      if FNodes[I][J].Target then
        Exit(FNodes[I][J]);
end;

function TSolver.Solve: Integer;

  procedure SwapZeroToTarget;
  var
    I: Integer;
  begin
    FPath.Reverse;
    for I := 0 to FPath.Count - 2 do
      TNode.Swap(FPath[I], FPath[I + 1]);

    DoOnTraceFinish;
    FPath.Clear;
  end;

var
  Empty, Target, Source, NextTarget: PNode;
  SourceDirection: TPoint;
begin
  Result := AStar(GetEmpty, GetTarget);
  SwapZeroToTarget;

  Empty := GetEmpty;
  Target := GetTarget;
  Source := GetSource;
  SourceDirection := Source.P - Target.P;
  SourceDirection.X := Sign(SourceDirection.X);
  SourceDirection.Y := Sign(SourceDirection.Y);

  // Hack to avoid target node on empty movement
  Target.Used := 500;

  repeat
    NextTarget := GetNode(Target.P + SourceDirection);
    Inc(Result, AStar(Empty, NextTarget));
    SwapZeroToTarget;
    TNode.Swap(GetEmpty, Target);
    DoOnTraceFinish;
    Empty := GetEmpty;
    Target := GetTarget;
  until NextTarget.P = Source.P;
  Dec(Result);
end;

function TSolver.ViableCount: Integer;
var
  I, J, K, L: Integer;
  A, B: PNode;
begin
  Result := 0;
  for I := 0 to FNodes.Count - 1 do
    for J := 0 to FNodes[I].Count - 1 do
      for K := 0 to FNodes.Count - 1 do
        for L := 0 to FNodes[K].Count - 1 do
      begin
        A := FNodes[I][J];
        B := FNodes[K][L];
        if (A <> B) and (A.Used > 0) and (A.Used <= B.Avail) then
          Inc(Result);
      end;
end;

end.
