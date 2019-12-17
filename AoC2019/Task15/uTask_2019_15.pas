unit uTask_2019_15;

interface

uses
  uTask, IntCode, System.Generics.Collections, System.Types;

type
  TRobotDirection = ( rdNorth = 1
                    , rdSouth = 2
                    , rdWest  = 3
                    , rdEast  = 4
                    );
  TMoveResult = ( mrWall
                , mrMoved
                , mrOxygenSystem
                );
  TRobotCode = class (TIntCode)
  private
    FPosition: TPoint;
  public
    constructor Create(const Position: TPoint; const Input: String = ''); overload;
    function PrepareMovement(const Direction: TRobotDirection): TRobotCode;
    function Move: TMoveResult;
    property Position: TPoint read FPosition write FPosition;
  end;

  TTask_AoC = class (TTask)
  private
    FInitialState: TRobotCode;
    procedure LoadProgram;
    function ExploreLevel(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TRobotCode }

constructor TRobotCode.Create(const Position: TPoint; const Input: String);
begin
  inherited Create(Input);
  FPosition := Position;
end;

function TRobotCode.Move: TMoveResult;
begin
  if Execute <> erWaitForInput then
    raise Exception.Create('Weird movement');
  Result := TMoveResult(Output.Last);
end;

function TRobotCode.PrepareMovement(const Direction: TRobotDirection): TRobotCode;
begin
  Result := TRobotCode.Create(Self);
  Result.FPosition := TPoint.Create(FPosition);
  with Result.FPosition do
    case Direction of
      rdNorth: Dec(Y);
      rdSouth: Inc(Y);
      rdWest:  Dec(X);
      rdEast:  Inc(X);
      else
        raise Exception.CreateFmt('Wrong direction: %d', [ Integer(Direction) ]);
    end;
  Result.AddInput(Integer(Direction));
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadProgram;
  try
    OK('Part 1: %d, Part 2: %d', [ ExploreLevel(1), ExploreLevel(2) ]);
  finally
    FInitialState.Free;
  end;
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TRobotCode.Create(TPoint.Zero, Text);
    finally
      Free;
    end;
end;

function TTask_AoC.ExploreLevel(const Part: Integer): Integer;
type
  TVisited = TDictionary<TPoint,TPoint>;
  TRobotQueue = TQueue<TRobotCode>;
var
  Visited: TVisited;
  Front: TVisited;
  Queue, NextQueue: TRobotQueue;
  Current: TRobotCode;
  P: TPoint;

  function NextPoint(const Direction: TRobotDirection): TPoint;
  begin
    Result := Current.Position;
    case Direction of
      rdNorth: Dec(Result.Y);
      rdSouth: Inc(Result.Y);
      rdWest:  Dec(Result.X);
      rdEast:  Inc(Result.X);
    end;
  end;

  procedure EnqueueMovements(Queue: TRobotQueue);
  var
    D: TRobotDirection;
    Next: TPoint;
  begin
    for D := Low(TRobotDirection) to High(TRobotDirection) do
      begin
        Next := NextPoint(D);
        if not Visited.ContainsKey(Next) then
          begin
            Queue.Enqueue(Current.PrepareMovement(D));
            Visited.Add(Next, Current.Position);
          end;
      end;
  end;

  function Traceback: Integer;
  var
    P: TPoint;
  begin
    Result := 0;
    P := Current.Position;
    while Visited.ContainsKey(P) and (P <> Visited[P]) do
      begin
        P := Visited[P];
        Inc(Result);
      end;
  end;

  procedure DrawInLog;
  var
    MinX, MinY, MaxX, MaxY, X, Y: Integer;
    Key: TPoint;
    S: String;
  begin
    MinX := MaxInt;
    MinY := MaxInt;
    MaxX := -MinX;
    MaxY := -MinY;

    for Key in Visited.Keys do
      begin
        if MinX > Key.X then MinX := Key.X;
        if MinY > Key.Y then MinY := Key.Y;
        if MaxX < Key.X then MaxX := Key.X;
        if MaxY < Key.Y then MaxY := Key.Y;
      end;

    X := MinX;
    while X <= MaxX do
      begin
        S := '';
        Y := MinY;
        while Y <= MaxY do
          begin
            Key := TPoint.Create(X, Y);
            if Front.ContainsKey(Key) then
              S := S + 'f'
            else if Key = TPoint.Zero then
              S := S + 'S'
            else if Key = P then
              S := S + 'O'
            else if not Visited.ContainsKey(Key) then
              S := S + ' '
            else if Visited[Key] = TPoint.Zero then
              S := S + '#'
            else
              S := S + '.';
            Inc(Y);
          end;
        Inc(X);
      end;
  end;

begin
  Result := -1;
  Queue := TRobotQueue.Create;
  Visited := TVisited.Create;
  try
    Current := FInitialState;
    Visited.Add(TPoint.Zero, TPoint.Zero);
    EnqueueMovements(Queue);
    while Queue.Count > 0 do
      begin
        Current := Queue.Dequeue;
        try
          case Current.Move of
            mrWall: ; // Dummy
            mrMoved:
              EnqueueMovements(Queue);
            mrOxygenSystem:
              if Part = 1 then
                Exit(Traceback)
              else
                begin
                  P := Current.Position;
                  Break;
                end;
          end;
        finally
          Current.Free;
        end;
      end;
  finally
    while Queue.Count > 0 do
      Queue.Dequeue.Free;
    Queue.Free;
    Visited.Free;
  end;

  if Part <> 2 then
    Exit;

  Result := 0;

  NextQueue := TRobotQueue.Create;
  Queue := TRobotQueue.Create;
  Front := TVisited.Create;
  Visited := TVisited.Create;
  try
    Current := TRobotCode.Create(FInitialState);
    Current.Position := P;
    Visited.Add(P, P);
    try
      EnqueueMovements(Queue);
    finally
      Current.Free;
    end;
    DrawInLog;
    while Queue.Count > 0 do
      begin
        Front.Clear;
        while Queue.Count > 0 do
          begin
            try
              Current := Queue.Dequeue;
              case Current.Move of
                mrWall:
                  Visited[Current.Position] := TPoint.Zero;
                mrMoved:
                  EnqueueMovements(NextQueue);
              end;
            finally
              Current.Free;
            end;
          end;
        while NextQueue.Count > 0 do
          if not Front.ContainsKey(NextQueue.Peek.Position) then
            begin
              Front.Add(NextQueue.Peek.Position, TPoint.Zero);
              Queue.Enqueue(NextQueue.Dequeue);
            end
          else
            NextQueue.Dequeue.Free;
        Inc(Result);
      end;
  finally
    DrawInLog;
    Front.Free;
    while NextQueue.Count > 0 do
      NextQueue.Dequeue.Free;
    NextQueue.Free;
    while Queue.Count > 0 do
      Queue.Dequeue.Free;
    Queue.Free;
    Visited.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 15, 'Oxygen System');

finalization
  GTask.Free;

end.
