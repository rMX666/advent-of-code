unit uTask_2018_22;

interface

uses
  System.Types, System.Generics.Collections, uTask;

type
  TMap = class;

  TRegionType = ( rtRocky, rtWet, rtNarrow );
  TResqueTool = ( rtNone, rtTorch, rtClimbingGear );
  TResqueTools = set of TResqueTool;

  TMap = class (TDictionary<TPoint,Integer>)
  private
    FTarget: TPoint;
    FDepth: Integer;
    function GetErosion(const X, Y: Integer): Integer;
    function GetRegionType(const X, Y: Integer): TRegionType;
    function GetAvailableTools(const X, Y: Integer): TResqueTools;
  public
    property Target: TPoint read FTarget write FTarget;
    property Depth: Integer read FDepth write FDepth;
    property Erosion[const X, Y: Integer]: Integer read GetErosion;
    property RegionType[const X, Y: Integer]: TRegionType read GetRegionType;
    property AvailableTools[const X, Y: Integer]: TResqueTools read GetAvailableTools;
    //
    function GetRiskLevel: Integer;
    function GetResqueTime: Integer;
  end;

  TTask_AoC = class (TTask)
  private
    FMap: TMap;
    procedure LoadMaze;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Generics.Defaults;

var
  GTask: TTask_AoC;

{ TMap }

function TMap.GetAvailableTools(const X, Y: Integer): TResqueTools;
begin
  case RegionType[X, Y] of
    rtRocky:  Result := [ rtTorch, rtClimbingGear ];
    rtWet:    Result := [ rtNone, rtClimbingGear ];
    rtNarrow: Result := [ rtNone, rtTorch ];
  end;
end;

function TMap.GetErosion(const X, Y: Integer): Integer;

  function CalcErosion(const X, Y: Integer): Integer;
  var
    GI: Integer;
  begin
    if (X < 0) or (Y < 0) then
      raise Exception.Create('Wrong cordinate');

    if ((X = 0) and (Y = 0)) or ((X = FTarget.X) and (Y = FTarget.Y)) then
      GI := 0
    else if X = 0 then
      GI := Y * 48271
    else if Y = 0 then
      GI := X * 16807
    else
      GI := Erosion[X - 1, Y] * Erosion[X, Y - 1];

    Result := (GI + FDepth) mod 20183;
  end;

var
  P: TPoint;
begin
  P := TPoint.Create(X, Y);
  if not ContainsKey(P) then
    Add(P, CalcErosion(X, Y));
  Result := Items[P];
end;

function TMap.GetRegionType(const X, Y: Integer): TRegionType;
begin
  Result := TRegionType(Erosion[X, Y] mod 3);
end;

function TMap.GetResqueTime: Integer;
type
  TSpentTime = Integer;
  TVisitedItem = TPair<TPoint, TResqueTool>;
  TQueueItem = TPair<TVisitedItem, TSpentTime>;
  TVisited = TDictionary<TVisitedItem, TSpentTime>;
  TVisitQueue = TList<TQueueItem>;
const
  Directions: array [0..3] of TPoint =
    ( ( X: -1; Y:  0 ), ( X:  1; Y:  0 ), ( X:  0; Y: -1 ), ( X:  0; Y:  1 ) );
var
  Visited: TVisited;
  Queue: TVisitQueue;
  QueueComparison: TComparison<TQueueItem>;
  Current: TQueueItem;
  BestTime: Integer;

  procedure CleanQueue(Item: TQueueItem);
  var
    Index: Integer;
  begin
    Inc(Item.Value);
    Queue.BinarySearch(Item, Index);
    Queue.DeleteRange(Index, Queue.Count - Index);
  end;

  procedure Enqueue(const Item: TQueueItem);
  var
    Index: Integer;
  begin
    Queue.BinarySearch(Item, Index);
    Queue.Insert(Index, Item);
  end;

  function Visit(const Item: TQueueItem): Boolean;
  begin
    with Item do
      begin
        Result := Visited.ContainsKey(Key);
        if not Result then
          Visited.Add(Key, Value)
        else
          if Visited[Key] > Value then
            begin
              Visited[Key] := Value;
              Exit(False);
            end;
      end;
  end;

  function EnqueueNeighbours(const Current: TQueueItem): Integer;
  var
    I: Integer;
    Tool: TResqueTool;
    Tools: TResqueTools;
    Next: TQueueItem;
  begin
    Result := -1;

    if Current.Value > BestTime then
      Exit;

    for I := 0 to 3 do
      begin
        with Next.Key do
          begin
            Key := Current.Key.Key + Directions[I];
            if Key.X < 0 then Continue;
            if Key.Y < 0 then Continue;
            Tools := AvailableTools[Key.X, Key.Y];
          end;

        for Tool in Tools do
          begin
            Next.Key.Value := Tool;
            Next.Value := Current.Value + 1;
            if Current.Key.Value <> Tool then
              Inc(Next.Value, 7);

            if (FTarget = Next.Key.Key) and (Tool = rtTorch) then
              begin
                if BestTime > Next.Value then
                  BestTime := Next.Value;
                Continue;
              end;

            if Visit(Next) then Continue;

            Enqueue(Next);
          end;
      end;
  end;

begin
  BestTime := MaxInt;

  QueueComparison := function (const Left, Right: TQueueItem): Integer
    begin
      Result := Left.Value - Right.Value;
      if Result = 0 then
        Result := (Abs(Left.Key.Key.X - FTarget.X) + Abs(Left.Key.Key.Y - FTarget.Y)) -
          (Abs(Right.Key.Key.X - FTarget.X) + Abs(Right.Key.Key.Y - FTarget.Y));
    end;
  Queue := TVisitQueue.Create(TComparer<TQueueItem>.Construct(QueueComparison));
  Visited := TVisited.Create;

  try
    Queue.Add(TQueueItem.Create(TVisitedItem.Create(TPoint.Create(0, 0), rtTorch), 0));
    Visited.Add(Queue.First.Key, Queue.First.Value);

    while Queue.Count > 0 do
      begin
        Current := Queue.First;
        Queue.Delete(0);
        EnqueueNeighbours(Current);
      end;

    Result := BestTime;
  finally
    Queue.Free;
    Visited.Free;
  end;
end;

function TMap.GetRiskLevel: Integer;
var
  X, Y: Integer;
begin
  Result := 0;

  for X := 0 to FTarget.X do
    for Y := 0 to FTarget.Y do
      Inc(Result, Integer(RegionType[X, Y]));
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadMaze;

    OK('Part 1: %d, Part 2: %d', [ FMap.GetRiskLevel, FMap.GetResqueTime ]);
  finally
    FMap.Free;
  end;
end;

procedure TTask_AoC.LoadMaze;
begin
  FMap := TMap.Create;

  with Input do
    try
      FMap.Depth := Strings[0].Split([' '])[1].ToInteger;
      FMap.Target := TPoint.Create(Strings[1].Split([' '])[1].Split([','])[0].ToInteger,
                                   Strings[1].Split([' '])[1].Split([','])[1].ToInteger);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 22, 'Mode Maze');

finalization
  GTask.Free;

end.
