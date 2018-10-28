unit uUtil;

interface

type
  TPermutationHandler = reference to procedure (const Permutation: TArray<Integer>);

procedure Swap(var A, B: Integer);
procedure GetPermutation(var A: TArray<Integer>; K: Integer);
function GetPermutationCount(const ItemCount: Integer): Integer;
procedure RunPermutations(const ItemCount: Integer; const Handler: TPermutationHandler);

implementation

procedure Swap(var A, B: Integer);
var
  Tmp: Integer;
begin
  Tmp := A;
  A := B;
  B := Tmp;
end;

procedure GetPermutation(var A: TArray<Integer>; K: Integer);
var
  I, J: Integer;
begin
  for I := Low(A) + 1 to High(A) + 1 do
    begin
      J := K mod I;
      Swap(A[J], A[I - 1]);
      K := K div I;
    end;
end;

function GetPermutationCount(const ItemCount: Integer): Integer;
var
  I: Integer;
begin
  Result := 1;

  for I := 2 to ItemCount do
    Result := Result * I;
end;

procedure RunPermutations(const ItemCount: Integer; const Handler: TPermutationHandler);
var
  I, K: Integer;
  Items, NextItems: TArray<Integer>;
begin
  SetLength(Items, ItemCount);
  for I := 0 to ItemCount - 1 do
    Items[I] := I;

  K := GetPermutationCount(ItemCount);

  for I := 1 to K do
    begin
      NextItems := Copy(Items, 0, ItemCount);
      GetPermutation(NextItems, I);
      Handler(NextItems);
    end;
end;

end.
