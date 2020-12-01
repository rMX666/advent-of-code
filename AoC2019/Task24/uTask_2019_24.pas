unit uTask_2019_24;

interface

uses
  uTask, System.Generics.Collections;

type
  TBugState = record
  strict private const
    SIZE = 5;
  private
    FRaw: Integer;
    function CheckRange(const I: Integer): Boolean;
    function GetTile(const X, Y: Integer): Boolean;
    procedure SetTile(const X, Y: Integer; const Value: Boolean);
    function GetAdjucentBugs(const X, Y: Integer): Integer;
  public
    constructor Create(const State: TBugState);
    class operator Implicit(const A: Integer): TBugState; overload;
    class operator Implicit(const A: TBugState): Integer; overload;
    function Live: TBugState;
    property AdjucentBugs[const X, Y: Integer]: Integer read GetAdjucentBugs;
    property Tile[const X, Y: Integer]: Boolean read GetTile write SetTile;
  end;

  TTask_AoC = class (TTask)
  private
    FInitialState: TBugState;
    procedure LoadInitialState;
    function GetFirstDuplicatedState: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TBugState }

function TBugState.CheckRange(const I: Integer): Boolean;
begin
  Result := (I >= 0) and (I < SIZE);
end;

constructor TBugState.Create(const State: TBugState);
begin
  FRaw := State.FRaw;
end;

class operator TBugState.Implicit(const A: Integer): TBugState;
begin
  Result.FRaw := A;
end;

class operator TBugState.Implicit(const A: TBugState): Integer;
begin
  Result := A.FRaw;
end;

function TBugState.Live: TBugState;
var
  X, Y: Integer;
begin
  Result := TBugState.Create(Self);
  for X := 0 to SIZE - 1 do
    for Y := 0 to SIZE - 1 do
      if Tile[X, Y] and (AdjucentBugs[X, Y] <> 1) then
        Result.Tile[X, Y] := False
      else if not Tile[X, Y] and (AdjucentBugs[X, Y] in [1, 2]) then
        Result.Tile[X, Y] := True;
end;

function TBugState.GetAdjucentBugs(const X, Y: Integer): Integer;
begin
  Result := Integer(Tile[X - 1, Y]) +
            Integer(Tile[X + 1, Y]) +
            Integer(Tile[X, Y - 1]) +
            Integer(Tile[X, Y + 1]);
end;

function TBugState.GetTile(const X, Y: Integer): Boolean;
begin
  if not (CheckRange(X) and CheckRange(Y)) then
    Exit(False);

  Result := (FRaw shr (X + Y * SIZE)) and 1 = 1;
end;

procedure TBugState.SetTile(const X, Y: Integer; const Value: Boolean);
var
  N: Integer;
begin
  if not (CheckRange(X) and CheckRange(Y)) then
    Exit;

  N := X + Y * SIZE;
  FRaw := (FRaw or (Integer(Value) shl N)) and not (Integer(not Value) shl N);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadInitialState;
  OK('Part 1: %d', [ GetFirstDuplicatedState ]);
end;

function TTask_AoC.GetFirstDuplicatedState: Integer;
var
  Cache: TDictionary<Integer,Integer>;
begin
  Cache := TDictionary<Integer,Integer>.Create;

  try
    Result := TBugState.Create(FInitialState);
    while not Cache.ContainsKey(Result) do
      begin
        Cache.Add(Result, 0);
        Result := TBugState(Result).Live;
      end;
  finally
    Cache.Free;
  end;
end;

procedure TTask_AoC.LoadInitialState;
var
  X, Y: Integer;
begin
  FInitialState := TBugState.Create(0);
  with Input do
    try
      for Y := 0 to Count - 1 do
        for X := 1 to Strings[Y].Length do
          FInitialState.Tile[X - 1, Y] := Strings[Y][X] = '#';
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 24, 'Planet of Discord');

finalization
  GTask.Free;

end.
