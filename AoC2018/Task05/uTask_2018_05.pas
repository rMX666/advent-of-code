unit uTask_2018_05;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FPolymer: String;
    function ReactAll(S: String): Integer;
    function FindBestReduce: Integer;
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
begin
  with Input do
    try
      FPolymer := Text.Trim;

      OK('Part 1: %d, Part 2: %d', [ ReactAll(FPolymer), FindBestReduce ]);
    finally
      Free;
    end;
end;

function TTask_AoC.FindBestReduce: Integer;
var
  C: AnsiChar;
  S: String;
  L: Integer;
begin
  Result := MaxInt;
  for C := 'a' to 'z' do
    begin
      S := FPolymer.Replace(String(C), '').Replace(String(UpCase(C)), '');
      L := ReactAll(S);
      if L < Result then
        Result := L;
    end;
end;

function TTask_AoC.ReactAll(S: String): Integer;
var
  I: Integer;

  function CanReact: Boolean;
  begin
    Result := False;

    if UpCase(S[I]) <> UpCase(S[I + 1]) then
      Exit(False);

    if (CharInSet(S[I], [ 'A'..'Z' ]) and CharInSet(S[I + 1], [ 'a'..'z' ])) or (CharInSet(S[I], [ 'a'..'z' ]) and CharInSet(S[I + 1], [ 'A'..'Z' ])) then
      Exit(True);
  end;

begin
  I := 1;

  while I < S.Length - 1 do
    begin
      if CanReact then
        begin
          S := S.Remove(I - 1, 2);
          I := 1;
        end
      else
        Inc(I);
    end;

  Result := S.Length;
end;

initialization
  GTask := TTask_AoC.Create(2018, 5, 'Alchemical Reduction');

finalization
  GTask.Free;

end.
