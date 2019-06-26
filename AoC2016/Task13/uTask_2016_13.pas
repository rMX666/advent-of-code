unit uTask_2016_13;

interface

uses
  VCL.Forms, System.Types, uTask, uForm_2016_13;

type
  TTask_AoC = class (TTask)
  private
    FFavoriteNumber: Integer;
    function IsWall(const X, Y: Integer): Boolean;
    function BFS(const A, B: TPoint; const Part: Integer): Integer;
    procedure DrawToForm(const A: TPoint; const DrawType: TDrawType);
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.Generics.Collections, System.SysUtils, System.Math, uUtil;

var
  GTask: TTask_AoC;

type
  TQueuePoint = record
    Current, Previous: TPoint;
    Steps: Integer;
    constructor Create(const ACurrent, APrevious: TPoint; const ASteps: Integer);
  end;

{ TQueuePoint }

constructor TQueuePoint.Create(const ACurrent, APrevious: TPoint; const ASteps: Integer);
begin
  Current := ACurrent;
  Previous := APrevious;
  Steps := ASteps;
end;

{ TTask_AoC }

function TTask_AoC.BFS(const A, B: TPoint; const Part: Integer): Integer;
type
  TQueue = TList<TQueuePoint>;
  TVisited = TDictionary<TPoint,TQueuePoint>;
var
  Queue: TQueue;
  Visited: TVisited;
  Current: TQueuePoint;

  procedure Enqueue(const Current: TQueuePoint);
  const
    DIRECTIONS: array[0..3] of TPoint =
      (
        (X:  0; Y:  1)
      , (X:  0; Y: -1)
      , (X:  1; Y:  0)
      , (X: -1; Y:  0)
      );
  var
    I: Integer;
    Next: TPoint;
  begin
    for I := 0 to 3 do
      begin
        Next := Current.Current + DIRECTIONS[I];

        if (Part = 2) and (Current.Steps + 1 > 50) then
          Continue;
        if IsWall(Next.X, Next.Y) then
          begin
            DrawToForm(Next, dtWall);
            Continue;
          end;
        if Visited.ContainsKey(Next) then
          begin
            if Visited[Next].Steps > Current.Steps + 1 then
              Visited[Next] := TQueuePoint.Create(Next, Current.Current, Current.Steps + 1);

            Continue;
          end;

        DrawToForm(Next, dtStep);

        Queue.Add(TQueuePoint.Create(Next, Current.Current, Current.Steps + 1));
        Visited.Add(Next, Queue.Last);
      end;
  end;

  function BackTrace: Integer;
  begin
    Result := Current.Steps;

    DrawToForm(Current.Current, dtMe);

    while Current.Current <> A do
      begin
        Current := Visited[Current.Previous];
        DrawToForm(Current.Current, dtPath);
      end;
  end;

begin
  Result := 0;
  Queue := TQueue.Create;
  Visited := TVisited.Create;

  try
    Queue.Add(TQueuePoint.Create(A, A, 0));
    Visited.Add(A, Queue.First);

    while Queue.Count > 0 do
      begin
        Current := Queue.First;
        Queue.Delete(0);

        if Part = 1 then
          if Current.Current = B then
            Exit(BackTrace);

        Enqueue(Current);
      end;

    if Part = 2 then
      Result := Visited.Count;
  finally
    Queue.Free;
    Visited.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      FFavoriteNumber := StrToInt(Text.Trim);
    finally
      Free;
    end;

  fMain_2016_13 := TfMain_2016_13.Create(Application);
  fMain_2016_13.Show;

  OK(Format('Part 1: %d', [ BFS(TPoint.Create(1, 1), TPoint.Create(31, 39), 1) ]));
  fMain_2016_13.Reset;
  OK(Format('Part 2: %d', [ BFS(TPoint.Create(1, 1), TPoint.Create(99, 99), 2) ]));
end;

procedure TTask_AoC.DrawToForm(const A: TPoint; const DrawType: TDrawType);
begin
  fMain_2016_13.Draw(A.X, A.Y, DrawType);
end;

function TTask_AoC.IsWall(const X, Y: Integer): Boolean;
begin
  if (X < 0) or (Y < 0) then
    Exit(True);

  Result := BitCount(X*X + 3*X + 2*X*Y + Y + Y*Y + FFavoriteNumber) mod 2 = 1;
end;

initialization
  GTask := TTask_AoC.Create(2016, 13, 'A Maze of Twisty Little Cubicles');

finalization
  GTask.Free;

end.
