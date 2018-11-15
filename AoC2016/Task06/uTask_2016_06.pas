unit uTask_2016_06;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FLines: TArray<String>;
    function GetMessage(const ModifiedCode: Boolean): String;
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
  Part1, Part2: String;
begin
  with Input do
    try
      FLines := ToStringArray;
    finally
      Free;
    end;

  Part1 := GetMessage(False);
  Part2 := GetMessage(True);

  OK(Format('Part 1: %s, Part2: %s', [ Part1, Part2 ]));
end;

function TTask_AoC.GetMessage(const ModifiedCode: Boolean): String;
var
  Counts: array ['a'..'z'] of Integer;
  I, J, BestV: Integer;
  C, BestC: Char;
begin
  Result := String.Create('-', FLines[0].Length);

  for I := 1 to Result.Length do
    begin
      FillChar(Counts, SizeOf(Counts), 0);
      for J := 0 to Length(FLines) - 1 do
        Inc(Counts[FLines[J][I]]);

      case ModifiedCode of
        True:
          begin
            BestV := MaxInt;
            for C := 'a' to 'z' do
              if BestV > Counts[C] then
                begin
                  BestV := Counts[C];
                  BestC := C;
                end;
          end;
        False:
          begin
            BestV := 0;
            for C := 'a' to 'z' do
              if BestV < Counts[C] then
                begin
                  BestV := Counts[C];
                  BestC := C;
                end;
          end;
      end;

      Result[I] := BestC;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 6, 'Signals and Noise');

finalization
  GTask.Free;

end.
