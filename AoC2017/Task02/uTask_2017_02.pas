unit uTask_2017_02;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FSheet: TArray<TArray<Integer>>;
    procedure LoadSheet;
    function CheckSum(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.CheckSum(const Part: Integer): Integer;

  function FindDivs(const A: TArray<Integer>): Integer;
  var
    I, J: Integer;
  begin
    for I := 0 to Length(A) - 1 do
      for J:= 0 to Length(A) - 1 do
        if I <> J then
          if A[I] mod A[J] = 0 then
            Exit(A[I] div A[J]);
  end;

var
  I, Min, Max: Integer;
begin
  Result := 0;
  for I := 0 to Length(FSheet) - 1 do
    case Part of
      1:
        begin
          Min := MinIntValue(FSheet[I]);
          Max := MaxIntValue(FSheet[I]);
          Inc(Result, Max - Min);
        end;
      2:
        Inc(Result, FindDivs(FSheet[I]));
    end;
end;

procedure TTask_AoC.DoRun;
begin
  LoadSheet;

  OK(Format('Part 1: %d, Part 2: %d', [ CheckSum(1), CheckSum(2) ]));
end;


procedure TTask_AoC.LoadSheet;

  function ToIntArray(const A: TArray<String>): TArray<Integer>;
  var
    I: Integer;
  begin
    SetLength(Result, Length(A));
    for I := 0 to Length(A) - 1 do
      Result[I] := A[I].ToInteger;
  end;

var
  I: Integer;
begin
  with Input do
    try
      SetLength(FSheet, Count);
      for I := 0 to Count - 1 do
        FSheet[I] := ToIntArray(Strings[I].Split([#9]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 2, 'Corruption Checksum');

finalization
  GTask.Free;

end.
