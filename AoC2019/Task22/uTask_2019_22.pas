unit uTask_2019_22;

interface

uses
  uTask, System.Generics.Collections;

type
  TTechniqueType = ( ttStack, ttCut, ttIncrement );
  TTechnique = record
    TechniqueType: TTechniqueType;
    N: Int64;
    constructor Create(const S: String); overload;
    constructor Create(const TechniqueType: TTechniqueType; const N: Int64); overload;
  end;

  TTechniques = TList<TTechnique>;

  TTask_AoC = class (TTask)
  private
    FTechniques: TTechniques;
    procedure LoadTechniques;
    function TryTechniques: Integer;
    function TryHardTechniques: Integer;
    function SimplifyAt(const I: Integer; const DeckSize: Int64): Boolean;
    procedure Simplify(const DeckSize: Int64);
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uUtil;

var
  GTask: TTask_AoC;

{ TTechnique }

constructor TTechnique.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Split([' ']);
  if A[0] = 'cut' then
    begin
      TechniqueType := ttCut;
      N := A[1].ToInteger;
    end
  else if (A[0] = 'deal') and (A[2] = 'increment') then
    begin
      TechniqueType := ttIncrement;
      N := A[3].ToInteger;
    end
  else if (A[0] = 'deal') and (A[2] = 'new') then
    TechniqueType := ttStack
  else
    raise Exception.CreateFmt('Wrong operation: %s', [ S ]);
end;

constructor TTechnique.Create(const TechniqueType: TTechniqueType; const N: Int64);
begin
  Self.TechniqueType := TechniqueType;
  Self.N := N;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  OK('Part 1: %d, Part 2: %d', [ TryTechniques, TryHardTechniques ]);
end;

procedure TTask_AoC.LoadTechniques;
var
  I: Integer;
begin
  FTechniques := TTechniques.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FTechniques.Add(TTechnique.Create(Strings[I]));
    finally
      Free;
    end;
end;

function TTask_AoC.SimplifyAt(const I: Integer; const DeckSize: Int64): Boolean;
var
  T1, T2: TTechnique;
begin
  Result := True;

  T1 := FTechniques[I];
  T2 := FTechniques[I + 1];

  if (T1.TechniqueType = ttStack) and (T2.TechniqueType = ttStack) then
    begin
      // Eliminate
      FTechniques.Delete(I);
      FTechniques.Delete(I);
      Result := False;
    end
  else if (T1.TechniqueType = ttCut) and (T2.TechniqueType = ttCut) then
    begin
      // Replace with one operation
      FTechniques[I] := TTechnique.Create(ttCut, (T1.N + T2.N) mod DeckSize);
      FTechniques.Delete(I + 1);
    end
  else if (T1.TechniqueType = ttIncrement) and (T2.TechniqueType = ttIncrement) then
    begin
      // Replace with one operation
      FTechniques[I] := TTechnique.Create(ttIncrement, (T1.N * T2.N) mod DeckSize);
      FTechniques.Delete(I + 1);
    end
  else if (T1.TechniqueType = ttCut) and (T2.TechniqueType = ttIncrement) then
    begin
      // Move increment to top
      FTechniques[I]     := TTechnique.Create(ttIncrement, T2.N);
      FTechniques[I + 1] := TTechnique.Create(ttCut, (T1.N * T2.N) mod DeckSize);
    end
  else if (T1.TechniqueType = ttStack) and (T2.TechniqueType = ttCut) then
    begin
      // Move cut to top
      FTechniques[I]     := TTechnique.Create(ttCut, -T2.N);
      FTechniques[I + 1] := TTechnique.Create(ttStack, 0);
    end
  else if (T1.TechniqueType = ttStack) and (T2.TechniqueType = ttIncrement) then
    begin
      // Move increment to top
      FTechniques[I]     := TTechnique.Create(ttIncrement, T2.N);
      FTechniques[I + 1] := TTechnique.Create(ttCut, -T2.N + 1);
      FTechniques.Insert(I + 2, TTechnique.Create(ttStack, 0));
    end;
end;

procedure TTask_AoC.Simplify(const DeckSize: Int64);
var
  I: Integer;
begin
  while FTechniques.Count > 3 do
    begin
      I := 0;
      while I < FTechniques.Count - 1 do
        if SimplifyAt(I, DeckSize) then
          Inc(I);
    end;
end;

function TTask_AoC.TryHardTechniques: Integer;
const
  DeckSize = 119315717514047;
  Times    = 101741582076661;
var
  P: Int64;
begin
  LoadTechniques;
  try
    P := 1;
    while P < Times do
      begin
        P := P shl 1;
        FTechniques.AddRange(FTechniques.ToArray);
        Simplify(DeckSize);
      end;
  finally
    FTechniques.Free;
  end;
end;

function TTask_AoC.TryTechniques: Integer;
const
  DeckSize = 10007;
var
  I, J, Shift: Integer;
  Cards, Tmp: TArray<Integer>;
begin
  LoadTechniques;
  try
    SetLength(Cards, DeckSize);
    for I := 0 to DeckSize - 1 do
      Cards[I] := I;

    Simplify(DeckSize);

    for I := 0 to FTechniques.Count - 1 do
      with FTechniques[I] do
        case TechniqueType of
          ttStack:
            for J := 0 to (DeckSize - 1) div 2 do
              Swap(Cards[J], Cards[DeckSize - J - 1]);
          ttCut:
            begin
              Shift := (DeckSize + N) mod DeckSize;
              Tmp := Copy(Cards, 0, Shift);
              Cards := Copy(Cards, Shift);
              SetLength(Cards, DeckSize);
              for J := 0 to Shift - 1 do
                Cards[J + (DeckSize - Shift)] := Tmp[J];
            end;
          ttIncrement:
            begin
              SetLength(Tmp, DeckSize);
              for J := 0 to DeckSize - 1 do
                Tmp[(J * N) mod DeckSize] := Cards[J];
              Cards := Copy(Tmp);
            end;
        end;

    Result := -1;
    for I := 0 to DeckSize - 1 do
      if Cards[I] = 2019 then
        Exit(I);
  finally
    FTechniques.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 22, 'Slam Shuffle');

finalization
  GTask.Free;

end.
