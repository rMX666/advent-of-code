unit uTask_2016_02;

interface

uses
  uTask;

type
  TKeyPad = TArray<String>;

  TTask_AoC = class (TTask)
  private
    FInstructions: TArray<String>;
    function GetCode(const KeyPad: TKeyPad): String;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Types;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
const
  Part1KP: String = '123$456$789';
  Part2KP: String = '##1##$#234#$56789$#ABC#$##D##';
var
  Part1, Part2: String;
begin
  with Input do
    try
      FInstructions := ToStringArray;
    finally
      Free;
    end;

  Part1 := GetCode(Part1KP.Split(['$']));
  Part2 := GetCode(Part2KP.Split(['$']));

  OK(Format('Part1: %s, Part 2: %s', [ Part1, Part2 ]));
end;

function TTask_AoC.GetCode(const KeyPad: TKeyPad): String;

  function Find5: TPoint;
  var
    I: Integer;
  begin
    Result := TPoint.Zero;
    for I := 0 to Length(KeyPad) - 1 do
      if KeyPad[I].IndexOf('5') >= 0 then
        Exit(TPoint.Create(KeyPad[I].IndexOf('5') - 1, I));
  end;

var
  I, J, L: Integer;
  Cur: TPoint;
begin
  Result := '';
  L := Length(KeyPad);
  Cur := Find5;
  for I := 0 to Length(FInstructions) - 1 do
    begin
      for J := 1 to FInstructions[I].Length do
        case FInstructions[I][J] of
          'U':
            if (Cur.Y > 0) and (KeyPad[Cur.Y - 1][Cur.X + 1] <> '#') then
              Dec(Cur.Y);
          'D':
            if (Cur.Y < L - 1) and (KeyPad[Cur.Y + 1][Cur.X + 1] <> '#') then
              Inc(Cur.Y);
          'L':
            if (Cur.X > 0) and (KeyPad[Cur.Y][Cur.X] <> '#') then
              Dec(Cur.X);
          'R':
            if (Cur.X < L - 1) and (KeyPad[Cur.Y][Cur.X + 2] <> '#') then
              Inc(Cur.X);
        end;
      Result := Result + KeyPad[Cur.Y][Cur.X + 1];
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 2, 'Bathroom Security');

finalization
  GTask.Free;

end.
