unit uTask_2015_18;

interface

uses
  uTask;

type
  TLife = Array of Array of Boolean;

  TTask_AoC = class (TTask)
  private
    FLife: TLife;
    procedure LoadLife;
    procedure Live(const Iterations: Integer; const LockCorners: Boolean);
    function CloneState: TLife;
    function CountOn: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Types, Vcl.Forms, uForm_2015_18;

const
  ITERATION_COUNT = 100;

  NEIGHBOUR_DIRECTIONS: Array [0..7] of TPoint =
    (
      ( X: -1; Y: -1 ),
      ( X: -1; Y:  0 ),
      ( X: -1; Y:  1 ),
      ( X:  0; Y: -1 ),
      ( X:  0; Y:  1 ),
      ( X:  1; Y: -1 ),
      ( X:  1; Y:  0 ),
      ( X:  1; Y:  1 )
    );

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.CloneState: TLife;
var
  I, J: Integer;
begin
  SetLength(Result, Length(FLife));
  for I := 0 to Length(FLife) - 1 do
    begin
      SetLength(Result[I], Length(FLife[I]));
      for J := 0 to Length(FLife[I]) - 1 do
        Result[I, J] := FLife[I, J];
    end;
end;

function TTask_AoC.CountOn: Integer;
var
  I, J: Integer;
begin
  Result := 0;

  for I := 0 to Length(FLife) - 1 do
    for J := 0 to Length(FLife[I]) - 1 do
      if FLife[I, J] then
        Inc(Result);
end;

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Integer;
begin
  fMain_2015_18 := TfMain_2015_18.Create(Application);
  with fMain_2015_18 do
    begin
      Show;

      LoadLife;
      Life := FLife;
      Live(ITERATION_COUNT, False);
      Part1 := CountOn;

      LoadLife;
      Life := FLife;
      Live(ITERATION_COUNT, True);
      Part2 := CountOn;
    end;

  OK('Part 1: %d, Part 2: %d', [ Part1, Part2 ]);
end;

procedure TTask_AoC.Live(const Iterations: Integer; const LockCorners: Boolean);

  function GetNeighbourCount(const X, Y: Integer; const State: TLife): Integer;
  var
    I, X1, Y1, LX, LY: Integer;
  begin
    Result := 0;

    LX := Length(State);
    LY := Length(State[0]);

    for I := 0 to 7 do
      begin
        X1 := NEIGHBOUR_DIRECTIONS[I].X + X;
        Y1 := NEIGHBOUR_DIRECTIONS[I].Y + Y;

        if (X1 >= 0) and (X1 < LX) and (Y1 >= 0) and (Y1 < LY) then
          if State[X1, Y1] then
            Inc(Result);
      end;
  end;

  procedure Step;
  var
    I, J, LX, LY: Integer;
    State: TLife;
  begin
    State := CloneState;
    LX := Length(State);
    LY := Length(State[0]);

    if LockCorners then
      begin
        State[0, 0] := True;
        State[LX - 1, 0] := True;
        State[0, LY - 1] := True;
        State[LX - 1, LY - 1] := True;
      end;

    for I := 0 to Length(State) - 1 do
      for J := 0 to Length(State[I]) - 1 do
        if State[I, J] then
          FLife[I, J] := GetNeighbourCount(I, J, State) in [ 2, 3 ]
        else
          FLife[I, J] := GetNeighbourCount(I, J, State) = 3;

    if LockCorners then
      begin
        FLife[0, 0] := True;
        FLife[LX - 1, 0] := True;
        FLife[0, LY - 1] := True;
        FLife[LX - 1, LY - 1] := True;
      end;
  end;

var
  I: Integer;
begin
  for I := 1 to Iterations do
    begin
      Step;
      fMain_2015_18.Repaint;
      Application.ProcessMessages;
      Sleep(20);
    end;
end;

procedure TTask_AoC.LoadLife;
var
  I, J: Integer;
begin
  with Input do
    try
      SetLength(FLife, Count);
      for I := 0 to Count - 1 do
        begin
          SetLength(FLife[I], Strings[I].Length);
          for J := 1 to Strings[I].Length do
            FLife[I, J - 1] := Strings[I][J] = '#';
        end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 18, 'Like a GIF For Your Yard');

finalization
  GTask.Free;

end.
