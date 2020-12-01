unit uTask_2020_01;

interface

uses
  System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    const TOTAL = 2020;
  private
    FExpense: TList<Integer>;
    procedure LoadExpense;
    function FindMultOf2020SumOf2: Integer;
    function FindMultOf2020SumOf3: Integer;
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
    LoadExpense;
    Ok('Part 1: %d, Part 2: %d', [ FindMultOf2020SumOf2, FindMultOf2020SumOf3 ]);
  finally
    FExpense.Free;
  end;
end;


function TTask_AoC.FindMultOf2020SumOf2: Integer;
var
  I, J, L: Integer;
begin
  Result := -1;
  for I := 0 to FExpense.Count - 1 do
    begin
      L := TOTAL - FExpense[I];
      for J := 0 to FExpense.Count - 1 do
        begin
          if I = J then
            Continue;
          if FExpense[J] > L then
            Break;
          if FExpense[I] + FExpense[J] = TOTAL then
            Exit(FExpense[I] * FExpense[J]);
        end;
    end;
end;

function TTask_AoC.FindMultOf2020SumOf3: Integer;
var
  I, J, K, L1, L2: Integer;
begin
  Result := -1;
  for I := 0 to FExpense.Count - 1 do
    begin
      L1 := TOTAL - FExpense[I];
      for J := 0 to FExpense.Count - 1 do
        begin
          if I = J then
            Continue;
          if FExpense[J] >= L1 then
            Break;
          L2 := L1 - FExpense[J];
          for K := 0 to FExpense.Count - 1 do
            begin
              if (I = K) or (J = K) then
                Continue;
              if FExpense[K] > L2 then
                Break;
              if L2 - FExpense[K] = 0 then
                Exit(FExpense[I] * FExpense[J] * FExpense[K]);
            end;
        end;
    end;
end;

procedure TTask_AoC.LoadExpense;
var
  I: Integer;
begin
  FExpense := TList<Integer>.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FExpense.Add(Strings[I].ToInteger);
      FExpense.Sort;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 1, 'Report Repair');

finalization
  GTask.Free;

end.
