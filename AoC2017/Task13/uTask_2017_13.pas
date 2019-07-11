unit uTask_2017_13;

interface

uses
  System.Generics.Collections, uTask;

type
  TLayer = record
    Number: Integer;
    Depth: Integer;
    Severity: Integer;
    constructor Create(const S: String);
    function IsCaught(const Delay: Integer): Boolean;
  end;

  TFirewall = class (TList<TLayer>)
  private
    function IsSafe(const Delay: Integer): Boolean;
  public
    function TotalSeverity(const Delay: Integer): Integer;
    function TimeToGo: Integer;
  end;

  TTask_AoC = class (TTask)
  private
    FFirewall: TFirewall;
    procedure LoadFirewall;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TLayer }

constructor TLayer.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Split([': ']);
  Number := A[0].ToInteger;
  Depth := A[1].ToInteger;
  Severity := Number * Depth;
end;

function TLayer.IsCaught(const Delay: Integer): Boolean;
begin
  Result := (Delay + Number) mod (Depth * 2 - 2) = 0;
end;

{ TFirewall }

function TFirewall.IsSafe(const Delay: Integer): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Count - 1 do
    if Items[I].IsCaught(Delay) then
      Exit(False);
end;

function TFirewall.TimeToGo: Integer;
begin
  Result := 0;
  while not IsSafe(Result) do
    Inc(Result);
end;

function TFirewall.TotalSeverity(const Delay: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Items[I].IsCaught(Delay) then
      Inc(Result, Items[I].Severity);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  FFirewall := TFirewall.Create;
  try
    LoadFirewall;
    OK(Format('Part 1: %d, Part 2: %d', [ FFirewall.TotalSeverity(0), FFirewall.TimeToGo ]));
  finally
    FFirewall.Free;
  end;
end;

procedure TTask_AoC.LoadFirewall;
var
  I: Integer;
begin
  with Input do
    try
      for I := 0 to Count - 1 do
        FFirewall.Add(TLayer.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 13, 'Packet Scanners');

finalization
  GTask.Free;

end.
