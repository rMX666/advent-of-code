unit uTask_2020_05;

interface

uses
  System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FSeats: TList<Integer>;
    procedure LoadSeats;
  protected
    procedure DoRun; override;
    function GetMaxSeatID: Integer;
    function FindOwnSeatID: Integer;
  end;

implementation

uses
  System.SysUtils, System.Math, System.RegularExpressions, uUtil;

var
  GTask: TTask_AoC;

procedure TTask_AoC.DoRun;
begin
  try
    LoadSeats;
    Ok('Part 1: %d, Part 2: %d', [ GetMaxSeatID, FindOwnSeatID ]);
  finally
    FSeats.Free;
  end;
end;

function TTask_AoC.FindOwnSeatID: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FSeats.Count - 2 do
    if FSeats[I + 1] - FSeats[I] > 1 then
      Exit(FSeats[I] + 1);
end;

function TTask_AoC.GetMaxSeatID: Integer;
begin
  Result := FSeats.Last;
end;

procedure TTask_AoC.LoadSeats;

  function GetSeatID(const S: String): Integer;
  begin
    Result := BinToInt(S.Replace('F', '0').Replace('B', '1').Replace('L', '0').Replace('R', '1'));
  end;

var
  I: Integer;
begin
  FSeats := TList<Integer>.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FSeats.Add(GetSeatID(Strings[I]));
      FSeats.Sort;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 5, 'Binary Boarding');

finalization
  GTask.Free;

end.
