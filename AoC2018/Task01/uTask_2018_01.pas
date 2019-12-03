unit uTask_2018_01;

interface

uses
  System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FChanges: TList<Integer>;
    procedure LoadChanges;
    function GetResultingFreq: Integer;
    function GetFirstTwice: Integer;
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
  try
    LoadChanges;
    OK('Part 1: %d, Part 2: %d', [ GetResultingFreq, GetFirstTwice ]);
  finally
    FChanges.Free;
  end;
end;

function TTask_AoC.GetFirstTwice: Integer;
var
  I: Integer;
  Freqs: TList<Integer>;
begin
  Freqs := TList<Integer>.Create;

  try
    Result := 0;
    I := 0;
    Freqs.Add(Result);
    while True do
      begin
        Inc(Result, FChanges[I]);
        if Freqs.Contains(Result) then
          Exit;
        Freqs.Add(Result);
        I := (I + 1) mod FChanges.Count;
      end;
  finally
    Freqs.Free;
  end;
end;

function TTask_AoC.GetResultingFreq: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FChanges.Count - 1 do
    Inc(Result, FChanges[I]);
end;

procedure TTask_AoC.LoadChanges;
var
  I: Integer;
begin
  FChanges := TList<Integer>.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FChanges.Add(Strings[I].ToInteger);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 1, 'Chronal Calibration');

finalization
  GTask.Free;

end.
