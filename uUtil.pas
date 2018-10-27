unit uUtil;

interface

procedure Swap(var A, B: Integer);
procedure GetPermutation(var A: TArray<Integer>; K: Integer);

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

end.
