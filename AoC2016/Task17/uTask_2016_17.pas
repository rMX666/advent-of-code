unit uTask_2016_17;

interface

uses
  System.Types, System.Classes, System.Generics.Collections, System.Generics.Defaults, uTask;

type
  TPath = record
    Path: String;
    Point: TPoint;
    constructor Create(const APath: String; const APoint: TPoint);
    function Move(const Direction: Char): TPath;
  end;

  TPathComparer = class(TCustomComparer<TPath>)
  public
    function Compare(const Left, Right: TPath): Integer; override;
    function Equals(const Left, Right: TPath): Boolean; reintroduce; overload; override;
  end;

  TTask_AoC = class (TTask)
  private const
    START: TPoint  = ( X: 0; Y: 0 );
    FINISH: TPoint = ( X: 3; Y: 3 );
  private
    FSalt: String;
    function GetDirections(const Path: String; const Point: TPoint): TArray<Char>;
    procedure FindMinMaxPath(out OMin, OMax: String);
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, IdHashMessageDigest, idHash;

var
  GTask: TTask_AoC;

{ TPath }

constructor TPath.Create(const APath: String; const APoint: TPoint);
begin
  Path := APath;
  Point := APoint;
end;

function TPath.Move(const Direction: Char): TPath;
var
  Next: TPoint;
begin
  Next := TPoint.Create(Point);
  case Direction of
    'U': Dec(Next.Y);
    'D': Inc(Next.Y);
    'L': Dec(Next.X);
    'R': Inc(Next.X);
  end;
  Result := TPath.Create(Path + Direction, Next);
end;

{ TPathComparer }

function TPathComparer.Compare(const Left, Right: TPath): Integer;
begin
  if Equals(Left, Right) then
    Exit(0);

  if Left.Path > Right.Path then
    Exit(1)
  else if Left.Path < Right.Path then
    Exit(-1)
  else
    Exit(0);
end;

function TPathComparer.Equals(const Left, Right: TPath): Boolean;
begin
  Result := (Left.Path = Right.Path) and (Left.Point = Right.Point);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  Part1, Part2: String;
  I: Integer;
begin
  with Input do
    try
      FSalt := Text.Trim;
    finally
      Free;
    end;

  FindMinMaxPath(Part1, Part2);
  OK(Format('Part 1: %s, Part 2: %d', [ Part1, Part2.Length ]));
end;

procedure TTask_AoC.FindMinMaxPath(out OMin, OMax: String);
type
  TPathList = TList<TPath>;
  TPathQueue = TQueue<TPath>;
var
  Visited: TPathList;
  Queue: TPathQueue;
  PathComparer: TPathComparer;
  Current, Next: TPath;
  Directions: TArray<Char>;
  I: Integer;
begin
  PathComparer := TPathComparer.Create;
  Visited := TPathList.Create(PathComparer);
  Queue := TPathQueue.Create;

  try
    Queue.Enqueue(TPath.Create('', START));
    while Queue.Count > 0 do
      begin
        Current := Queue.Dequeue;
        Visited.Add(Current);
        Directions := GetDirections(Current.Path, Current.Point);
        for I := 0 to Length(Directions) - 1 do
          begin
            Next := Current.Move(Directions[I]);
            if Next.Point = FINISH then
              begin
                if (Next.Path.Length < OMin.Length) or (OMin = '') then
                  OMin := Next.Path;
                if Next.Path.Length > OMax.Length then
                  OMax := Next.Path;
              end
            else if not Visited.Contains(Next) then
              Queue.Enqueue(Next);
          end;
      end;
  finally
    FreeAndNil(Queue);
    FreeAndNil(Visited);
    FreeAndNil(PathComparer);
  end;
end;

function TTask_AoC.GetDirections(const Path: String; const Point: TPoint): TArray<Char>;
const
  Directions: array[0..3] of Char = ( 'U', 'D', 'L', 'R' );

  function CanGo(const Direction: Char): Boolean;
  begin
    Result := False;
    case Direction of
      'U': Result := Point.Y > START.Y;
      'D': Result := Point.Y < FINISH.Y;
      'L': Result := Point.X > START.X;
      'R': Result := Point.X < FINISH.X;
    end;
  end;

var
  Hash: String;
  I: Integer;
begin
  SetLength(Result, 0);
  with TIdHashMessageDigest5.Create do
    try
      Hash := HashStringAsHex(FSalt + Path).ToLower.Substring(0, 4);
      for I := 1 to Hash.Length do
        if (Hash[I] in ['b'..'f']) and CanGo(Directions[I - 1]) then
          begin
            SetLength(Result, Length(Result) + 1);
            Result[Length(Result) - 1] := Directions[I - 1];
          end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 17, 'Two Steps Forward');

finalization
  GTask.Free;

end.
