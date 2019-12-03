unit uTask_2016_09;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    function DecompresedSize(S: String): Integer;
    function AdvDecompresedSize(S: String): Int64;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.AdvDecompresedSize(S: String): Int64;

type
  TCommand = record
    Count, Times: Integer;
    S: String;
    EndPos: Integer;
    IsFinal: Boolean;
  end;

  function GetCmd(const S: String): TCommand;
  var
    Pos: Integer;
    A: TArray<String>;
  begin
    Pos := S.IndexOf(')');
    A := S.Substring(1, Pos - 1).Split(['x']);
    Result.Count := A[0].ToInteger;
    Result.Times := A[1].ToInteger;
    Result.EndPos := Pos + Result.Count;
    Result.S := S.Substring(Pos + 1, Result.EndPos - Pos);
    Result.IsFinal := not Result.S.Contains('(');
  end;

  function ProcessCmd: Int64;
  var
    Command: TCommand;
  begin
    Result := 0;
    Command := GetCmd(S);
    if Command.IsFinal then
      Inc(Result, Command.Count * Command.Times)
    else
      Inc(Result, AdvDecompresedSize(Command.S) * Command.Times);

    S := S.Remove(0, Command.EndPos + 1);
  end;

begin
  Result := 0;
  while S.Length > 0 do
    Inc(Result, ProcessCmd)
end;

function TTask_AoC.DecompresedSize(S: String): Integer;

  function ProcessCmd: Integer;
  var
    Pos, Count, Times: Integer;
    A: TArray<String>;
  begin
    Pos := S.IndexOf(')');
    A := S.Substring(1, Pos - 1).Split(['x']);
    Count := A[0].ToInteger;
    Times := A[1].ToInteger;
    Result := Count * Times;
    S := S.Remove(0, Pos + Count + 1);
  end;

begin
  Result := 0;
  while S.Length > 0 do
    Inc(Result, ProcessCmd)
end;

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      OK('Part 1: %d, Part 2: %d', [ DecompresedSize(Text.Trim), AdvDecompresedSize(Text.Trim) ]);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 9, 'Explosives in Cyberspace');

finalization
  GTask.Free;

end.
