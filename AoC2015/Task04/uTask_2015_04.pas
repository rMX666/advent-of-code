unit uTask_2015_04;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    function MineAdventCoints(const Complexity: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, IdHashMessageDigest, idHash;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  Ok(Format('Part 1: %d, Part 2: %d', [ MineAdventCoints(5), MineAdventCoints(6) ]));
end;

function TTask_AoC.MineAdventCoints(const Complexity: Integer): Integer;
var
  Key, ComplexityStr: String;
  MD5: TIdHashMessageDigest5;
  I: Integer;
begin
  Result := 0;
  with Input do
    try
      Key := Text.Trim;
    finally
      Free;
    end;
  MD5 := TIdHashMessageDigest5.Create;

  ComplexityStr := '';
  for I := 1 to Complexity do
    ComplexityStr := ComplexityStr + '0';

  try
    while MD5.HashStringAsHex(Key + IntToStr(Result)).Substring(0, Complexity) <> ComplexityStr do
      Inc(Result);
  finally
    MD5.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 4, 'The Ideal Stocking Stuffer');

finalization
  GTask.Free;

end.
