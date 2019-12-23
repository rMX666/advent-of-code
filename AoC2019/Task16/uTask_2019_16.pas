unit uTask_2019_16;

interface

uses
  uTask;

type
  TFTTList = packed array of Byte;

  TTask_AoC = class (TTask)
  private
    FList: String;
    procedure LoadList;
    function PrepareList(const Iterations: Integer): TFTTList;
    function ToCode(const S: TFTTList): String;
    function FFT: String;
    function FastFFT: String;
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
  LoadList;
  OK('Part 1: %s, Part 2: %s', [ FFT, FastFFT ]);
end;

procedure TTask_AoC.LoadList;
begin
  with Input do
    try
      FList := Text.Trim;
    finally
      Free;
    end;
end;

function TTask_AoC.PrepareList(const Iterations: Integer): TFTTList;
var
  I: Integer;
begin
  SetLength(Result, FList.Length * Iterations);
  for I := 0 to Length(Result) - 1 do
    Result[I] := FList.Substring(I mod FList.Length, 1).ToInteger
end;

function TTask_AoC.ToCode(const S: TFTTList): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to 7 do
    Result := Result + S[I].ToString;
end;

function TTask_AoC.FastFFT: String;
var
  S: TFTTList;
  Phase, I, RunningSum: Integer;
begin
  S := Copy(PrepareList(10000), FList.Substring(0, 7).ToInteger);
  for Phase := 1 to 100 do
    begin
      RunningSum := 0;
      I := Length(S) - 1;
      while I >= 0 do
        begin
          Inc(RunningSum, S[I]);
          S[I] := RunningSum mod 10;
          Dec(I);
        end;
    end;
  Result := ToCode(S);
end;

function TTask_AoC.FFT: String;
var
  Phase: Integer;
  Index, I, Base, Sign, Total, L: Integer;
  S: TFTTList;
begin
  S := PrepareList(1);
  L := Length(S) - 1;

  for Phase := 1 to 100 do
    for Index := 0 to L do
      begin
        Base := Index;
        Total := 0;
        Sign := 1;
        while Base <= L do
          begin
            for I := Base to Min(Base + Index, L) do
              Inc(Total, S[I] * Sign);
            Inc(Base, (Index + 1) * 2);
            Sign := -Sign;
          end;
        S[Index] := Abs(Total) mod 10;
      end;

  Result := ToCode(S);
end;

initialization
  GTask := TTask_AoC.Create(2019, 16, 'Flawed Frequency Transmission');

finalization
  GTask.Free;

end.
