unit uTask_2015_10;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  protected
    function LookAndSay(const Start: String; const Iterations: Integer): Integer;
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  Start: String;
begin
  with Input do
    try
      Start := Text.Trim;
    finally
      Free;
    end;

  OK('Part 1: %d, Part 2: %d', [ LookAndSay(Start, 40), LookAndSay(Start, 50) ]);
end;

function TTask_AoC.LookAndSay(const Start: String; const Iterations: Integer): Integer;
var
  I: Integer;
  Step: String;

  function GetSameCount(const Start: Integer): Integer;
  var
    C: Char;
    I: Integer;
  begin
    C := Step[Start];
    I := Start + 1;
    Result := 1;
    while (C = Step[I]) and (I <= Step.Length) do
      begin
        Inc(Result);
        Inc(I);
      end;
  end;

  function Iterate: Integer;
  var
    NextStep: String;
    I, SameCount: Integer;
  begin
    NextStep := '';
    I := 1;
    while I <= Step.Length do
      begin
        SameCount := GetSameCount(I);
        NextStep := NextStep + SameCount.ToString + Step[I];
        Inc(I, SameCount);
      end;

    Step := NextStep;
    Result := NextStep.Length;
  end;

begin
  Result := 0;
  Step := Start;
  for I := 1 to Iterations do
    Result := Iterate;
end;

initialization
  GTask := TTask_AoC.Create(2015, 10, 'Elves Look, Elves Say');

finalization
  GTask.Free;

end.
