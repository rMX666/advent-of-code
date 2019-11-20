unit Generics.PriorityQueue;

{
  Array heap based generic priority queue implementation.
  Inspired by https://cs.nyu.edu/courses/spring12/CSCI-GA.3033-014/Assignment3/heap.html
}

interface

uses
  System.SysUtils, System.Generics.Defaults;

type
  EPriorityQueue        = Exception;
  EWrongCompareFunction = class(EPriorityQueue);
  EQueueIsEmpty         = class(EPriorityQueue);

  TPriorityQueue<T> = class
  strict private type
    TArrayT = TArray<T>;
  private
    FQueue: TArrayT;
    FSize: Integer;
    FCapacity: Integer;
    FComparer: IComparer<T>;
    function DoCompare(const A, B: T): Integer;
    procedure Grow;
    procedure Trim;
    procedure RebalanceDownFrom(I: Integer = 0);
    function GetIsEmpty: Boolean;
    procedure SetSize(const Value: Integer);
    procedure SetCapacity(const Value: Integer);
  public
    constructor Create(const AComparer: IComparer<T> = nil);
    function Clone: TPriorityQueue<T>;
    procedure Push(const Value: T);
    function Pop: T;
    function Peek: T;
    function Contains(const Value: T): Boolean;
    property IsEmpty: Boolean read GetIsEmpty;
    property Size: Integer read FSize write SetSize;
  end;

  TObjectPriorityQueue<T: class> = class(TPriorityQueue<T>)
  private
    FOwnsObjects: Boolean;
  public
    constructor Create(const AComparer: IComparer<T> = nil; const OwnsObjects: Boolean = True);
    destructor Destroy; override;
  end;

resourcestring
  rsWrongCompareFunciton = 'Compare function cannot be nil';
  rsQueueIsEmpty         = 'Queue is empty';

implementation

{ TPriorityQueue<T> }

constructor TPriorityQueue<T>.Create(const AComparer: IComparer<T> = nil);
begin
  if AComparer = nil then
    FComparer := TComparer<T>.Default
  else
    FComparer := AComparer;
  SetCapacity(1);
end;

function TPriorityQueue<T>.Clone: TPriorityQueue<T>;
begin
  Result := TPriorityQueue<T>.Create(FComparer);
  Result.FQueue := Copy(FQueue, 0, FCapacity);
  Result.FCapacity := FCapacity;
  Result.FSize := FSize;
end;

function TPriorityQueue<T>.DoCompare(const A, B: T): Integer;
begin
  Result := FComparer.Compare(A, B);
  if Result < 0 then
    Result := -1
  else if Result > 0 then
    Result := 1;
end;

function TPriorityQueue<T>.GetIsEmpty: Boolean;
begin
  Result := FSize = 0;
end;

function TPriorityQueue<T>.Peek: T;
begin
  if IsEmpty then
    raise EQueueIsEmpty.Create(rsQueueIsEmpty);
  Result := FQueue[0];
end;

function TPriorityQueue<T>.Pop: T;
begin
  Result := Peek;
  FQueue[0] := FQueue[FSize - 1];
  Size := Size - 1;
  RebalanceDownFrom;
end;

procedure TPriorityQueue<T>.Push(const Value: T);
var
  I, P: Integer;
begin
  I := FSize;
  Size := Size + 1;

  while I > 0 do
    begin
      P := (I - 1) shr 1;
      if DoCompare(Value, FQueue[P]) >= 0 then
        Break;
      FQueue[I] := FQueue[P];
      I := P;
    end;

  FQueue[I] := Value;
end;

procedure TPriorityQueue<T>.RebalanceDownFrom(I: Integer);
var
  L, R, HalfSize: Integer;
  First, Best: T;
begin
  First := FQueue[I];
  HalfSize := FSize shr 1;

  while I < HalfSize do
    begin
      L := (I shl 1) + 1;
      R := L + 1;
      Best := FQueue[L];
      if (R < FSize) and (DoCompare(FQueue[R], Best) < 0) then
        begin
          L := R;
          Best := FQueue[R];
        end;
      if DoCompare(Best, First) >= 0 then
        Break;
      FQueue[I] := Best;
      I := L;
    end;

  FQueue[I] := First;
end;

procedure TPriorityQueue<T>.Grow;
begin
  if FSize > FCapacity then
    SetCapacity(FCapacity shl 1);
end;

procedure TPriorityQueue<T>.Trim;
begin
  if FSize < FCapacity shr 1 then
    SetCapacity(FCapacity shr 1);
end;

procedure TPriorityQueue<T>.SetSize(const Value: Integer);
var
  OldSize: Integer;
begin
  OldSize := FSize;
  FSize := Value;
  if OldSize < Value then
    Grow
  else if OldSize > Value then
    Trim;
end;

procedure TPriorityQueue<T>.SetCapacity(const Value: Integer);
begin
  FCapacity := Value;
  SetLength(FQueue, FCapacity);
end;

function TPriorityQueue<T>.Contains(const Value: T): Boolean;
var
  I: Integer;
begin
  Result := False;
  I := 0;
  while I < FSize do
    case DoCompare(FQueue[I], Value) of
      -1: I := (I shl 1) + 1;
       0: Exit(True);
       1: I := (I shl 1) + 2;
    end;
end;

{ TObjectPriorityQueue<T> }

constructor TObjectPriorityQueue<T>.Create(const AComparer: IComparer<T>; const OwnsObjects: Boolean);
begin
  inherited Create(AComparer);
  FOwnsObjects := OwnsObjects;
end;

destructor TObjectPriorityQueue<T>.Destroy;
var
  I: Integer;
begin
  if FOwnsObjects then
    for I := 0 to FSize - 1 do
      FreeAndNil(FQueue[I]);
  inherited;
end;

end.
