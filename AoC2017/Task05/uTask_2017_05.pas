unit uTask_2017_05;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FJumps: TArray<Integer>;
    procedure ReadJumps;
    function JumpOutSteps(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  OK('Part 1: %d, Part 2: %d', [ JumpOutSteps(1), JumpOutSteps(2) ])
end;

function TTask_AoC.JumpOutSteps(const Part: Integer): Integer;
var
  L, I, This: Integer;
begin
  Result := 0;
  ReadJumps;
  L := Length(FJumps);
  I := 0;
  while (I < L) and (I >= 0) do
    begin
      This := I;
      Inc(I, FJumps[I]);
      case Part of
        1:
          Inc(FJumps[This]);
        2:
          if FJumps[This] >= 3 then
            Dec(FJumps[This])
          else
            Inc(FJumps[This]);
      end;
      Inc(Result);
    end;
  SetLength(FJumps, 0);
end;

procedure TTask_AoC.ReadJumps;
var
  I: Integer;
begin
  with Input do
    try
      SetLength(FJumps, Count);
      for I := 0 to Count - 1 do
        FJumps[I] := Strings[I].ToInteger;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 5, 'A Maze of Twisty Trampolines, All Alike');

finalization
  GTask.Free;

end.
