unit uTask_2015_15;

interface

uses
  uTask, System.Generics.Collections;

type
  TIngridient = record
    Name: String;
    Capacity,
    Durability,
    Flavor,
    Texture,
    Calories: Integer;
    constructor Create(const S: String);
  end;

  TIngridients = TList<TIngridient>;

  TTask_AoC = class (TTask)
  private
    FIngridients: TIngridients;
    procedure LoadIngridiends;
    function FindBestCookieScore(const CaloryLimit: Integer = -1): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

const
  MAX_SPOONS = 100;

var
  GTask: TTask_AoC;

{ TIngridient }

constructor TIngridient.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Replace(',', '').Replace(':', '').Split([' ']);

  Name       := A[0];
  Capacity   := A[2].ToInteger;
  Durability := A[4].ToInteger;
  Flavor     := A[6].ToInteger;
  Texture    := A[8].ToInteger;
  Calories   := A[10].ToInteger;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Integer;
begin
  try
    LoadIngridiends;

    Part1 := FindBestCookieScore;
    Part2 := FindBestCookieScore(500);

    OK(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
  finally
    FIngridients.Free;
  end;
end;

function TTask_AoC.FindBestCookieScore(const CaloryLimit: Integer): Integer;
var
  Combinations: TArray<Integer>;
  CCount, CombinationsCount, CombinationNo: Integer;

  function IncCombinations: Integer;
  var
    I: Integer;
    Stop: Boolean;
  begin
    Result := 0;
    I := CCount - 1;
    Stop := False;
    while I >= 0 do
      begin
        if not Stop then
          begin
            Inc(Combinations[I]);
            if Combinations[I] > MAX_SPOONS - CCount then
              Combinations[I] := 1
            else
              Stop := True;
          end;
        Inc(Result, Combinations[I]);
        Dec(I);
      end;
  end;

  function SkipToCorrectCombination: Boolean;
  begin
    Result := True;

    if CombinationNo > CombinationsCount then
      Exit(False);

    while IncCombinations <> MAX_SPOONS do
      begin
        Inc(CombinationNo);
        if CombinationNo > CombinationsCount then
          Exit(False);
      end;
  end;

  function CalculateCombination: Integer;

    function ZeroIfNegative(const N: Integer): Integer;
    begin
      if N < 0 then
        Result := 0
      else
        Result := N;
    end;

  var
    I, Capacity, Durability, Flavor, Texture, Calories: Integer;
  begin
    Capacity := 0;
    Durability := 0;
    Flavor := 0;
    Texture := 0;
    Calories := 0;

    for I := 0 to CCount - 1 do
      begin
        Inc(Capacity, FIngridients[I].Capacity * Combinations[I]);
        Inc(Durability, FIngridients[I].Durability * Combinations[I]);
        Inc(Flavor, FIngridients[I].Flavor * Combinations[I]);
        Inc(Texture, FIngridients[I].Texture * Combinations[I]);
        Inc(Calories, FIngridients[I].Calories * Combinations[I]);
       end;

    Result := ZeroIfNegative(Capacity) * ZeroIfNegative(Durability) * ZeroIfNegative(Flavor) * ZeroIfNegative(Texture);

    if CaloryLimit > -1 then
      if Calories <> CaloryLimit then
        Result := 0;
  end;

var
  I, Sum: Integer;
begin
  Result := 0;

  CCount := FIngridients.Count;
  SetLength(Combinations, CCount);
  CombinationsCount := 1;
  CombinationNo := 0;
  for I := 0 to CCount - 1 do
    begin
      Combinations[I] := 1;
      CombinationsCount := CombinationsCount * MAX_SPOONS;
    end;

  while SkipToCorrectCombination do
    for I := 0 to CCount - 1 do
      begin
        Sum := CalculateCombination;
        if Result < Sum then
          Result := Sum;
      end;
end;

procedure TTask_AoC.LoadIngridiends;
var
  I: Integer;
begin
  FIngridients := TIngridients.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FIngridients.Add(TIngridient.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 15, 'Science for Hungry People');

finalization
  GTask.Free;

end.
