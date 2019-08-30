unit uTask_2018_19;

interface

uses
  uTask, uProgram_2018_19;

type
  TTask_AoC = class (TTask)
  private
    FProgram: TProgram;
    procedure LoadProgram;
    {$Hints off}
    procedure Reverse;
    {$Hints on}
    function SumOfDivisors: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uForm_2018_19;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  Part1State: TState;
begin
//  Reverse;
  LoadProgram;

  FillChar(Part1State, SizeOf(Part1State), 0);

  {
  // Uncomment to run debugger
  fMain_2018_19 := TfMain_2018_19.Create(nil);
  fMain_2018_19.SetProgram(FProgram);
  FProgram.Execute(Part1State, True);
  fMain_2018_19.ShowModal;
//  }

  try
    OK(Format('Part 1: %d, Part 2: %d', [ FProgram.Execute(Part1State)[0], SumOfDivisors ]))
  finally
    FProgram.Free;
  end;
end;

procedure TTask_AoC.LoadProgram;
var
  I: Integer;
begin
  FProgram := TProgram.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        if Strings[I].StartsWith('#') then
          FProgram.SetIPRegister(Strings[I].Split([' '])[1].ToInteger)
        else
          FProgram.Add(TOp.Create(Strings[I]));
    finally
      Free;
    end;
end;

// Turned out that this is just a very unefficient algorithm of finding sum of divisors of a number
{$Hints off}
procedure TTask_AoC.Reverse;
label
  MAIN_LOOP, MAIN_LOOP1, INNER_LOOP;
var
  r0, r1, r2, r3, r4, r5: Integer;
begin
  r0 := 1;
  r1 := 0;
  r2 := 0;
  r3 := 17; // addi 3 16 3
  r4 := 0;
  r5 := 0;

  r4 := r4 + 2;  Inc(r3); // addi 4 2 4
  r4 := r4 * r4; Inc(r3); // mulr 4 4 4
  r4 := r4 * r3; Inc(r3); // mulr 3 4 4
  r4 := r4 * 11; Inc(r3); // muli 4 11 4
  r1 := r1 + 6;  Inc(r3); // addi 1 6 1
  r1 := r1 * r3; Inc(r3); // mulr 1 3 1
  r1 := r1 + 10; Inc(r3); // addi 1 10 1
  r4 := r4 + r1; Inc(r3); // addr 4 1 4

  r3 := r3 + r0; Inc(r3); // addr 3 0 3
  if r0 = 0 then
    begin
      r3 := 1; // seti 0 0 3
      goto MAIN_LOOP;
    end;

  r1 := r3;      Inc(r3); // setr 3 9 1
  r1 := r1 * r3; Inc(r3); // mulr 1 3 1
  r1 := r3 + r1; Inc(r3); // addr 3 1 1
  r1 := r3 * r1; Inc(r3); // mulr 3 1 1
  r1 := r1 * 14; Inc(r3); // muli 1 14 1
  r1 := r1 * r3; Inc(r3); // mulr 1 3 1
  r4 := r4 + r1; Inc(r3); // addr 4 1 4
  r0 := 0;       Inc(r3); // seti 0 4 0
  r3 := 0;       Inc(r3); // seti 0 0 3
  goto MAIN_LOOP;

  MAIN_LOOP:
    r5 := 1;                              Inc(r3); // seti 1 6 5
  MAIN_LOOP1:
    r2 := 1;                              Inc(r3); // seti 1 8 2

  INNER_LOOP:
    r1 := r5 * r2;                        Inc(r3); // mulr 5 2 1

    if r1 = r4 then r1 := 1 else r1 := 0; Inc(r3); // eqrr 1 4 1
    r3 := r1 + r3;                        Inc(r3); // addr 1 3 3
    if r1 = 0 then                                 // addi 3 1 3
      begin r3 := r3 + 1;  Inc(r3); end
    else                                           // addr 5 0 0
      begin r0 := r5 + r0; Inc(r3); end;

    r2 := r2 + 1;                         Inc(r3); // addi 2 1 2
    if r2 > r4 then r1 := 1 else r1 := 0; Inc(r3); // gtrr 2 4 1
    r3 := r3 + r1;                        Inc(r3); // addr 3 1 3
    if r1 = 0 then                                 // seti 2 3 3
      begin r3 := 3; goto INNER_LOOP; end;

    r5 := r5 + 1;                         Inc(r3); // addi 5 1 5

    if r5 > r4 then r1 := 1 else r1 := 0; Inc(r3); // gtrr 5 4 1
    r3 := r3 + r1;                        Inc(r3); // addr 1 3 3
    if r1 = 0 then                                 // seti 1 8 3
      begin r3 := 2; goto MAIN_LOOP1; end
    else                                           // mulr 3 3 3
      begin r3 := r3 * r3; Exit; end;
end;
{$Hints on}

function TTask_AoC.SumOfDivisors: Integer;
var
  I, Num: Integer;
  InitialState: TState;
begin
  FillChar(InitialState, SizeOf(InitialState), 0);
  InitialState[0] := 1;
  FProgram.Execute(InitialState, True);
  // Do some steps and take a number from register 4
  for I := 0 to 1000 do
    FProgram.Step;
  Num := FProgram.State[4];

  // Find sum of all divisors of number
  Result := Num;
  for I := 1 to Num div 2 + 1 do
    if Num mod I = 0 then
      Inc(Result, I);
end;

initialization
  GTask := TTask_AoC.Create(2018, 19, 'Go With The Flow');

finalization
  GTask.Free;

end.
