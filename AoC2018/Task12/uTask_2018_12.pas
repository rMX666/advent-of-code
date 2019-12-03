unit uTask_2018_12;

interface

uses
  System.Generics.Collections, uTask;

type
  TPlantState = array [-1000..1000] of Boolean;

  TPlantRule = record
    Pattern: array [-2..2] of Boolean;
    Value: Boolean;
    constructor Create(const S: String);
  end;

  TPlanter = TList<TPlantRule>;

  TTask_AoC = class (TTask)
  private
    FInitialState: TPlantState;
    FPlanter: TPlanter;
    procedure LoadRules;
    function NextState(const State: TPlantState): TPlantState;
    function AfterNGenerations(const State: TPlantState; const N: Integer): TPlantState;
    function StateSum(const State: TPlantState): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TPlantRule }

constructor TPlantRule.Create(const S: String);
var
  A: TArray<String>;
  I: Integer;
begin
  A := S.Split([' => ']);
  for I := 1 to A[0].Length do
    Pattern[I - 3] := A[0][I] = '#';
  Value := A[1] = '#';
end;

{ TTask_AoC }

function TTask_AoC.AfterNGenerations(const State: TPlantState; const N: Integer): TPlantState;
var
  I: Integer;
begin
  Result := State;
  for I := 1 to N do
    Result := NextState(Result);
end;

function TTask_AoC.NextState(const State: TPlantState): TPlantState;

  function FindRule(const Index: Integer): Boolean;
  var
    I, J: Integer;
    Found: Boolean;
  begin
    Result := False;
    for I := 0 to FPlanter.Count - 1 do
      begin
        Found := True;
        for J := Index - 2 to Index + 2 do
          Found := Found and (State[J] = FPlanter[I].Pattern[J - Index]);
        if Found then
          Exit(FPlanter[I].Value);
      end;
  end;

var
  I: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  for I := Low(State) to High(State) do
    Result[I] := FindRule(I);
end;

function TTask_AoC.StateSum(const State: TPlantState): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(State) to High(State) do
    if State[I] then
      Inc(Result, I);
end;

procedure TTask_AoC.DoRun;
var
  N1, N2, Part2: Int64;
begin
  LoadRules;

  N1 := StateSum(AfterNGenerations(FInitialState, 100));
  N2 := StateSum(AfterNGenerations(FInitialState, 200));
  Part2 := N1 + (500000000 - 1) * (N2 - N1);

  try
    OK('Part 1: %d, Part 2: %d', [ StateSum(AfterNGenerations(FInitialState, 20)), Part2 ]);
  finally
    FPlanter.Free;
  end;
end;

procedure TTask_AoC.LoadRules;
var
  InitialState: String;
  I: Integer;
begin
  FillChar(FInitialState, SizeOf(FInitialState), 0);
  FPlanter := TPlanter.Create;

  with Input do
    try
      InitialState := Strings[0].Split([': '])[1];
      for I := 1 to InitialState.Length do
        FInitialState[I - 1] := InitialState[I] = '#';

      for I := 2 to Count - 1 do
        if Strings[I].EndsWith(' => #') then
          FPlanter.Add(TPlantRule.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 12, 'Subterranean Sustainability');

finalization
  GTask.Free;

end.
