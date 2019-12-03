unit uTask_2016_05;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FKey: String;
    function CinemaDecrypt(const IsHardMode: Boolean): String;
    procedure PasswordChanged(const IsHardMode: Boolean; const S: String);
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, IdHashMessageDigest, idHash, uForm_2016_05;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.CinemaDecrypt(const IsHardMode: Boolean): String;
var
  MD5: TIdHashMessageDigest5;
  I, Pos: Integer;
  Hash: String;
begin
  Result := String.Create('*', 8);

  MD5 := TIdHashMessageDigest5.Create;
  try
    I := 0;
    while Result.Contains('*') do
      begin
        Hash := MD5.HashStringAsHex(FKey + I.ToString);

        if Hash.StartsWith('00000') then
          case IsHardMode of
            True:
              if CharInSet(Hash[6], [ '0'..'7' ]) then
                begin
                  Pos := String(Hash[6]).ToInteger + 1;
                  if Result[Pos] = '*' then
                    begin
                      Result[Pos] := Hash[7];
                      PasswordChanged(IsHardMode, Result);
                    end;
                end;
            False:
              begin
                Result[Result.IndexOf('*') + 1] := Hash[6];
                PasswordChanged(IsHardMode, Result);
              end;
          end;

        Inc(I);
      end;
  finally
    MD5.Free;
  end;

  Result := Result.ToLower;
end;

procedure TTask_AoC.DoRun;
var
  Part1, Part2: String;
begin
  with Input do
    try
      FKey := Text.Trim;
    finally
      Free;
    end;

  fMain_2016_05 := TfMain_2016_05.Create(nil);
  fMain_2016_05.Show;
  Part1 := CinemaDecrypt(False);
  Part2 := CinemaDecrypt(True);

  OK('Part 1: %s, Part 2: %s', [ Part1, Part2 ]);
end;

procedure TTask_AoC.PasswordChanged(const IsHardMode: Boolean; const S: String);
begin
  fMain_2016_05.PasswordChanged(IsHardMode, S);
end;

initialization
  GTask := TTask_AoC.Create(2016, 5, 'How About a Nice Game of Chess?');

finalization
  GTask.Free;

end.
