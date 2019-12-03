unit uTask_2017_06;

interface

uses
  System.Generics.Collections, uTask;

type
  TMemoryState = array [0..15] of Byte;
  TStates = TDictionary<TMemoryState,Integer>;

  TTask_AoC = class (TTask)
  private
    FInitialState: TMemoryState;
    FStates: TStates;
    procedure LoopDetect(out UntilLoop, LoopLength: Integer);
    function RealignMemory(const Memory: TMemoryState): TMemoryState;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  A: TArray<String>;
  I, UntilLoop, LoopLength: Integer;
begin
  with Input do
    try
      A := Text.Trim.Split([#9]);
      for I := 0 to 15 do
        FInitialState[I] := A[I].ToInteger;
    finally
      Free;
    end;

  FStates := TStates.Create;
  try
    LoopDetect(UntilLoop, LoopLength);

    OK('Part 1: %d, Part 2: %d', [ UntilLoop, LoopLength ]);
  finally
    FStates.Free;
  end;
end;

procedure TTask_AoC.LoopDetect(out UntilLoop, LoopLength: Integer);
var
  State: TMemoryState;
begin
  UntilLoop := 0;

  State := FInitialState;
  while True do
    begin
      Inc(UntilLoop);
      State := RealignMemory(State);
      if FStates.ContainsKey(State) then
        Break;
      FStates.Add(State, UntilLoop);
    end;
  LoopLength := UntilLoop - FStates[State];
end;

function TTask_AoC.RealignMemory(const Memory: TMemoryState): TMemoryState;
var
  I, MaxI, MaxVal: Integer;
begin
  // Find source of redistribution
  // And fill the resulting state
  MaxVal := 0;
  MaxI := 0;
  for I := 0 to 15 do
    begin
      if MaxVal < Memory[I] then
        begin
          MaxVal := Memory[I];
          MaxI := I;
        end;
      Result[I] := Memory[I];
    end;

  // Redistribute max value
  Result[MaxI] := 0;
  I := (MaxI + 1) mod 16;
  while MaxVal > 0 do
    begin
      Inc(Result[I]);
      Dec(MaxVal);
      I := (I + 1) mod 16;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 6, 'Memory Reallocation');

finalization
  GTask.Free;

end.
