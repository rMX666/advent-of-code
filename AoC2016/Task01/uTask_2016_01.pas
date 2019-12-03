unit uTask_2016_01;

interface

uses
  System.Generics.Collections, System.Types, uTask;

type
  TDirection = ( L, R
               , N, E, S, W );
  TStep = record
    Direction: TDirection;
    Steps: Integer;
    constructor Create(const S: String);
  end;

  TSteps = TList<TStep>;

  TTask_AoC = class (TTask)
  private
    FSteps: TSteps;
    procedure LoadSteps;
    function Turn(const TurnDir, CurrDir: TDirection): TDirection;
    function GetShortestPath: Integer;
    function GetFirstIntersectionPath: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TStep }

constructor TStep.Create(const S: String);
begin
  case S[1] of
    'L': Direction := L;
    'R': Direction := R;
  end;
  Steps := S.Substring(1).ToInteger;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Integer;
begin
  try
    LoadSteps;

    Part1 := GetShortestPath;
    Part2 := GetFirstIntersectionPath;
  finally
    FSteps.Free;
  end;

  OK('Part 1: %d, Part 2: %d', [ Part1, Part2 ]);
end;

function TTask_AoC.GetFirstIntersectionPath: Integer;
var
  CurrentPos: TPoint;
  CurrentDir: TDirection;
  I, J: Integer;
  Path: TList<TPoint>;
  Found: Boolean;
begin
  CurrentPos := TPoint.Zero;
  CurrentDir := N;

  Path := TList<TPoint>.Create;

  try
    Found := False;
    for I := 0 to FSteps.Count - 1 do
      begin
        CurrentDir := Turn(FSteps[I].Direction, CurrentDir);
        for J := 1 to FSteps[I].Steps do
          begin
            case CurrentDir of
              N: Dec(CurrentPos.Y, 1);
              E: Inc(CurrentPos.X, 1);
              S: Inc(CurrentPos.Y, 1);
              W: Dec(CurrentPos.X, 1);
            end;
            if Path.Contains(CurrentPos) then
              begin
                Found := True;
                Break;
              end;
            Path.Add(CurrentPos);
          end;
        if Found then
          Break;
      end;
  finally
    Path.Free;
  end;

  Result := Abs(CurrentPos.X) + Abs(CurrentPos.Y);
end;

function TTask_AoC.GetShortestPath: Integer;
var
  CurrentPos: TPoint;
  CurrentDir: TDirection;
  I: Integer;
begin
  CurrentPos := TPoint.Zero;
  CurrentDir := N;

  for I := 0 to FSteps.Count - 1 do
    begin
      CurrentDir := Turn(FSteps[I].Direction, CurrentDir);
      case CurrentDir of
        N: Dec(CurrentPos.Y, FSteps[I].Steps);
        E: Inc(CurrentPos.X, FSteps[I].Steps);
        S: Inc(CurrentPos.Y, FSteps[I].Steps);
        W: Dec(CurrentPos.X, FSteps[I].Steps);
      end;
    end;

  Result := Abs(CurrentPos.X) + Abs(CurrentPos.Y);
end;

procedure TTask_AoC.LoadSteps;
var
  I: Integer;
  A: TArray<String>;
begin
  FSteps := TSteps.Create;
  with Input do
    try
      A := Text.Trim.Split([', ']);
      for I := 0 to Length(A) - 1 do
        FSteps.Add(TStep.Create(A[I]));
    finally
      Free;
    end;
end;

function TTask_AoC.Turn(const TurnDir, CurrDir: TDirection): TDirection;
begin
  Result := L;
  case TurnDir of
    L: Result := TDirection((4 + Integer(CurrDir) - Integer(N) - 1) mod 4 + Integer(N));
    R: Result := TDirection((4 + Integer(CurrDir) - Integer(N) + 1) mod 4 + Integer(N));
  end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 1, 'No Time for a Taxicab');

finalization
  GTask.Free;

end.
