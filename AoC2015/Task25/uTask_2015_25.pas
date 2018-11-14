unit uTask_2015_25;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
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
  A: TArray<String>;
  I, Col, Row, Target: Integer;
  Code: Int64;
begin
  Code := 20151125;

  with Input do
    try
      A := Text.Replace('.', '').Replace(',', '').Trim.Split([' ']);
      Col := A[18].ToInteger;
      Row := A[16].ToInteger;
    finally
      Free;
    end;

  Target := (Row + Col - 1) * (Row + Col) div 2 - Row;

  for I := 1 to Target do
    Code := (Code * 252533) mod 33554393;

  OK(Format('%d', [ Code ]));
end;

initialization
  GTask := TTask_AoC.Create(2015, 25, 'Let It Snow');

finalization
  GTask.Free;

end.
