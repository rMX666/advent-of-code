unit uTask_2020_13;

interface

uses
  System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FEarliestTimestamp: Integer;
    FBuses: TList<Integer>;
    procedure LoadSchedule;
    function GetClosestBus: Integer;
    function GetSubsequentDepartureTimestemp: Int64;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uUtil;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadSchedule;
    Ok('Part 1: %d, Part 2: %d', [ GetClosestBus, GetSubsequentDepartureTimestemp ]);
  finally
    FBuses.Free;
  end;
end;

function TTask_AoC.GetClosestBus: Integer;
var
  I, Time, MinID, MinTime: Integer;
begin
  MinID := MaxInt;
  MinTime := MaxInt;

  for I := 0 to FBuses.Count - 1 do
    if FBuses[I] <> -1 then
      begin
        Time := Ceil(FEarliestTimestamp / FBuses[I]) * FBuses[I] - FEarliestTimestamp;
        if MinTime > Time then
          begin
            MinTime := Time;
            MinID := FBuses[I];
          end;
      end;

  Result := MinID * MinTime;
end;

function TTask_AoC.GetSubsequentDepartureTimestemp: Int64;
var
  Buses: TList<TPair<Integer,Integer>>;
  I: Integer;
  Increment: Int64;
begin
  Buses := TList<TPair<Integer,Integer>>.Create;

  try
    for I := 0 to FBuses.Count - 1 do
      if FBuses[I] <> -1 then
        Buses.Add(TPair<Integer,Integer>.Create(FBuses[I], I));

    Result := 0;
    Increment := 1;
    I := 1;
    for I := 0 to Buses.Count - 1 do
      begin
        while (Result + Buses[I].Value) mod Buses[I].Key <> 0 do
          Inc(Result, Increment);
        Increment := Increment * Buses[I].Key;
      end;
  finally
    Buses.Free;
  end;
end;

procedure TTask_AoC.LoadSchedule;
var
  A: TArray<String>;
  I: Integer;
begin
  FBuses := TList<Integer>.Create;

  with Input do
    try
      FEarliestTimestamp := Strings[0].ToInteger;
      A := Strings[1].Split([',']);
    finally
      Free;
    end;

  for I := 0 to Length(A) - 1 do
    if A[I] = 'x' then
      FBuses.Add(-1)
    else
      FBuses.Add(A[I].ToInteger);
end;

initialization
  GTask := TTask_AoC.Create(2020, 13, 'Shuttle Search');

finalization
  GTask.Free;

end.
