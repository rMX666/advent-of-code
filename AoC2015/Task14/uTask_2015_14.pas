unit uTask_2015_14;

interface

uses
  uTask, System.Generics.Collections;

type
  PDeer = ^TDeer;
  TDeer = record
    Name: String;
    Speed, GoTime, RestTime: Integer;
    Path: Integer;
    Points: Integer;
    GoTimer, RestTimer: Integer;
    constructor Create(const S: String);
    class function Pointer(const S: String): PDeer; static;
    procedure Score;
    function Step: Integer;
  end;

  TDeers = TList<PDeer>;
  TMaxProperty = ( mpPath, mpPoints );
  TGetMaxPropertyHandler = reference to function (const Deer: TDeer): Integer;

  TTask_AoC = class (TTask)
  private
    FDeers: TDeers;
    FMaxHandlers: TArray<TGetMaxPropertyHandler>;
    procedure LoadDeers;
    function GetMax(const MaxProperty: TMaxProperty = mpPath): Integer;
    procedure RaceDeers;
  protected
    procedure DoRun; override;
  public
    constructor Create; override;
  end;

implementation

uses
  System.SysUtils;

const
  RACE_TIME = 2503;

var
  GTask: TTask_AoC;

{ TDeer }

constructor TDeer.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Trim.Split([' ']);

  Name     := A[0];
  Speed    := A[3].ToInteger;
  GoTime   := A[6].ToInteger;
  RestTime := A[13].ToInteger;

  Path      := 0;
  Points    := 0;
  GoTimer   := GoTime;
  RestTimer := 0;
end;

class function TDeer.Pointer(const S: String): PDeer;
begin
  New(Result);
  Result^ := TDeer.Create(S);
end;

procedure TDeer.Score;
begin
  Inc(Points);
end;

function TDeer.Step: Integer;
begin
  if GoTimer > 0 then
    begin
      Inc(Path, Speed);
      Dec(GoTimer);
      if GoTimer = 0 then
        RestTimer := RestTime;
    end
  else
    begin
      Dec(RestTimer);
      if RestTimer = 0 then
        GoTimer := GoTime;
    end;

  Result := Path;
end;

{ TTask_AoC }

constructor TTask_AoC.Create;
begin
  inherited;
  SetLength(FMaxHandlers, Integer(High(TMaxProperty)) + 1);

  FMaxHandlers[Integer(mpPath)]   := function (const Deer: TDeer): Integer begin Result := Deer.Path; end;
  FMaxHandlers[Integer(mpPoints)] := function (const Deer: TDeer): Integer begin Result := Deer.Points; end;
end;

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Integer;
begin
  try
    LoadDeers;
    RaceDeers;

    Part1 := GetMax(mpPath);
    Part2 := GetMax(mpPoints);

    OK('Part 1: %d, Part 2: %d', [ Part1, Part2 ]);
  finally
    FDeers.Free;
  end;
end;

function TTask_AoC.GetMax(const MaxProperty: TMaxProperty): Integer;
var
  I, Value: Integer;
begin
  Result := 0;

  for I := 0 to FDeers.Count - 1 do
    begin
      Value := FMaxHandlers[Integer(MaxProperty)](FDeers[I]^);
      if Result < Value then
        Result := Value;
    end;
end;

procedure TTask_AoC.LoadDeers;
var
  I: Integer;
begin
  FDeers := TDeers.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FDeers.Add(TDeer.Pointer(Strings[I]));
    finally
      Free;
    end;
end;

procedure TTask_AoC.RaceDeers;
var
  T, MaxPath: Integer;

  procedure StepDeers;
  var
    I, Path: Integer;
  begin
    MaxPath := 0;

    for I := 0 to FDeers.Count - 1 do
      begin
        Path := FDeers[I].Step;
        if MaxPath < Path then
          MaxPath := Path;
      end;
  end;

  procedure ScoreBestDeers;
  var
    I: Integer;
  begin
    for I := 0 to FDeers.Count - 1 do
      if FDeers[I].Path = MaxPath then
        FDeers[I].Score;
  end;

begin
  for T := 1 to RACE_TIME do
    begin
      StepDeers;
      ScoreBestDeers;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 14, 'Reindeer Olympics');

finalization
  GTask.Free;

end.
