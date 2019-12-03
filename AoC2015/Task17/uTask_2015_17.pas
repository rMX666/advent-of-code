unit uTask_2015_17;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FContainers: TArray<Integer>;
    FWaysToFill, FMinWaysToFill: Integer;
    procedure CountMinWaysToFill;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  uUtil, System.SysUtils;

const
  MAX_VOLUME = 150;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.CountMinWaysToFill;
var
  SubSequences: TSubSequences<Integer>;
  Sequence: TArray<Integer>;
  I, Sum, MinCount: Integer;
begin
  SubSequences := TSubSequences<Integer>.Create(FContainers);

  FWaysToFill := 0;
  FMinWaysToFill := 0;
  MinCount := Length(FContainers);
  // Take all subsequences of given containers list
  for Sequence in SubSequences do
    begin
      // Take sum of each subsequence
      Sum := 0;
      for I := 0 to Length(Sequence) - 1 do
        Inc(Sum, Sequence[I]);
      // On sum match increase counters
      if Sum = MAX_VOLUME then
        begin
          // Count all ways of filling containers
          Inc(FWaysToFill);
          // Find minimum length of filling sequence
          if Length(Sequence) < MinCount then
            begin
              // If previous minimum was not real minimum, reset counter
              FMinWaysToFill := 1;
              MinCount := Length(Sequence);
            end
          // If current current sequence is of minimum length, increase counter
          else if Length(Sequence) = MinCount then
            Inc(FMinWaysToFill);
        end;
    end;
end;

procedure TTask_AoC.DoRun;
var
  I: Integer;
begin
  with Input do
    try
      SetLength(FContainers, Count);
      for I := 0 to Count - 1 do
        FContainers[I] := Strings[I].ToInteger;
    finally
      Free;
    end;

  CountMinWaysToFill;

  OK('Part 1: %d, Part 2: %d', [ FWaysToFill, FMinWaysToFill ]);
end;

initialization
  GTask := TTask_AoC.Create(2015, 17, 'No Such Thing as Too Much');

finalization
  GTask.Free;

end.
