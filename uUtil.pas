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
    function DoGetEnumerator: TEnumerator<TPermutationItems>;
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

implementation

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

end.
