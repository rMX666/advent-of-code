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
  protected
    function DoGetEnumerator: TEnumerator<TArray<T>>; reintroduce;
  public
    constructor Create(const ASequence: TArray<T>);
    type
      TEnumerator = class(TEnumerator<TArray<T>>)
      private
        FParent: TSubSequences<T>;
        FCurrent: TArray<T>;
        FIndex: Integer;
        FCount: Integer;
        function GetCurrent: TArray<T>;
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

implementation

uses
  System.Math;

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
  FIndex := 0;
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
  Bit: Integer;
  I, L: Integer;
begin
  if FIndex > FCount then
    Exit(False);

  Result := True;
  Inc(FIndex);

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

constructor TSubSequences<T>.Create(const ASequence: TArray<T>);
begin
  FSequence := ASequence;
  TArray.Sort<T>(FSequence);
  FLength := Length(FSequence);
end;

function TSubSequences<T>.DoGetEnumerator: TEnumerator<TArray<T>>;
begin
  Result := GetEnumerator;
end;

function TSubSequences<T>.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

end.
