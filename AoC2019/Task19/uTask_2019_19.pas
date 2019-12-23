unit uTask_2019_19;

interface

uses
  uTask, IntCode, System.Types;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function IsPulled(const X, Y: Integer): Boolean;
    function CountBeamPoints: Integer;
    function SquareCordinates: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.IsPulled(const X, Y: Integer): Boolean;
begin
  with TIntCode.Create(FInitialState) do
    try
      AddInput(X);
      AddInput(Y);
      if Execute <> erHalt then
         raise Exception.Create('Wrong execution result');
      Result := Output.Last = 1;
    finally
      Free;
    end;
end;

function TTask_AoC.CountBeamPoints: Integer;
var
  X, Y, LastOneY: Integer;
  GotOne: Boolean;
begin
  Result := 0;

  LastOneY := 0;
  for X := 0 to 49 do
    begin
      GotOne := False;
      for Y := LastOneY to 49 do
        if IsPulled(X, Y) then
          begin
            Inc(Result);
            if not GotOne then
              begin
                GotOne := True;
                LastOneY := Y;
              end;
          end
        else if GotOne then
          Break;
    end;
end;

function TTask_AoC.SquareCordinates: Integer;
var
  X, Y: Integer;
begin
  Y := 99;
  X := 0;
  while not IsPulled(X + 99, Y - 99) do
    begin
      Inc(Y);
      while not IsPulled(X, Y) do
        Inc(X);
    end;
  Result := 10000 * X + Y - 99;
end;

procedure TTask_AoC.DoRun;
begin
  LoadProgram;
  try
    OK('Part 1: %d, Part 2: %d', [ CountBeamPoints, SquareCordinates ]);
  finally
    FInitialState.Free;
  end;
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TIntCode.Create(Text);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 19, 'Tractor Beam');

finalization
  GTask.Free;

end.
