unit uTask_2018_21;

interface

uses
  uTask, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    procedure Reverse(out Part1, Part2: Int64);
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
var
  Part1, Part2: Int64;
begin
  Reverse(Part1, Part2);

  OK(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
end;

procedure TTask_AoC.Reverse(out Part1, Part2: Int64);
label
  INIT, MAIN_LOOP, LOOP;
var
  R: array [0..5] of Int64;
  R4List: TDictionary<Int64,Boolean>;
begin
  R4List := TDictionary<Int64,Boolean>.Create;

  try
    FillChar(R, SizeOf(R), 0);

    {
      // Skip test instructions
      seti 123 0 1
      bani 1 456 1
      eqri 1 72 1
      addr 1 2 2
      seti 0 0 2
      seti 0 9 1
    }

  INIT:
    R[4] := R[1] or $10000; // bori 1 65536 4
    R[1] := $F8B118;        // seti 16298264 8 1

    repeat
      R[1] := (((R[1] + (R[4] and $ff)) and $FFFFFF) * $1016B) and $FFFFFF; // bani 4 255 5
                                                                            // addr 1 5 1
                                                                            // bani 1 16777215 1
                                                                            // muli 1 65899 1
                                                                            // bani 1 16777215 1

      // gtir 256 4 5
      // addr 5 2 2
      // addi 2 1 2
      // seti 27 1 2
      // vvvvvvvvvvvvv
      if 256 > R[4] then
        begin
          if R[1] = R[0] then // eqrr 1 0 5
            Exit              // addr 5 2 2
          else
            begin
              R[4] := R[1] or $10000;
              if R4List.ContainsKey(R[4]) then
                begin
                  Part2 := R[4];
                  Exit;
                end;
              if R4List.Count = 0 then
                Part1 := R[4];
              R4List.Add(R[4], True);
              goto INIT;        // seti 5 3 2
            end;
        end;

      R[5] := 0;              // seti 0 3 5
      repeat
        R[3] := (R[5] + 1) * $100; // addi 5 1 3
                                   // muli 3 256 3

        Inc(R[5]); // addi 5 1 5
                   // seti 17 1 2
        // gtrr 3 4 3
        // addr 3 2 2
        // addi 2 1 2
        // seti 25 4 2
        // vvvvvvvvvvvvv
      until R[3] > R[4];

      R[4] := R[5] - 1; // setr 5 3 4
    until False;
  finally
    R4List.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 21, 'Chronal Conversion');

finalization
  GTask.Free;

end.
