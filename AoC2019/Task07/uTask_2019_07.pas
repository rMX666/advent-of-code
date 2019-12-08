unit uTask_2019_07;

interface

uses
  uTask, IntCode;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function RunAmplifier(const Phase, Signal: Integer): Integer;
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
    OK('Part 1: %d', [ GetBestAmpSignal ]);
  finally
    FInitialState.Free;
  end;
end;

function TTask_AoC.RunAmplifier(const Phase, Signal: Integer): Integer;
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

function TTask_AoC.GetBestAmpSignal: Integer;

  procedure Swap(var A, B: Integer);
  var
    T: Integer;
  begin
    T := A;
    A := B;
    B := T;
  end;

var
  I, J, K, T, AmpOutput: Integer;
  InitialPhases, Phases: TArray<Integer>;
begin
  Result := 0;

  SetLength(InitialPhases, 5);
  for I := 0 to 4 do
    InitialPhases[I] := I;

  for I := 1 to 120 do
    begin
      // Generate pemutations
      Phases := Copy(InitialPhases);
      K := I;
      for T := 1 to Length(Phases) do
        begin
          J := K mod T;
          Swap(Phases[J], Phases[T - 1]);
          K := K div T;
        end;

      AmpOutput := 0;
      for T := 0 to Length(Phases) - 1 do
        AmpOutput := RunAmplifier(Phases[T], AmpOutput);
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
begin

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
