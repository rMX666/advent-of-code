unit uTask_2018_09;

interface

uses
  uTask, uUtil;

type
  TTask_AoC = class (TTask)
  private
    FPlayerCount: Integer;
    FMaxNumber: Integer;
    function GetHighScore(const MaxNumber: Integer): Int64;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Generics.Collections;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  A: TArray<String>;
begin
  with Input do
    try
      A := Text.Trim.Split([' ']);
      FPlayerCount := A[0].ToInteger;
      FMaxNumber := A[6].ToInteger;
    finally
      Free;
    end;

  OK('Part 1: %d, Part 2: %d', [ GetHighScore(FMaxNumber), GetHighScore(FMaxNumber * 100) ]);
end;

function TTask_AoC.GetHighScore(const MaxNumber: Integer): Int64;
var
  Players: TArray<Int64>;
  Marbles: PNode;
  I, CurrentPlayer: Integer;
begin
  SetLength(Players, FPlayerCount);

  Marbles := TNode.Pointer(0);
  Marbles := Marbles.Push(1);
  CurrentPlayer := 1;

  for I := 2 to MaxNumber do
    if I mod 23 = 0 then
      begin
        Inc(Players[CurrentPlayer], I);
        Marbles := Marbles.Rotate(-7);
        Inc(Players[CurrentPlayer], Marbles.Data);
        Marbles := Marbles.Pop.Rotate(1);
        CurrentPlayer := (CurrentPlayer + 1) mod FPlayerCount;
      end
    else
      begin
        Marbles := Marbles.Rotate(1);
        Marbles := Marbles.Push(I);
        CurrentPlayer := (CurrentPlayer + 1) mod FPlayerCount;
      end;

  Marbles.Free;

  Result := 0;
  for I := 0 to FPlayerCount - 1 do
    if Result < Players[I] then
      Result := Players[I];
end;

initialization
  GTask := TTask_AoC.Create(2018, 9, 'Marble Mania');

finalization
  GTask.Free;

end.
