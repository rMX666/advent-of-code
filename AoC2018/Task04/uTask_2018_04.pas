unit uTask_2018_04;

interface

uses
  System.Generics.Collections, uTask;

type
  TDay = String;
  TIntervals = Array [0..59] of Boolean;
  TDayIntervals = TDictionary<TDay,TIntervals>;

  TGuard = class
  private
    FID: Integer;
    FIntervals: TDayIntervals;
    function GetIntervals(const Day: TDay): TIntervals;
  public
    constructor Create(const AID: Integer);
    destructor Destroy; override;
    property Intervals[const Day: TDay]: TIntervals read GetIntervals;
    procedure AddAsleepInterval(const Day: TDay; const AFrom, ATo: Integer);
    function GetAsleepMinuteCount: Integer;
    function GetBestMinute: Integer; overload;
    function GetBestMinute(out BestFreq: Integer): Integer; overload;
  end;

  TGuards = TObjectDictionary<Integer,TGuard>;

  TTask_AoC = class (TTask)
  private
    FGuards: TGuards;
    procedure LoadGuards;
    function GetBestMinute: Integer;
    function GetBestFreqMinute: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Classes;

var
  GTask: TTask_AoC;

{ TGuard }

procedure TGuard.AddAsleepInterval(const Day: TDay; const AFrom, ATo: Integer);
var
  Intervals: TIntervals;
  I: Integer;
begin
  if not FIntervals.ContainsKey(Day) then
    begin
      FillChar(Intervals, SizeOf(Intervals), 0);
      FIntervals.Add(Day, Intervals);
    end
  else
    Intervals := Self.Intervals[Day];

  for I := AFrom to ATo - 1 do
    Intervals[I] := True;

  FIntervals[Day] := Intervals;
end;

constructor TGuard.Create(const AID: Integer);
begin
  FIntervals := TDayIntervals.Create;
  FID := AID;
end;

destructor TGuard.Destroy;
begin
  FIntervals.Free;
  inherited;
end;

function TGuard.GetAsleepMinuteCount: Integer;
var
  Intervals: TIntervals;
  I: Integer;
begin
  Result := 0;

  for Intervals in FIntervals.Values do
    for I := 0 to 59 do
      if Intervals[I] then
        Inc(Result);
end;

function TGuard.GetBestMinute(out BestFreq: Integer): Integer;
var
  I, Freq: Integer;
  Intervals: TIntervals;
begin
  Result := -1;

  BestFreq := -1;
  for I := 0 to 59 do
    begin
      Freq := 0;
      for Intervals in FIntervals.Values do
        if Intervals[I] then
          Inc(Freq);

      if BestFreq < Freq then
        begin
          BestFreq := Freq;
          Result := I;
        end;
    end;
end;

function TGuard.GetBestMinute: Integer;
var
  Freq: Integer;
begin
  Result := GetBestMinute(Freq);
end;

function TGuard.GetIntervals(const Day: TDay): TIntervals;
begin
  Result := FIntervals[Day];
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadGuards;

    OK(Format('Part 1: %d, Part 2: %d', [ GetBestMinute, GetBestFreqMinute ]));
  finally
    FGuards.Free;
  end;
end;

function TTask_AoC.GetBestFreqMinute: Integer;
var
  Guard: TGuard;
  ID, BestFreq, Freq, Minute: Integer;
begin
  BestFreq := -1;
  for Guard in FGuards.Values do
    begin
      Minute := Guard.GetBestMinute(Freq);
      if BestFreq < Freq then
        begin
          BestFreq := Freq;
          ID := Guard.FID;
        end;
    end;

  Result := ID * FGuards[ID].GetBestMinute;
end;

function TTask_AoC.GetBestMinute: Integer;
var
  Guard: TGuard;
  I, BestMinutes, ID: Integer;
  Intervals: TIntervals;
begin
  Result := 0;

  BestMinutes := 0;
  ID := 0;
  for Guard in FGuards.Values do
    if BestMinutes < Guard.GetAsleepMinuteCount then
      begin
        ID := Guard.FID;
        BestMinutes := Guard.GetAsleepMinuteCount;
      end;

  Result := ID * FGuards[ID].GetBestMinute;
end;

procedure TTask_AoC.LoadGuards;

  function MakeGuard(const S: String; out Day: TDay): TGuard;
  var
    A: TArray<String>;
    ID: Integer;
  begin
    A := S.Replace('[', '').Replace(']', '').Replace('#', '').Split([' ']);
    ID := A[3].ToInteger;
    Day := A[0];

    if not FGuards.ContainsKey(ID) then
      FGuards.Add(ID, TGuard.Create(ID));

    Result := FGuards[ID];
  end;

  function GetMinute(const S: String): Integer;
  var
    A: TArray<String>;
  begin
    A := S.Replace('[', '').Replace(']', '').Replace('#', '').Replace(':', ' ').Split([' ']);
    Result := A[2].ToInteger;
  end;

var
  I: Integer;
  Guard: TGuard;
  StartMinute, EndMinute: Integer;
  Day: TDay;
begin
  FGuards := TGuards.Create([ doOwnsValues ]);

  with TStringList(Input) do
    try
      Sort;

      I := 0;
      while I < Count do
        begin
          if Strings[I].Contains('Guard #') then
            Guard := MakeGuard(Strings[I], Day)
          else if Strings[I].Contains('falls asleep') then
            StartMinute := GetMinute(Strings[I])
          else if Strings[I].Contains('wakes up') then
            begin
              EndMinute := GetMinute(Strings[I]);
              Guard.AddAsleepInterval(Day, StartMinute, EndMinute);
            end;

          Inc(I);
        end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 4, 'Repose Record');

finalization
  GTask.Free;

end.
