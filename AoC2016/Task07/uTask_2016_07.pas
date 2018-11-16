unit uTask_2016_07;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FIP: TArray<String>;
    function TLSCount: Integer;
    function SSLCount: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Generics.Collections;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      FIP := ToStringArray;
    finally
      Free;
    end;

  OK(Format('Part 1: %d, Part 2: %d', [ TLSCount, SSLCount ]))
end;

function TTask_AoC.TLSCount: Integer;

  function SupportsTLS(const IP: String): Boolean;
  var
    InBrackets: Boolean;
    I: Integer;
  begin
    Result := False;

    InBrackets := False;
    for I := 1 to IP.Length - 3 do
      if IP[I] = '[' then
        InBrackets := True
      else if IP[I] = ']' then
        InBrackets := False
      else
        begin
          if (IP[I] = IP[I + 3]) and (IP[I + 1] = IP[I + 2]) and (IP[I] <> IP[I + 1]) then
            if InBrackets then
              Exit(False)
            else
              Result := True;
        end;
  end;

var
  I: Integer;
begin
  Result := 0;

  for I := 0 to Length(FIP) - 1 do
    if SupportsTLS(FIP[I]) then
      Inc(Result);
end;

function TTask_AoC.SSLCount: Integer;

  function SupportsSSL(const IP: String): Boolean;
  var
    InBrackets: Boolean;
    I: Integer;
    IPn, IPh: String;
  begin
    Result := False;

    InBrackets := False;
    IPn := '';
    IPh := '';
    for I := 1 to IP.Length do
      case IP[I] of
        '[':
          begin
            InBrackets := True;
            IPh := IPh + '*';
          end;
        ']':
          begin
            InBrackets := False;
            IPn := IPn + '#';
          end
        else
          if InBrackets then
            IPh := IPh + IP[I]
          else
            IPn := IPn + IP[I];
      end;

    for I := 1 to IPn.Length - 2 do
      if (IPn[I] <> IPn[I + 1]) and (IPn[I] = IPn[I + 2]) and IPh.Contains(IPn[I + 1] + IPn[I] + IPn[I + 1]) then
        Exit(True);
  end;

var
  I: Integer;
begin
  Result := 0;

  for I := 0 to Length(FIP) - 1 do
    if SupportsSSL(FIP[I]) then
      Inc(Result);
end;

initialization
  GTask := TTask_AoC.Create(2016, 7, 'Internet Protocol Version 7');

finalization
  GTask.Free;

end.
