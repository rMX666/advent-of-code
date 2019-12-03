unit uTask_2015_01;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FInput: String;
    procedure Part1;
    procedure Part2;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      FInput := Text;
    finally
      Free;
    end;

  Part1;
  Part2;
end;

procedure TTask_AoC.Part1;
var
  I, Floor: Integer;
begin
  Floor := 0;
  for I := 1 to Length(FInput) do
    case FInput[I] of
      '(': Inc(Floor);
      ')': Dec(Floor);
    end;
  OK('Part 1: %d', [ Floor ]);
end;

procedure TTask_AoC.Part2;
var
  I, Floor: Integer;
begin
  Floor := 0;
  for I := 1 to Length(FInput) do
    begin
      case FInput[I] of
        '(': Inc(Floor);
        ')': Dec(Floor);
      end;
      if Floor = -1 then
        Break;
    end;
  OK('Part 2: %d', [ I ]);
end;

initialization
  GTask := TTask_AoC.Create(2015, 1, 'Not Quite Lisp');

finalization
  GTask.Free;

end.
