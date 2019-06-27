unit uTask_2016_16;

interface

uses
  System.Classes, uTask;

type
  TTask_AoC = class (TTask)
  private const
    LENGTH_PART1 = 272;
    LENGTH_PART2 = 35651584;
  private
    FCurve: TBits;
    procedure LoadInitialState;
    function GetCurveCheckSum(const MaxSize: Integer): String;
  protected
    procedure DoRun; override;
  end;

  TBitsHelper = class helper for TBits
    function ToString: String;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TBitsHelper }

function TBitsHelper.ToString: String;
var
  I: Integer;
  B: TStringBuilder;
begin
  B := TStringBuilder.Create;
  try
    for I := 0 to Size - 1 do
      B.Append(Integer(Self.Bits[I]));
    Result := B.ToString;
  finally
    FreeAndNil(B);
  end;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadInitialState;

  try
    OK(Format('Part 1: %s, Part 2: %s', [ GetCurveChecksum(LENGTH_PART1), GetCurveChecksum(LENGTH_PART2) ]));
  finally
    FCurve.Free;
  end;
end;

function TTask_AoC.GetCurveCheckSum(const MaxSize: Integer): String;
var
  Count, I: Integer;
  Curve: TBits;
begin
  Curve := TBits.Create;

  try
    // Copy initial curve
    Curve.Size := FCurve.Size;
    for I := 0 to FCurve.Size - 1 do
      Curve[I] := FCurve[I];

    // Make a curve of required size
    while Curve.Size < MaxSize do
      begin
        Count := Curve.Size;
        Curve.Size := Count * 2 + 1;
        for I := 0 to Count - 1 do
          Curve[Count + I + 1] := not Curve[Count - I - 1];
      end;
    // Cut valuable part
    Curve.Size := MaxSize;

    // Calculate checksum
    while Curve.Size mod 2 = 0 do
      begin
        Count := Curve.Size div 2;
        for I := 0 to Count - 1 do
          Curve[I] := not (Curve[I * 2] xor Curve[I * 2 + 1]);
        Curve.Size := Count;
      end;
  finally
    Result := Curve.ToString;
    Curve.Free;
  end;
end;

procedure TTask_AoC.LoadInitialState;
var
  I: Integer;
  S: String;
begin
  FCurve := TBits.Create;
  with Input do
    try
      S := Text.Trim;
      for I := 1 to S.Length do
        FCurve.Bits[I - 1] := S[I] = '1';
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 16, 'Dragon Checksum');

finalization
  GTask.Free;

end.
