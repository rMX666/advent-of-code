unit uTask_2017_10;

interface

uses
  uTask, uKnotHash;

type
  TTask_AoC = class (TTask)
  private
    function ParseKey: TKnotKey;
    function GetInputValue: String;
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
var
  Part1: Integer;
begin
  with TKnotHash.Create(ParseKey) do
    try
      Hash;
      Part1 := RawList[0] * RawList[1];
    finally
      Free;
    end;

  OK('Part 1: %d, Part 2: %s', [ Part1, TKnotHash.HashHex(GetInputValue) ]);
end;

function TTask_AoC.GetInputValue: String;
begin
  with Input do
    try
      Result := Text.Trim;
    finally
      Free;
    end;
end;

function TTask_AoC.ParseKey: TKnotKey;
var
  I: Integer;
  A: TArray<String>;
begin
  with Input do
    try
      A := Text.Trim.Split([',']);
      SetLength(Result, Length(A));
      for I := 0 to Length(A) - 1 do
        Result[I] := A[I].ToInteger;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 10, 'Knot Hash');

finalization
  GTask.Free;

end.
