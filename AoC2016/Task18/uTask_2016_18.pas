unit uTask_2016_18;

interface

uses
  Classes, uTask;

type
  TTask_AoC = class (TTask)
  private
    FRow: TBits;
    procedure LoadFirstRow;
    function CountFree(Rows: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

  TBitsHelper = class helper for TBits
  public
    procedure Assign(const Other: TBits);
    function FalseCount: Integer;
    function ToString: String;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TBitsHelper }

procedure TBitsHelper.Assign(const Other: TBits);
var
  I: Integer;
begin
  Self.Size := 0;
  Self.Size := Other.Size;
  for I := 0 to Self.Size - 1 do
    Self[I] := Other[I];
end;

function TBitsHelper.FalseCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Size - 1 do
    if not Bits[I] then
      Inc(Result);
end;

function TBitsHelper.ToString: String;
var
  I: Integer;
begin
  with TStringBuilder.Create do
    try
      for I := 0 to Size - 1 do
        if Bits[I] then
          Append('^')
        else
          Append('.');

      Result := ToString;
    finally
      Free;
    end;
end;

{ TTask_AoC }

function TTask_AoC.CountFree(Rows: Integer): Integer;
var
  Row: TBits;
  I: Integer;
begin
  LoadFirstRow;
  Result := 0;
  Row := TBits.Create;
  Row.ToString;

  try
    Row.Size := FRow.Size;
    Row.Assign(FRow);
    while Rows > 0 do
      begin
        Inc(Result, FRow.FalseCount);
        Row[0]            := FRow[1];
        Row[Row.Size - 1] := FRow[Row.Size - 2];
        for I := 1 to FRow.Size - 2 do
          Row[I] := FRow[I - 1] xor FRow[I + 1];
        FRow.Assign(Row);
        Dec(Rows);
      end;
  finally
    Row.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    FRow := TBits.Create;
    OK('Part 1: %d, Part 2: %d', [ CountFree(40), CountFree(400000) ]);
  finally
    FRow.Free;
  end;
end;

procedure TTask_AoC.LoadFirstRow;
var
  I: Integer;
  S: String;
begin
  with Input do
    try
      S := Text.Trim;
      FRow.Size := 0;
      FRow.Size := S.Length;
      for I := 1 to S.Length do
        FRow[I - 1] := S[I] = '^';
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 18, 'Like a Rogue');

finalization
  GTask.Free;

end.
