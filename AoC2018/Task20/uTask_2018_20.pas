unit uTask_2018_20;

interface

uses
  System.Types, System.Generics.Collections, uTask;

type
  TNeighbours = TList<TPoint>;
  TMap = TObjectDictionary<TPoint,TNeighbours>;

  TTask_AoC = class (TTask)
  private
    FRegExp: String;
    FMap: TMap;
    procedure LoadRegExp;
    function BFS(const Start: TPoint): TDictionary<TPoint,Integer>;
    function FurtherPoint: Integer;
    function RoomsWithMoreThan(const N: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uForm_2018_20;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  FMap := TMap.Create([doOwnsValues]);
  try
    fForm_2018_20 := TfForm_2018_20.Create(nil);
    LoadRegExp;
    fForm_2018_20.DrawMap(FMap, TPoint.Zero);
    fForm_2018_20.ShowModal;
    OK('Part 1: %d, Part 2: %d', [ FurtherPoint, RoomsWithMoreThan(1000) ]);
  finally
    FMap.Free;
  end;
end;

function TTask_AoC.BFS(const Start: TPoint): TDictionary<TPoint,Integer>;
type
  TQueuePair = TPair<TPoint,Integer>;
var
  Queue: TQueue<TQueuePair>;
  Current: TQueuePair;
  Next: TPoint;
begin
  Result := TDictionary<TPoint,Integer>.Create;
  Queue := TQueue<TQueuePair>.Create;

  try
    Queue.Enqueue(TQueuePair.Create(Start, 0));
    while Queue.Count > 0 do
      begin
        Current := Queue.Dequeue;
        for Next in FMap[Current.Key] do
          begin
            if Result.ContainsKey(Next) then
              Continue;
            Result.Add(Next, Current.Value + 1);
            Queue.Enqueue(TQueuePair.Create(Next, Current.Value + 1));
          end;
      end;
  finally
    Queue.Free;
  end;
end;

function TTask_AoC.FurtherPoint: Integer;
var
  Results: TDictionary<TPoint,Integer>;
  Key: TPoint;
begin
  Results := nil;
  try
    Results := BFS(TPoint.Zero);

    // Find further point
    Result := 0;
    for Key in Results.Keys do
      if Results[Key] > Result then
        Result := Results[Key];
  finally
    if Assigned(Results) then
      Results.Free;
  end;
end;

function TTask_AoC.RoomsWithMoreThan(const N: Integer): Integer;
var
  Results: TDictionary<TPoint,Integer>;
  Key: TPoint;
begin
  Results := nil;
  try
    Results := BFS(TPoint.Zero);

    Result := 0;
    for Key in Results.Keys do
      if Results[Key] >= N then
        Inc(Result);
  finally
    if Assigned(Results) then
      Results.Free;
  end;
end;

procedure TTask_AoC.LoadRegExp;

  procedure PushMap(const P1, P2: TPoint);
  begin
    if not FMap.ContainsKey(P1) then
      FMap.Add(P1, TNeighbours.Create);
    FMap[P1].Add(P2);
  end;

  function AddPoint(const C: Char; const P: TPoint): TPoint;
  begin
    case C of
      'N': Result := P + TPoint.Create( 0, -1);
      'S': Result := P + TPoint.Create( 0,  1);
      'W': Result := P + TPoint.Create(-1,  0);
      'E': Result := P + TPoint.Create( 1,  0);
    end;
    PushMap(P, Result);
    PushMap(Result, P);
  end;

  function Contains(const P: TPoint; const A: TArray<TPoint>): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to Length(A) - 1 do
      if A[I] = P then
        Exit(True);
  end;

  function MergeUnique(const A, B: TArray<TPoint>): TArray<TPoint>;
  var
    I: Integer;
  begin
    Result := Copy(A, 0, Length(A));
    for I := 0 to Length(B) - 1 do
      if not Contains(B[I], Result) then
        Insert(B[I], Result, 0);
  end;

  function MakeMap(const Points: TArray<TPoint>): TArray<TPoint>;
  var
    I: Integer;
    C: Char;
    Saved: TArray<TPoint>;
  begin
    Result := Copy(Points, 0, Length(Points));
    while FRegExp.Length > 0 do
      begin
        C := FRegExp[1];
        Delete(FRegExp, 1, 1);
        case C of
          '(':
            Result := MakeMap(Result);
          '|':
            begin
              Saved := Copy(Result, 0, Length(Result));
              Result := Copy(Points, 0, Length(Points));
            end;
          ')':
            Break;
          else
            for I := 0 to Length(Result) - 1 do
              Result[I] := AddPoint(C, Result[I]);
        end;
      end;
    Result := MergeUnique(Result, Saved);
  end;

var
  Points: TArray<TPoint>;
begin
  with Input do
    try
      FRegExp := Text.Trim.Replace('^', '').Replace('$', '');
    finally
      Free;
    end;

  SetLength(Points, 1);
  Points[0] := TPoint.Zero;
  Points := MakeMap(Points);
end;

initialization
  GTask := TTask_AoC.Create(2018, 20, 'A Regular Map');

finalization
  GTask.Free;

end.
