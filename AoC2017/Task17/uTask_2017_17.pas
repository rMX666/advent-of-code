unit uTask_2017_17;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FSteps: Integer;
    function After2017: Integer;
    function After0: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Generics.Collections, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.After0: Integer;
var
  I, Pos: Integer;
begin
  Result := 0;
  Pos := 0;
  for I := 1 to 50000000 do
    begin
      Pos := (Pos + FSteps) mod I + 1;
      if Pos = 1 then
        Result := I;
    end;
end;

function TTask_AoC.After2017: Integer;
var
  L: TList<Integer>;
  I, Pos: Integer;
begin
  L := TList<Integer>.Create;

  try
    L.Add(0);

    Pos := 0;
    for I := 1 to 2017 do
      begin
        Pos := (Pos + I + FSteps) mod L.Count + 1;
        L.Insert(Pos, I);
      end;

    Result := L[L.IndexOf(2017) + 1];
  finally
    L.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      FSteps := Text.Trim.ToInteger;
    finally
      Free;
    end;

  OK('Part 1: %d, Part 2: %d', [ After2017, After0 ]);
end;


initialization
  GTask := TTask_AoC.Create(2017, 17, 'Spinlock');

finalization
  GTask.Free;

end.
