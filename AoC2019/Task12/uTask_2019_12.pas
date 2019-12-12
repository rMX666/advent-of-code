unit uTask_2019_12;

interface

uses
  uTask, System.Generics.Collections, System.Generics.Defaults;

type
  TMoon = class
  private
    FC: array [0..2] of Integer;
    FV: array [0..2] of Integer;
    function GetEnergy: Integer;
  public
    constructor Create(const S: String);
    procedure CalcVelocity(const Moon: TMoon);
    procedure Move;
    property Energy: Integer read GetEnergy;
  end;

  TTask_AoC = class (TTask)
  private
    FMoons: TObjectList<TMoon>;
    procedure LoadMoons;
    procedure StepMoons;
    function GetSystemEnergy(const Steps: Integer): Integer;
    function FindRepeatingState: Int64;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uUtil;

var
  GTask: TTask_AoC;

{ TMoon }

constructor TMoon.Create(const S: String);
var
  A: TArray<String>;
  I: Integer;
begin
  A := S.Replace('>', '').Split([', ']);
  for I := 0 to 2 do
    begin
      FC[I] := A[I].Split(['='])[1].ToInteger;
      FV[I] := 0;
    end;
end;

procedure TMoon.CalcVelocity(const Moon: TMoon);
var
  I: Integer;
begin
  for I := 0 to 2 do
    if FC[I] < Moon.FC[I] then
      Inc(FV[I])
    else if FC[I] > Moon.FC[I] then
      Dec(FV[I]);
end;

function TMoon.GetEnergy: Integer;
var
  I, Pot, Kin: Integer;
begin
  Pot := 0;
  Kin := 0;
  for I := 0 to 2 do
    begin
      Inc(Pot, Abs(FC[I]));
      Inc(Kin, Abs(FV[I]));
    end;
  Result := Pot * Kin;
end;

procedure TMoon.Move;
var
  I: Integer;
begin
  for I := 0 to 2 do
    Inc(FC[I], FV[I]);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  OK('Part 1: %d, Part 2: %d', [ GetSystemEnergy(1000), FindRepeatingState ]);
end;

function TTask_AoC.FindRepeatingState: Int64;
var
  I, J: Integer;
  T: Boolean;
  P: array of array [0..2] of Integer; // Initial position of moons
  C: array [0..2] of Int64;            // Count to repeat of cordinate index
  D: array [0..2] of Boolean;          // True if repeat found
begin
  LoadMoons;
  try
    // Save initial state
    SetLength(P, FMoons.Count);
    for I := 0 to FMoons.Count - 1 do
      for J := 0 to 2 do
        P[I, J] := FMoons[I].FC[J];

    for I := 0 to 2 do
      begin
        C[I] := 0;
        D[I] := False;
      end;

    while not (D[0] and D[1] and D[2]) do
      begin
        StepMoons;

        for I := 0 to 2 do
          // If the cordinate is not repeating yet
          if not D[I] then
            begin
              T := True;
              // Within all moons check given cordinate...
              for J := 0 to FMoons.Count - 1 do
                // ... for equality with initial state's cordinate
                // and if the velocity to be equal to zero
                if (FMoons[J].FC[I] <> P[J, I]) or (FMoons[J].FV[I] <> 0) then
                  begin
                    T := False;
                    Break;
                  end;
              D[I] := T;
              Inc(C[I]);
            end;
      end;

    // The answer is the least common multiple of the points when each cordinate starts to repeat
    Result := 1;
    for I := 0 to 2 do
      Result := LCM(Result, C[I]);
  finally
    FMoons.Free;
  end;
end;

function TTask_AoC.GetSystemEnergy(const Steps: Integer): Integer;
var
  I: Integer;
begin
  LoadMoons;
  try
    for I := 1 to Steps do
      StepMoons;

    Result := 0;
    for I := 0 to FMoons.Count - 1 do
      Inc(Result, FMoons[I].GetEnergy);
  finally
    FMoons.Free;
  end;
end;

procedure TTask_AoC.LoadMoons;
var
  I: Integer;
begin
  FMoons := TObjectList<TMoon>.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FMoons.Add(TMoon.Create(Strings[I]));
    finally
      Free;
    end;
end;

procedure TTask_AoC.StepMoons;
var
  I, J: Integer;
begin
  for I := 0 to FMoons.Count - 1 do
    for J := 0 to FMoons.Count - 1 do
      if I <> J then
        FMoons[I].CalcVelocity(FMoons[J]);
  for I := 0 to FMoons.Count - 1 do
    FMoons[I].Move;
end;

initialization
  GTask := TTask_AoC.Create(2019, 12, 'The N-Body Problem');

finalization
  GTask.Free;

end.
