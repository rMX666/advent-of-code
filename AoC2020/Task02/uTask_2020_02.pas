unit uTask_2020_02;

interface

uses
  System.RegularExpressions, System.Generics.Collections, uTask;

type
  TPassword = record
  private
    FLow, FHigh: Integer;
    FChar: Char;
    FPassword: String;
  public
    constructor Create(const S: String);
    function IsValid(const Rule: Integer): Boolean;
  end;

  TTask_AoC = class (TTask)
  private
    FPasswords: TList<TPassword>;
    procedure LoadPasswords;
  protected
    procedure DoRun; override;
    function ValidAmount(const Part: Integer): Integer;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TPassword }

constructor TPassword.Create(const S: String);
const
  RE = '^([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)$';
begin
  with TRegEx.Match(S, RE) do
    begin
      FLow := String(Groups[1].Value).ToInteger;
      FHigh := String(Groups[2].Value).ToInteger;
      FChar := Groups[3].Value[1];
      FPassword := Groups[4].Value;
    end;
end;

function TPassword.IsValid(const Rule: Integer): Boolean;
begin
  Result := False;
  case Rule of
    1: Result := FPassword.CountChar(FChar) in [ FLow .. FHigh ];
       // Either both are False or both are True is *Invalid*
       // Need one True and one False at any place
    2: Result := (FPassword[FLow] = FChar) <> (FPassword[FHigh] = FChar);
  end;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadPasswords;
    OK('Part 1: %d, Part 2: %d', [ ValidAmount(1), ValidAmount(2) ]);
  finally
    FPasswords.Free;
  end;
end;

procedure TTask_AoC.LoadPasswords;
var
  I: Integer;
begin
  FPasswords := TList<TPassword>.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FPasswords.Add(TPassword.Create(Strings[I]));
    finally
      Free;
    end;
end;

function TTask_AoC.ValidAmount(const Part: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FPasswords.Count - 1 do
    if FPasswords[I].IsValid(Part) then
      Inc(Result);
end;

initialization
  GTask := TTask_AoC.Create(2020, 2, 'Password Philosophy');

finalization
  GTask.Free;

end.
