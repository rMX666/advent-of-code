unit uTask_2015_05;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    function IsNice(const Part: Integer; const S: String): Boolean;
    function CountNiceStrings(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.IsNice(const Part: Integer; const S: String): Boolean;
const
  Vowels: String = 'aeiou';
  Forbidden: Array [0..3] of String = ( 'ab', 'cd', 'pq', 'xy' );

  function HasVowel: Boolean;
  var
    I, Count: Integer;
  begin
    Result := False;
    Count := 0;

    for I := 1 to S.Length do
      if Vowels.Contains(S[I]) then
        begin
          Inc(Count);

          if Count = 3 then
            Exit(True);
        end;
  end;

  function HasDouble: Boolean;
  var
    I: Integer;
  begin
    Result := False;

    for I := 1 to S.Length - 1 do
      if S[I] = S[I + 1] then
        Exit(True);
  end;

  function HasForbidden: Boolean;
  var
    I: Integer;
  begin
    Result := False;

    for I := 0 to 3 do
      if S.Contains(Forbidden[I]) then
        Exit(True);
  end;

  function HasDoubleDouble: Boolean;
  var
    I: Integer;
    J: Integer;
  begin
    Result := False;

    for I := 1 to S.Length - 3 do
      for J := I + 2 to S.Length - 1 do
        if S[I] + S[I + 1] = S[J] + S[J + 1] then
          Exit(True);
  end;

  function HasXYXPattern: Boolean;
  var
    I: Integer;
  begin
    Result := False;

    for I := 1 to S.Length - 2 do
      if S[I] = S[I + 2] then
        Exit(True);
  end;

begin
  case Part of
    1: Result := HasVowel and HasDouble and (not HasForbidden);
    2: Result := HasDoubleDouble and HasXYXPattern;
  end;
end;

function TTask_AoC.CountNiceStrings(const Part: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;

  with Input do
    try
      for I := 0 to Count - 1 do
        if IsNice(Part, Strings[I]) then
          Inc(Result);
    finally
      Free;
    end;
end;

procedure TTask_AoC.DoRun;
begin
  Ok(Format('Part 1: %d, Part 2: %d', [ CountNiceStrings(1), CountNiceStrings(2) ]));
end;

initialization
  GTask := TTask_AoC.Create(2015, 5, 'Doesn''t He Have Intern-Elves For This?');

finalization
  GTask.Free;

end.
