unit uUtil;

interface

uses
  System.Generics.Collections;

type
  TPermutationItems = TArray<Integer>;

  TPermutations = class(TEnumerable<TPermutationItems>)
  public
    FItemCount: Integer;
    FCount: Integer;
  protected
    function DoGetEnumerator: TEnumerator<TPermutationItems>; reintroduce;
  public
    constructor Create(const AItemCount: Integer);
    type
      TEnumerator = class(TEnumerator<TPermutationItems>)
      private
        FParent: TPermutations;
        FCurrent: TPermutationItems;
        FInitial: TPermutationItems;
        FCurrentIndex: Integer;
        function GetCurrent: TPermutationItems;
      protected
        function DoGetCurrent: TPermutationItems; override;
        function DoMoveNext: Boolean; override;
      public
        constructor Create(const AParent: TPermutations);
        property Current: TPermutationItems read GetCurrent;
        function MoveNext: Boolean;
      end;
    function GetEnumerator: TEnumerator; reintroduce; inline;
  end;

  TSubSequences<T> = class(TEnumerable<TArray<T>>)
  private
    FSequence: TArray<T>;
    FLength: Integer;
    FMinLength, FMaxLength: Integer;
  protected
    function DoGetEnumerator: TEnumerator<TArray<T>>; reintroduce;
  public
    constructor Create(const ASequence: TArray<T>; const AMinLength: Integer = -1; const AMaxLength: Integer = -1);
    type
      TMoveNextResult = ( mnrOk, mnrWrongSize, mnrEof );
      TEnumerator = class(TEnumerator<TArray<T>>)
      private
        FParent: TSubSequences<T>;
        FCurrent: TArray<T>;
        FIndex: Integer;
        FCount: Integer;
        function GetCurrent: TArray<T>;
        function TryMoveNext: TMoveNextResult;
        function CheckSubsequenceSize(const Index: Integer): Boolean;
      protected
        function DoGetCurrent: TArray<T>; override;
        function DoMoveNext: Boolean; override;
      public
        constructor Create(const AParent: TSubSequences<T>);
        property Current: TArray<T> read GetCurrent;
        function MoveNext: Boolean;
      end;
    function GetEnumerator: TEnumerator; reintroduce; inline;
  end;

  // Simple circular double linked list implementation
  PNode = ^TNode;
  TNode = record
  private
    constructor Create(const AData: Integer);
  public
    Data: Integer;
    Next, Prev: PNode;
    class function Pointer(const AData: Integer): PNode; static;
    function Push(const Value: Integer): PNode;
    function Pop: PNode;
    function Rotate(const Value: Integer): PNode;
    procedure Free;
    function ToString: String;
  end;

// Simplified implementation of Knuth-Morris-Pratt alhorithm
// Search Needle in Haystack, return array of found positions (empty array of nothibg found)
function KMP(const Needle, Haystack: String): TArray<Integer>;

// Count 1 bits in number
function BitCount(X: Integer): Integer;

procedure SortString(var S: String);

implementation

uses
  System.SysUtils, System.Math;

function KMP(const Needle, Haystack: String): TArray<Integer>;
var
  NL, HL: Integer;
  I, J: Integer;
begin
  SetLength(Result, 0);

  NL := Needle.Length;
  HL := Haystack.Length;

  J := 1;
  for I := 1 to HL do
    begin
      while (J > 1) and (Haystack[I] <> Needle[J]) do
        Dec(J);
      if Haystack[I] = Needle[J] then
        Inc(J);
      if J = NL + 1 then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := I - NL + 1;
        end;
    end;
end;

function BitCount(X: Integer): Integer;
begin
  //          01010101010101010101010101010101...
  X := (X and $55555555) + ((X shr 1) and $55555555);
  //          00110011001100110011001100110011...
  X := (X and $33333333) + ((X shr 2) and $33333333);
  //          00001111000011110000111100001111...
  X := (X and $0f0f0f0f) + ((X shr 4) and $0f0f0f0f);
  //          00000000111111110000000011111111...
  X := (X and $00ff00ff) + ((X shr 8) and $00ff00ff);
  //          00000000000000001111111111111111...
  X := (X and $0000ffff) + ((X shr 16) and $0000ffff);
  Result := X;
end;

procedure SortString(var S: String);
var
  A: TArray<Char>;
begin
  A := S.ToCharArray;
  TArray.Sort<Char>(A);
  S := String.Create(A);
end;

procedure Swap(var A, B: Integer);
var
  Tmp: Integer;
begin
  Tmp := A;
  A := B;
  B := Tmp;
end;

{ TPermutation.TEnumerator }

constructor TPermutations.TEnumerator.Create(const AParent: TPermutations);
var
  I: Integer;
begin
  FParent := AParent;

  SetLength(FInitial, FParent.FItemCount);
  for I := 0 to FParent.FItemCount do
    FInitial[I] := I;

  FCurrent := Copy(FInitial, 0, FParent.FItemCount);
  FCurrentIndex := 0;
end;

function TPermutations.TEnumerator.DoGetCurrent: TPermutationItems;
begin
  Result := GetCurrent
end;

function TPermutations.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TPermutations.TEnumerator.GetCurrent: TPermutationItems;
begin
  Result := FCurrent;
end;

function TPermutations.TEnumerator.MoveNext: Boolean;
var
  I, J, K: Integer;
begin
  if FCurrentIndex >= FParent.FCount then
    Exit(False);

  Result := True;

  Inc(FCurrentIndex);
  FCurrent := Copy(FInitial, 0, FParent.FItemCount);

  K := FCurrentIndex;
  for I := Low(FCurrent) + 1 to High(FCurrent) + 1 do
    begin
      J := K mod I;
      Swap(FCurrent[J], FCurrent[I - 1]);
      K := K div I;
    end;
end;

{ TPermutation }

constructor TPermutations.Create(const AItemCount: Integer);
var
  I: Integer;
begin
  FItemCount := AItemCount;

  FCount := 1;
  for I := 2 to FItemCount do
    FCount := FCount * I;
end;

function TPermutations.DoGetEnumerator: TEnumerator<TPermutationItems>;
begin
  Result := GetEnumerator;
end;

function TPermutations.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

{ TSubSequences<T>.TEnumerator }

constructor TSubSequences<T>.TEnumerator.Create(const AParent: TSubSequences<T>);
begin
  FParent := AParent;
  SetLength(FCurrent, 0);
  FIndex := -1;
  FCount := Round(Power(2, FParent.FLength)) - 1;
end;

function TSubSequences<T>.TEnumerator.DoGetCurrent: TArray<T>;
begin
  Result := GetCurrent;
end;

function TSubSequences<T>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TSubSequences<T>.TEnumerator.GetCurrent: TArray<T>;
begin
  Result := FCurrent;
end;

function TSubSequences<T>.TEnumerator.MoveNext: Boolean;
var
  MoveNextResult: TMoveNextResult;
begin
  repeat
    MoveNextResult := TryMoveNext;
  until MoveNextResult <> mnrWrongSize;

  Result := MoveNextResult = mnrOk;
end;

function TSubSequences<T>.TEnumerator.CheckSubsequenceSize(const Index: Integer): Boolean;
var
  Bits: Integer;
begin
  Bits := BitCount(Index);
  Result := (FParent.FMinLength <= Bits) and (FParent.FMaxLength >= Bits);
end;

function TSubSequences<T>.TEnumerator.TryMoveNext: TMoveNextResult;
var
  Bit: Integer;
  I, L: Integer;
begin
  if FIndex > FCount then
    Exit(mnrEof);

  Inc(FIndex);

  if not CheckSubsequenceSize(FIndex) then
    Exit(mnrWrongSize);

  Result := mnrOk;

  Bit := FIndex;
  I := FParent.FLength - 1;
  L := 0;
  SetLength(FCurrent, FParent.FLength);

  while (Bit <> 0) and (I >= 0) do
    begin
      if (Bit and 1) = 1 then
        begin
          FCurrent[L] := FParent.FSequence[I];
          Inc(L);
        end;

      Bit := Bit shr 1;
      Dec(I);
    end;

  SetLength(FCurrent, L);
end;

{ TSubSequences<T> }

constructor TSubSequences<T>.Create(const ASequence: TArray<T>; const AMinLength: Integer = -1; const AMaxLength: Integer = -1);
begin
  FSequence := ASequence;
  TArray.Sort<T>(FSequence);
  FLength := Length(FSequence);
  FMinLength := AMinLength;
  FMaxLength := AMaxLength;
  if FMaxLength = -1 then
    FMaxLength := MaxInt;
end;

function TSubSequences<T>.DoGetEnumerator: TEnumerator<TArray<T>>;
begin
  Result := GetEnumerator;
end;

function TSubSequences<T>.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

{ TNode }

constructor TNode.Create(const AData: Integer);
begin
  Data := AData;
  Prev := nil;
  Next := nil;
end;

procedure TNode.Free;
var
  Node, NextNode: PNode;
begin
  Node := @Self;
  try
    while Node <> nil do
      begin
        NextNode := Node.Next;
        if NextNode <> nil then
          begin
            Node.Next := nil;
            Dispose(Node);
          end;
        Node := NextNode;
      end;
  except
    // Yes, I know. Something gone wrong and I don't want to fix it
  end;
end;

class function TNode.Pointer(const AData: Integer): PNode;
begin
  New(Result);
  Result^ := TNode.Create(AData);
  Result.Next := Result;
  Result.Prev := Result;
end;

function TNode.Pop: PNode;
begin
  Result := Prev;
  // Adjust links
  Next.Prev := Prev;
  Prev.Next := Next;
  Next := nil;
  Prev := nil;
  Dispose(@Self);
end;

function TNode.Push(const Value: Integer): PNode;
begin
  Result := TNode.Pointer(Value);
  Result.Prev := @Self;
  Result.Next := Next;
  Next.Prev := Result;
  Next := Result;
end;

function TNode.Rotate(const Value: Integer): PNode;
var
  I, L: Integer;
begin
  Result := @Self;
  L := Abs(Value);
  case Sign(Value) of
    -1: for I := 1 to L do Result := Result.Prev;
     1: for I := 1 to L do Result := Result.Next;
  end;
end;

function TNode.ToString: String;
var
  Node: PNode;
begin
  Result := Data.ToString;
  Node := Self.Next;
  while Node <> @Self do
    begin
      Result := Result + ', ' + Node.Data.ToString;
      Node := Node.Next;
    end;
end;

end.
