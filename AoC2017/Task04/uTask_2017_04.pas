unit uTask_2017_04;

interface

uses
  System.Classes, System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FPhrases: TStrings;
    function NoDuplicates: Integer;
    function NoAnagrams: Integer;
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
  FPhrases := Input;

  try
    OK('Part 1: %d, Part 2: %d', [ NoDuplicates, NoAnagrams ]);
  finally
    FPhrases.Free;
  end;
end;

function TTask_AoC.NoAnagrams: Integer;

  function IsAnagram(A, B: String): Boolean;
  var
    I: Integer;
  begin
    if A.Length <> B.Length then
      Exit(False);

    for I := 1 to A.Length do
      B := B.Remove(B.IndexOf(A[I]), 1);

    Result := B = '';
  end;

label
  GoOn;
var
  Words: TArray<String>;
  I, J, K: Integer;
begin
  Result := 0;
  for I := 0 to FPhrases.Count - 1 do
    begin
      Words := FPhrases[I].Split([' ']);

      for J := 0 to Length(Words) - 1 do
        for K := J + 1 to Length(Words) - 1 do
          if IsAnagram(Words[J], Words[K]) then
            goto GoOn; // I don't care about Raptors :)

      Inc(Result);
      GoOn: // Just to skip increment
    end;
end;

function TTask_AoC.NoDuplicates: Integer;
var
  I, J: Integer;
  Words: TArray<String>;
  Failed: Boolean;
begin
  Result := 0;

  for I := 0 to FPhrases.Count - 1 do
    begin
      Words := FPhrases[I].Split([' ']);
      TArray.Sort<String>(Words);
      Failed := False;
      for J := 0 to Length(Words) - 2 do
        if Words[J] = Words[J + 1] then
          begin
            Failed := True;
            Break;
          end;
      if not Failed then
        Inc(Result);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 4, 'High-Entropy Passphrases');

finalization
  GTask.Free;

end.
