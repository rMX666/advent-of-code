unit uSolver_2016_24;

interface

uses
  System.SysUtils, System.Classes, System.RegularExpressions, System.Generics.Collections, System.Generics.Defaults,
  System.Types;

type
  TGraph = array of array of Integer;

  PNode = ^TNode;
  TNode = record
    P: TPoint;
    IsWall: Boolean;
    Number: Integer;
    Distances: TArray<Integer>;
    constructor Create(const AP: TPoint; const AChar: Char);
    class function Pointer(const AP: TPoint; const AChar: Char): PNode; static;
  end;

  TNodeGrid = TDictionary<TPoint,PNode>;

  TOnNodeEvent = procedure (const Node: PNode) of object;
  TOnNodeTraceEvent = procedure (const EndNode, StepNode: PNode) of object;
  TOnGraphCreated = procedure (const Graph: TGraph) of object;

  TSolverPart = ( spFirst, spSecond );

  TSolver = class
  private
    FNodes: TNodeGrid;
    FValueableNodes: TArray<PNode>;
    FOnPathSearchStep: TOnNodeEvent;
    FOnPathTraceStep: TOnNodeTraceEvent;
    FOnGraphCreated: TOnGraphCreated;
    FSolverPart: TSolverPart;
    procedure BFS(const Start: PNode);
    function FindBestPath: Integer;
  protected
    procedure NodesValueNotify(Sender: TObject; const Item: PNode; Action: TCollectionNotification);
    procedure DoOnPathSearchStep(const Node: PNode);
    procedure DoOnPathTraceStep(const EndNode, StepNode: PNode);
    procedure DoOnGraphCreated(const Graph: TGraph);
  public
    constructor Create(const ANodes: TStrings; const ASolverPart: TSolverPart);
    destructor Destroy; override;
    function Solve: Integer;
    property OnPathSearchStep: TOnNodeEvent read FOnPathSearchStep write FOnPathSearchStep;
    property OnPathTraceStep: TOnNodeTraceEvent read FOnPathTraceStep write FOnPathTraceStep;
    property OnGraphCreated: TOnGraphCreated read FOnGraphCreated write FOnGraphCreated;
  end;

implementation

uses
  uUtil;

{ TNode }

constructor TNode.Create(const AP: TPoint; const AChar: Char);
begin
  P := AP;
  IsWall := False;
  Number := -1;
  case AChar of
    '#':      IsWall := True;
    '0'..'9': Number := StrToInt(AChar);
  end;
  SetLength(Distances, 10);
end;

class function TNode.Pointer(const AP: TPoint; const AChar: Char): PNode;
begin
  New(Result);
  Result^ := TNode.Create(AP, AChar);
end;

{ TSolver }

procedure TSolver.BFS(const Start: PNode);
var
  Queue: TQueue<PNode>;
  Visited: TDictionary<PNode, PNode>;
  CurrentNode: PNode;

  function GetNeighbours(const Node: PNode): TArray<PNode>;
  const
    Directions: Array [0..3] of TPoint =
      (
        ( X:  0; Y: -1 ), // U
        ( X:  0; Y:  1 ), // D
        ( X: -1; Y:  0 ), // L
        ( X:  1; Y:  0 )  // R
      );
  var
    I: Integer;
    NextNode: PNode;
  begin
    SetLength(Result, 0);

    for I := 0 to 3 do
      begin
        NextNode := FNodes[Node.P + Directions[I]];

        if NextNode.IsWall then
          Continue;

        if Visited.ContainsKey(NextNode) then
          Continue;

        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := NextNode;
      end;
  end;

  procedure EnqueueNeighbours(const Node: PNode);
  var
    NextNode: PNode;
  begin
    for NextNode in GetNeighbours(Node) do
      begin
        Queue.Enqueue(NextNode);
        Visited.Add(NextNode, Node);
      end;
  end;

  function TraceBack(Node: PNode): Integer;
  var
    NextNode: PNode;
  begin
    Result := 0;
    NextNode := Visited[Node];

    while Assigned(NextNode) do
      begin
        DoOnPathTraceStep(Node, NextNode);
        NextNode := Visited[NextNode];
        Inc(Result);
      end;
  end;

var
  Distance: Integer;
begin
  Queue := TQueue<PNode>.Create;
  Visited := TDictionary<PNode, PNode>.Create;

  Queue.Enqueue(Start);
  Visited.Add(Start, nil);

  try
    while Queue.Count > 0 do
      begin
        CurrentNode := Queue.Dequeue;

        if (CurrentNode.Number > -1) and (CurrentNode <> Start) then
          begin
            Distance := TraceBack(CurrentNode);
            Start.Distances[CurrentNode.Number] := Distance;
            CurrentNode.Distances[Start.Number] := Distance;
          end;

        EnqueueNeighbours(CurrentNode);

        DoOnPathSearchStep(CurrentNode);
      end;
  finally
    Queue.Free;
    Visited.Free;
  end;
end;

function TSolver.FindBestPath: Integer;

  function InitializeGraph: TGraph;
  var
    I, J: Integer;
  begin
    SetLength(Result, Length(FValueableNodes));
    for I := 0 to Length(Result) - 1 do
      begin
        SetLength(Result[I], Length(FValueableNodes));
        for J := 0 to Length(Result) - 1 do
          Result[I, J] := FValueableNodes[I].Distances[J];
      end;
  end;

var
  Graph: TGraph;
  I, NodeCount, PathLength: Integer;
  Indexes, Path, BestPath: TArray<Integer>;
  Permutations: TPermutations;
begin
  Graph := InitializeGraph;
  DoOnGraphCreated(Graph);

  Result := MaxInt;
  NodeCount := Length(Graph);
  Permutations := TPermutations.Create(NodeCount - 1, 1);
  try
    for Indexes in Permutations do
      begin
        Path := Copy(Indexes, 0, NodeCount - 1);
        System.Insert(0, Path, 0);

        if FSolverPart = spSecond then
          System.Insert(0, Path, Length(Path));

        PathLength := 0;
        for I := 0 to Length(Path) - 2 do
          Inc(PathLength, Graph[Path[I], Path[I + 1]]);

        if PathLength < Result then
          begin
            Result := PathLength;
            BestPath := Copy(Path, 0, Length(Path));
          end;
      end;
  finally
    Permutations.Free;
  end;
end;

constructor TSolver.Create(const ANodes: TStrings; const ASolverPart: TSolverPart);
var
  X, Y: Integer;
  Point: TPoint;
begin
  SetLength(FValueableNodes, 0);

  FNodes := TNodeGrid.Create;
  FNodes.OnValueNotify := NodesValueNotify;
  for Y := 0 to ANodes.Count - 1 do
    for X := 0 to ANodes[Y].Length - 1 do
      begin
        Point := TPoint.Create(X, Y);
        FNodes.Add(Point, TNode.Pointer(Point, ANodes[Y][X + 1]));
      end;

  FSolverPart := ASolverPart;
end;

destructor TSolver.Destroy;
var
  Node: PNode;
begin
  for Node in FNodes.Values do
    Dispose(Node);
  FNodes.Free;
  inherited;
end;

procedure TSolver.DoOnGraphCreated(const Graph: TGraph);
begin
  if Assigned(FOnGraphCreated) then
    FOnGraphCreated(Graph);
end;

procedure TSolver.DoOnPathSearchStep(const Node: PNode);
begin
  if Assigned(FOnPathSearchStep) then
    FOnPathSearchStep(Node);
end;

procedure TSolver.DoOnPathTraceStep(const EndNode, StepNode: PNode);
begin
  if Assigned(FOnPathTraceStep) then
    FOnPathTraceStep(EndNode, StepNode);
end;

procedure TSolver.NodesValueNotify(Sender: TObject; const Item: PNode; Action: TCollectionNotification);
begin
  if Action = cnAdded then
    if Item.Number > -1 then
      begin
        if Length(FValueableNodes) <= Item.Number then
          SetLength(FValueableNodes, Item.Number + 1);
        FValueableNodes[Item.Number] := Item;
      end;
end;

function TSolver.Solve: Integer;
var
  Node: PNode;
begin
  for Node in FValueableNodes do
    BFS(Node);

  Result := FindBestPath;
end;

end.
