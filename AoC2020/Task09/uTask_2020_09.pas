unit uTask_2020_09;

interface

uses
  System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private const
    PREAMBLE_SIZE = 25;
    LOOKBACK_SIZE = 25;
  private
    FData: TList<Int64>;
    procedure LoadData;
    function GetFirstInvalidNumber: Int64;
    function GetEncryptionWeakness: Int64;
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
begin
  try
    LoadData;
    Ok('Part 1: %d, Part 2: %d', [ GetFirstInvalidNumber, GetEncryptionWeakness ]);
  finally
    FData.Free;
  end;
end;


function TTask_AoC.GetEncryptionWeakness: Int64;
var
  FirstInvalid, Sum: Int64;
  I, B, E, Min, Max: Integer;
begin
  FirstInvalid := GetFirstInvalidNumber;
  B := 0;
  Sum := 0;
  while FirstInvalid <> Sum do
    begin
      Sum := 0;
      I := B;
      while Sum < FirstInvalid do
        begin
          Inc(Sum, FData[I]);
          Inc(I);
        end;
      if FirstInvalid = Sum then
        Break;
      Inc(B);
    end;

  E := I;
  Min := FData[B];
  Max := FData[B];
  for I := B to E - 1 do
    begin
      if Min < FData[I] then Min := FData[I];
      if Max > FData[I] then Max := FData[I];
    end;
  Result := Min + Max;
end;

function TTask_AoC.GetFirstInvalidNumber: Int64;
var
  I, J, K: Integer;
  Found: Boolean;
begin
  for I := PREAMBLE_SIZE to FData.Count - 1 do
    begin
      Found := False;
      for J := I - LOOKBACK_SIZE to I - 1 do
        for K := J to I - 1 do
          if (J <> K) and (FData[I] = FData[J] + FData[K]) then
            Found := True;
      if not Found then
        Exit(FData[I]);
    end;
end;

procedure TTask_AoC.LoadData;
var
  I: Integer;
begin
  FData := TList<Int64>.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FData.Add(Strings[I].ToInt64);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 9, 'Encoding Error');

finalization
  GTask.Free;

end.
