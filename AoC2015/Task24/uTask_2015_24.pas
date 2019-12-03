unit uTask_2015_24;

interface

uses
  uTask;

type
  TPacks = TArray<Integer>;

  TTask_AoC = class (TTask)
  private
    FPacks: TPacks;
    FTotalWeight: Integer;
  protected
    procedure LoadPacks;
    function BestQE(const PartCount: Integer): Int64;
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uUtil;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.BestQE(const PartCount: Integer): Int64;

  procedure WeightAndQE(const Packs: TPacks; out Weight: Integer; out QE: Int64);
  var
    I: Integer;
  begin
    Weight := 0;
    QE := 1;
    for I := 0 to Length(Packs) - 1 do
      begin
        Inc(Weight, Packs[I]);
        QE := QE * Packs[I];
      end;
  end;

var
  I, PartWeight, MinLength, Weight: Integer;
  QE: Int64;
  SubSeqs: TSubSequences<Integer>;
  SubSeq: TPacks;
begin
  Result := High(Int64);

  PartWeight := FTotalWeight div PartCount;

  MinLength := Length(FPacks);

  // Approximate subsequence size to skip irrelevant results
  Weight := 0;
  I := 0;
  while (I < Length(FPacks)) and (Weight <= PartWeight) do
    begin
      Inc(Weight, FPacks[Length(FPacks) - I - 1]);
      Inc(I);
    end;

  SubSeqs := TSubSequences<Integer>.Create(FPacks, I - 1, I + 2);
  try
    for SubSeq in SubSeqs do
      begin
        WeightAndQE(SubSeq, Weight, QE);
        if Weight = PartWeight then
          begin
            if MinLength > Length(SubSeq) then
              begin
                MinLength := Length(SubSeq);
                Result := QE;
              end
            else
              if (MinLength = Length(SubSeq)) and (Result > QE) then
                Result := QE;
          end;
      end;
  finally
    SubSeqs.Free;
  end;
end;

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Int64;
begin
  LoadPacks;

  Part1 := BestQE(3);
  Part2 := BestQE(4);

  OK('Part 1: %d, Part 2: %d', [ Part1, Part2 ]);
end;

procedure TTask_AoC.LoadPacks;
var
  I: Integer;
begin
  FTotalWeight := 0;
  with Input do
    try
      SetLength(FPacks, Count);
      for I := 0 to Count - 1 do
        begin
          FPacks[I] := Strings[I].ToInteger;
          Inc(FTotalWeight, FPacks[I]);
        end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 24, 'It Hangs in the Balance');

finalization
  GTask.Free;

end.
