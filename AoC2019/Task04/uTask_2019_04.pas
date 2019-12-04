unit uTask_2019_04;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FBegin, FEnd: Integer;
    procedure LoadRange;
    function PasswordCount(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, Windows;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  StartTime, EndTime, Freq: Int64;
  Part1, Part2: Integer;
begin
  LoadRange;

  QueryPerformanceFrequency(Freq);
  Freq := Freq div 1000000;
  QueryPerformanceCounter(StartTime);

  Part1 := PasswordCount(1);
  Part2 := PasswordCount(2);

  QueryPerformanceCounter(EndTime);

  OK('Part 1: %d, Part 2: %d, Time: %d', [ Part1, Part2, (EndTime - StartTime) div Freq ]);
end;


procedure TTask_AoC.LoadRange;
var
  A: TArray<String>;
begin
  with Input do
    try
      A := Text.Trim.Split(['-']);
      FBegin := A[0].ToInteger;
      FEnd   := A[1].ToInteger;
    finally
      Free;
    end;
end;

function TTask_AoC.PasswordCount(const Part: Integer): Integer;
type
  TPasswordCheckResult = ( pcrOk, pcrNoDuplicate, pcrDecrementing );

  function CheckPassword(const Password: String): TPasswordCheckResult;
  var
    I: Integer;
    HasDuplicate: Boolean;
    TripleChar: Char;
    S: String;
  begin
    Result := pcrOk;
    HasDuplicate := False;
    case Part of
      1:
        begin
          for I := 1 to Password.Length - 1 do
            begin
              if Password[I] = Password[I + 1] then
                HasDuplicate := True;
              if Password[I] > Password[I + 1] then
                Exit(pcrDecrementing);
            end;
          if not HasDuplicate then
            Exit(pcrNoDuplicate);
        end;
      2:
        begin
          TripleChar := #0;    // Just something
          S := Password + '0'; // Here we try to get character after the end of string, so add something
          for I := 1 to Password.Length - 1 do
            begin
              // If there's group of more then two, remember it.
              if (S[I] = S[I + 1]) and (S[I + 1] = S[I + 2]) then
                TripleChar := S[I];
              // If there's group of two and it's not related to previous group of three, then password is good
              if (S[I] = S[I + 1]) and (S[I + 1] <> S[I + 2]) and (S[I] <> TripleChar) then
                HasDuplicate := True;
              if Password[I] > Password[I + 1] then
                Exit(pcrDecrementing);
            end;
          if not HasDuplicate then
            Exit(pcrNoDuplicate);
        end;
    end;
  end;

  procedure IncToNonDecrementing(var Password: Integer);
  var
    I, L: Integer;
    S: String;
  begin
    S := Password.ToString;
    L := S.Length;
    I := 1;
    // Find first character which is less then previous
    while (S[I] <= S[I + 1]) and (I < L) do
      Inc(I);

    if I < L then
      // Copy incrementing sequence and repear its last character
      Password := (S.Substring(0, I) + StringOfChar(S[I], L - I)).ToInteger;
  end;

var
  Password: Integer;
begin
  Result := 0;
  Password := FBegin;
  while Password <= FEnd do
    case CheckPassword(Password.ToString) of
      pcrOk:
        begin
          Inc(Result);
          Inc(Password);
        end;
      pcrNoDuplicate:
        Inc(Password);
      pcrDecrementing:
        // Find next non-decrementing password.
        // Drastically improves performance (about 300 times faster in my case).
        IncToNonDecrementing(Password);
        //Inc(Password);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 4, 'Secure Container');

finalization
  GTask.Free;

end.
