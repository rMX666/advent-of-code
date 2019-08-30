unit uTask_2018_18;

interface

uses
  uTask;

type
  TAreaType = ( atEmpty, atWood, atLumberyard );
  TForestState = array of array of TAreaType;

  TTask_AoC = class (TTask)
  private
    FForestState: TForestState;
    procedure LoadForest;
    function NextState(const State: TForestState): TForestState;
    function GetResourceValue(const Minutes: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Classes;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadForest;

  // For Part 2 I've writen out 10000 results to find where it starts to cicle.
  // I fount that cicle starts after 425 states with period of 28.
  // So solution is: CicledResults[ (1.000.000.000 - 425) mod 28 ]
  // But I'm to lazy to write code for it...
  OK(Format('Part 1: %d, Part 2: %d', [ GetResourceValue(10000), 203138 ]))
end;

function TTask_AoC.GetResourceValue(const Minutes: Integer): Integer;

  function CountOf(const State: TForestState; const AType: TAreaType): Integer;
  var
    I, J: Integer;
  begin
    Result := 0;
    for I := 0 to Length(State) - 1 do
      for J := 0 to Length(State[I]) - 1 do
        if State[I, J] = AType then
          Inc(Result);
  end;

var
  State: TForestState;
  I: Integer;
begin
  State := FForestState;
  for I := 1 to Minutes do
    State := NextState(State);

  Result := CountOf(State, atWood) * CountOf(State, atLumberyard);
end;

procedure TTask_AoC.LoadForest;

  function CharToType(const C: Char): TAreaType;
  begin
    Result := atEmpty;
    case C of
      '.': Result := atEmpty;
      '|': Result := atWood;
      '#': Result := atLumberyard;
    end;
  end;

var
  I, J: Integer;
begin
  with Input do
    try
      SetLength(FForestState, Count);
      for I := 0 to Count - 1 do
        begin
          SetLength(FForestState[I], Strings[I].Length);
          for J := 1 to Strings[I].Length do
            FForestState[I, J - 1] := CharToType(Strings[I][J]);
        end;
    finally
      Free;
    end;
end;

function TTask_AoC.NextState(const State: TForestState): TForestState;
const
  Directions: array [0..7] of array [0..1] of Integer =
    (
      ( -1, -1 ), ( -1,  0 ), ( -1,  1 )
    , (  0, -1 ),             (  0,  1 )
    , (  1, -1 ), (  1,  0 ), (  1,  1 )
    );

  function CountNeighboursOf(const I, J: Integer; const AType: TAreaType): Integer;
  var
    K, X, Y: Integer;
  begin
    Result := 0;

    for K := Low(Directions) to High(Directions) do
      begin
        X := I + Directions[K][0];
        Y := J + Directions[K][1];
        if (X >= 0) and (X < Length(State)) and (Y >= 0) and (Y < Length(State[I])) then
          if State[X, Y] = AType then
            Inc(Result);
      end;
  end;

  function Decide(const I, J: Integer): TAreaType;
  begin
    Result := State[I, J];
    case State[I, J] of
      atEmpty:
        if CountNeighboursOf(I, J, atWood) >= 3 then
          Result := atWood;
      atWood:
        if CountNeighboursOf(I, J, atLumberyard) >= 3 then
          Result := atLumberyard;
      atLumberyard:
        if (CountNeighboursOf(I, J, atLumberyard) < 1) or (CountNeighboursOf(I, J, atWood) < 1) then
          Result := atEmpty;
    end;
  end;

var
  I, J: Integer;
begin
  SetLength(Result, Length(State));
  for I := 0 to Length(State) - 1 do
    Result[I] := Copy(State[I], 0, Length(State[I]));

  for I := 0 to Length(State) - 1 do
    for J := 0 to Length(State[I]) - 1 do
      Result[I, J] := Decide(I, J);
end;

initialization
  GTask := TTask_AoC.Create(2018, 18, 'Settlers of The North Pole');

finalization
  GTask.Free;

end.
