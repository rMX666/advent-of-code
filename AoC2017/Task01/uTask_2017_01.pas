unit uTask_2017_01;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FCaptcha: String;
    function Solve(const Part: Integer): Integer;
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
  with Input do
    try
      FCaptcha := Text.Trim;
    finally
      Free;
    end;

  OK(Format('Part 1: %d, Part 2: %d', [ Solve(1), Solve(2) ]));
end;


function TTask_AoC.Solve(const Part: Integer): Integer;
var
  I, Next: Integer;
begin
  Result := 0;

  Next := 0;
  for I := 1 to FCaptcha.Length do
    begin
      case Part of
        1: Next := I mod FCaptcha.Length + 1;
        2:
          begin
            Next := I + FCaptcha.Length div 2;
            if Next > FCaptcha.Length then
              Dec(Next, FCaptcha.Length);
          end;
      end;

      if FCaptcha[I] = FCaptcha[Next] then
        Inc(Result, String(FCaptcha[I]).ToInteger);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 1, 'Inverse Captcha');

finalization
  GTask.Free;

end.
