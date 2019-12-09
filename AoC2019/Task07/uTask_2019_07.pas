unit uTask_2019_07;

interface

uses
  uTask, IntCode, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    procedure GetPermutation(const Initial: TArray<Integer>; const Index: Integer; out Permutated: TArray<Integer>);
    function GetBestAmpSignal: Integer;
    function GetBestFeedbackAmpSignal: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadProgram;
  try
    OK('Part 1: %d, Part 2: %d', [ GetBestAmpSignal, GetBestFeedbackAmpSignal ]);
  finally
    FInitialState.Free;
  end;
end;

procedure TTask_AoC.GetPermutation(const Initial: TArray<Integer>; const Index: Integer;
  out Permutated: TArray<Integer>);
var
  I, J, K, Tmp: Integer;
begin
  // Generate pemutations
  Permutated := Copy(Initial);
  K := Index;
  for I := 1 to Length(Permutated) do
    begin
      J := K mod I;
      // Swap
      Tmp := Permutated[J];
      Permutated[J] := Permutated[I - 1];
      Permutated[I - 1] := Tmp;
      //
      K := K div I;
    end;
end;

function TTask_AoC.GetBestAmpSignal: Integer;

  function RunAmplifier(const Phase, Signal: Integer): Integer;
  begin
    Result := 0;
    with FInitialState.Clone do
      try
        AddInput(Phase);
        AddInput(Signal);
        if Execute = erHalt then
          Result := Output[0];
      finally
        Free;
      end;
  end;

var
  I, J, AmpOutput: Integer;
  InitialPhases, Phases: TArray<Integer>;
begin
  Result := 0;

  SetLength(InitialPhases, 5);
  for I := 0 to 4 do
    InitialPhases[I] := I;

  for I := 1 to 120 do
    begin
      GetPermutation(InitialPhases, I, Phases);
      AmpOutput := 0;
      for J := 0 to Length(Phases) - 1 do
        AmpOutput := RunAmplifier(Phases[J], AmpOutput);
      if Result < AmpOutput then
        Result := AmpOutput;
    end;

  { XXX: It throws "Invalid pointer operation" exception on 5 elements permutation generation. WTF?
  Permutations := TPermutations.Create(5);
  try
    for Phases in Permutations do
      begin
        AmpOutput := 0;
        for I := 0 to Length(Phases) - 1 do
          AmpOutput := RunAmplifier(Phases[I], AmpOutput);
        if Result < AmpOutput then
          Result := AmpOutput;
      end;
  finally
    Permutations.Free;
  end;
  }
end;

function TTask_AoC.GetBestFeedbackAmpSignal: Integer;

  function RunFeedbackChain(const Phases: TArray<Integer>): Integer;
  var
    Amps: TObjectList<TIntCode>;
    I, LastOutput: Integer;
    E: TExecuteResult;
  begin
    Amps := TObjectList<TIntCode>.Create;
    try
      for I := 0 to Length(Phases) - 1 do
        begin
          Amps.Add(FInitialState.Clone);
          Amps.Last.AddInput(Phases[I]);
        end;

      E := erNone;
      LastOutput := 0;
      while E <> erHalt do
        for I := 0 to Amps.Count - 1 do
          with Amps[I] do
            begin
              AddInput(LastOutput);
              E := Execute;
              LastOutput := Output.Last;
            end;
      Result := LastOutput;
    finally
      Amps.Free;
    end;
  end;

var
  I, J, AmpOutput: Integer;
  InitialPhases, Phases: TArray<Integer>;
begin
  Result := 0;

  SetLength(InitialPhases, 5);
  for I := 5 to 9 do
    InitialPhases[I - 5] := I;

  for I := 1 to 120 do
    begin
      GetPermutation(InitialPhases, I, Phases);
      AmpOutput := RunFeedbackChain(Phases);
      if Result < AmpOutput then
        Result := AmpOutput;
    end;
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TIntCode.LoadProgram(Text);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 7, 'Amplification Circuit');

finalization
  GTask.Free;

end.
