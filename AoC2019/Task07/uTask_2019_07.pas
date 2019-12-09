unit uTask_2019_07;

interface

uses
  uTask, IntCode, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function GetBestAmpSignal: Integer;
    function GetBestFeedbackAmpSignal: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  uUtil;

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
  I, AmpOutput: Integer;
  Phases: TPermutationItems;
  Permutations: TPermutations;
begin
  Result := 0;

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
  AmpOutput: Integer;
  Phases: TPermutationItems;
  Permutations: TPermutations;
begin
  Result := 0;

  Permutations := TPermutations.Create(5, 5);
  try
    for Phases in Permutations do
      begin
        AmpOutput := RunFeedbackChain(Phases);
        if Result < AmpOutput then
          Result := AmpOutput;
      end;
  finally
    Permutations.Free;
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
