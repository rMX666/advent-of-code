unit uTask_2017_03;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FInput: Integer;
    function Part1: Integer;
    function Part2: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.Types, System.Generics.Collections, System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      FInput := Text.Trim.ToInteger;
    finally
      Free;
    end;

  OK(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
end;

function TTask_AoC.Part1: Integer;
var
  I: Integer;
begin
  // Find resulting spiral turn
  I := 1;
  while I * I < FInput do
    Inc(I, 2);

  Result := (I * I - FInput);
  I := I div 2;
  if (Result div I) mod 2 = 0 then
    Result := I - (Result mod I)
  else
    Result := Result mod I;
  Inc(Result, I);
end;

function TTask_AoC.Part2: Integer;
var
  Spiral: TDictionary<TPoint,Integer>;

  function GetSum(const P: TPoint): Integer;
  const
    Directions: array[0..7] of TPoint =
      (
        ( X:  0; Y:  1 )
      , ( X:  0; Y: -1 )
      , ( X:  1; Y:  1 )
      , ( X:  1; Y:  0 )
      , ( X:  1; Y: -1 )
      , ( X: -1; Y:  1 )
      , ( X: -1; Y:  0 )
      , ( X: -1; Y: -1 )
      );
  var
    I: Integer;
    Next: TPoint;
  begin
    Result := 0;
    for I := 0 to 7 do
      begin
        Next := P + Directions[I];
        if Spiral.ContainsKey(Next) then
          Inc(Result, Spiral[Next]);
      end;
  end;

  function NextStep(const P: TPoint; const TurnSize: Integer): TPoint;
  var
    TurnHalf: Integer;
  begin
    Result := TPoint.Create(P);
    TurnHalf := TurnSize div 2;

    {
       ^
       |
     2<|<1
     V | ^
    ---+--->
     V | ^
     3>|>4
       |
    }

    // 1
    if      (P.X >= 0) and (P.Y >= 0) and (P.Y = TurnHalf)  then Dec(Result.X)
    else if (P.X >= 0) and (P.Y >= 0) and (P.X = TurnHalf)  then Inc(Result.Y)
    // 2
    else if (P.X < 0)  and (P.Y >= 0) and (P.X = -TurnHalf) then Dec(Result.Y)
    else if (P.X < 0)  and (P.Y >= 0) and (P.Y = TurnHalf)  then Dec(Result.X)
    // 3
    else if (P.X < 0)  and (P.Y < 0)  and (P.Y = -TurnHalf) then Inc(Result.X)
    else if (P.X < 0)  and (P.Y < 0)  and (P.X = -TurnHalf) then Dec(Result.Y)
    // 4
    else if (P.X >= 0) and (P.Y < 0)  and (P.X = TurnHalf)  then Inc(Result.Y)
    else if (P.X >= 0) and (P.Y < 0)  and (P.Y = -TurnHalf) then Inc(Result.X);
  end;

var
  Current: TPoint;
  TurnSize, StepNumber: Integer;
begin
  Result := 0;
  Spiral := TDictionary<TPoint,Integer>.Create;

  try
    Spiral.Add(TPoint.Create(0, 0), 1);

    TurnSize := 1;
    StepNumber := 1;
    Current := TPoint.Zero;
    while Result < FInput do
      begin
        if StepNumber = TurnSize * TurnSize then
          begin
            Inc(Current.X);
            Inc(TurnSize, 2);
          end
        else
          Current := NextStep(Current, TurnSize);
        Result := GetSum(Current);
        Spiral.Add(Current, Result);
        Inc(StepNumber);
      end;
  finally
    Spiral.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 3, 'Spiral Memory');

finalization
  GTask.Free;

end.
