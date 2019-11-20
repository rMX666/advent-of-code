unit uSet_2016_11;

interface

uses
  System.SysUtils;

type
  TItemType = ( itMicrochip, itGenerator );
  TItemName = (  // Bit numbers
    inCobalt     = 0
  , inDilithium  = 2
  , inElerium    = 4
  , inPolonium   = 6
  , inPromethium = 8
  , inRuthenium  = 10
  , inThulium    = 12
  );
  TItemNames = set of TItemName;

  TItemNamesEx = record
  private
    FSet: TArray<TItemName>;
    function GetCount: Integer;
    function GetItem(const Index: Integer): TItemName;
    procedure SetItem(const Index: Integer; const Value: TItemName);
  public
    constructor Create(const Values: TItemNames);
    procedure Add(const Value: TItemName);
    procedure AddRange(const Values: TItemNames); overload;
    procedure AddRange(const Values: TItemNamesEx); overload;
    procedure Remove(const Value: TItemName); overload;
    procedure Remove(const Index: Integer); overload;
    function Contains(const Value: TItemName): Boolean;
    function ToSet: TItemNames;
    function ToArray: TArray<TItemName>;
    property Count: Integer read GetCount;
    property Items[const Index: Integer]: TItemName read GetItem write SetItem; default;
    class operator Add(const A, B: TItemNamesEx): TItemNamesEx;
    class operator Subtract(const A, B: TItemNamesEx): TItemNamesEx;
    class operator Multiply(const A, B: TItemNamesEx): TItemNamesEx;
    class operator Equal(const A, B: TItemNamesEx): Boolean;
    class operator Implicit(const A: TItemNames): TItemNamesEx;
    class operator Explicit(const A: TArray<TItemName>): TItemNamesEx;
  end;

implementation

{ TItemNames }

constructor TItemNamesEx.Create(const Values: TItemNames);
var
  Item: TItemName;
begin
  SetLength(FSet, 0);
  for Item in Values do
    System.Insert(Item, FSet, 0);
end;

function TItemNamesEx.Contains(const Value: TItemName): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if FSet[I] = Value then
      Exit(True);
end;

class operator TItemNamesEx.Implicit(const A: TItemNames): TItemNamesEx;
begin
  Result := TItemNamesEx.Create(A);
end;

class operator TItemNamesEx.Explicit(const A: TArray<TItemName>): TItemNamesEx;
begin
  Result.FSet := Copy(A);
end;

class operator TItemNamesEx.Add(const A, B: TItemNamesEx): TItemNamesEx;
var
  I: Integer;
begin
  Result := TItemNamesEx.Create(A.ToSet);
  for I := 0 to B.Count - 1 do
    Result.Add(B[I]);
end;

class operator TItemNamesEx.Subtract(const A, B: TItemNamesEx): TItemNamesEx;
var
  I: Integer;
begin
  Result := TItemNamesEx.Create([]);
  for I := 0 to A.Count - 1 do
    if not B.Contains(A[I]) then
      Result.Add(A[I]);
end;

class operator TItemNamesEx.Multiply(const A, B: TItemNamesEx): TItemNamesEx;
var
  I: Integer;
begin
  Result := TItemNamesEx.Create([]);
  for I := 0 to A.Count - 1 do
    if B.Contains(A[I]) then
      Result.Add(A[I]);
end;

class operator TItemNamesEx.Equal(const A, B: TItemNamesEx): Boolean;
var
  I: Integer;
begin
  Result := A.Count = B.Count;
  if Result then
    for I := 0 to A.Count - 1 do
      if not (B.Contains(A[I]) and A.Contains(B[I])) then
        Exit(False);
end;

procedure TItemNamesEx.Add(const Value: TItemName);
begin
  if not Contains(Value) then
    System.Insert(Value, FSet, 0);
end;

procedure TItemNamesEx.AddRange(const Values: TItemNames);
begin
  AddRange(TItemNamesEx.Create(Values));
end;

procedure TItemNamesEx.AddRange(const Values: TItemNamesEx);
var
  I: Integer;
begin
  for I := 0 to Values.Count - 1 do
    Add(Values[I]);
end;

procedure TItemNamesEx.Remove(const Value: TItemName);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I] = Value then
      begin
        Remove(I);
        Break;
      end;
end;

procedure TItemNamesEx.Remove(const Index: Integer);
begin
  if (Index < 0) or (Index >= Count) then
    raise EArgumentOutOfRangeException.Create('TItemNamesEx.Remove argment Index is out of range');
  System.Delete(FSet, Index, 1);
end;

function TItemNamesEx.GetCount: Integer;
begin
  Result := Length(FSet);
end;

function TItemNamesEx.GetItem(const Index: Integer): TItemName;
begin
  Result := FSet[Index];
end;

procedure TItemNamesEx.SetItem(const Index: Integer; const Value: TItemName);
begin
  FSet[Index] := Value;
end;

function TItemNamesEx.ToArray: TArray<TItemName>;
begin
  Result := Copy(FSet);
end;

function TItemNamesEx.ToSet: TItemNames;
var
  I: Integer;
begin
  Result := [];
  for I := 0 to Count - 1 do
    Include(Result, Items[I]);
end;

end.
