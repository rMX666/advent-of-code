unit uTask_2015_11;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    function GetNextPassword(const Password: String): String;
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
  Start, Part1, Part2: String;
begin
  with Input do
    try
      Start := Text.Trim;
    finally
      Free;
    end;

  Part1 := GetNextPassword(Start);
  Part2 := GetNextPassword(Part1);

  OK(Format('Part 1: %s, Part 2: %s', [ Part1, Part2 ]));
end;

function TTask_AoC.GetNextPassword(const Password: String): String;

  function IncChar(var C: Char): Boolean;
  begin
    Result := True;

    if C < 'z' then
      C := Chr(Ord(C) + 1)
    else
      begin
        C := 'a';
        Result := False;
      end;
  end;

  function IncStr(Password: String): String;
  var
    I: Integer;
    Stop: Boolean;
  begin
    I := Password.Length;

    while I > 0 do
      begin
        Stop := IncChar(Password[I]);
        if Stop then
          Exit(Password);

        Dec(I);
      end;
  end;

  function HasIOL(const Password: String): Boolean;
  begin
    Result := Password.Contains('i') or Password.Contains('o') or Password.Contains('l');
  end;

  function HasThreeSeq(const Password: String): Boolean;

    function NextChar(const C: Char): Char;
    begin
      Result := Chr(Ord(C) + 1);
    end;

  var
    I: Integer;
  begin
    Result := False;

    for I := 1 to Password.Length - 2 do
      if (NextChar(Password[I]) = Password[I + 1]) and (NextChar(Password[I + 1]) = Password[I + 2]) then
        Exit(True);
  end;

  function HasDoubleDouble(const Password: String): Boolean;
  var
    I: Integer;
    Count: Integer;
  begin
    I := 1;
    Count := 0;
    Result := False;

    while I <= Password.Length do
      begin
        if Password[I] = Password[I + 1] then
          begin
            Inc(Count);
            if Count = 2 then
              Exit(True);

            Inc(I);
          end;

        Inc(I);
      end;
  end;

var
  IsCorrect: Boolean;
begin
  IsCorrect := False;
  Result := Password;

  while not IsCorrect do
    begin
      Result := IncStr(Result);
      IsCorrect := HasThreeSeq(Result) and (not HasIOL(Result)) and HasDoubleDouble(Result);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 11, 'Corporate Policy');

finalization
  GTask.Free;

end.
