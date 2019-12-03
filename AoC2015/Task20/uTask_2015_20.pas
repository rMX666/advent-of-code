unit uTask_2015_20;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FPresents: Integer;
    function Part1: Integer;
    function Part2: Integer;
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
      FPresents := Text.Trim.ToInteger;
    finally
      Free;
    end;

  OK('Part 1: %d, Part 2: %d', [ Part1, Part2 ]);
end;

function TTask_AoC.Part1: Integer;
var
  I, J, L: Integer;
  Houses: TArray<Integer>;
begin
  L := FPresents div 10;
  Result := MaxInt;
  SetLength(Houses, L);

  for I := 1 to L do
    begin
      J := I;
      while J <= L do
        begin
          Inc(Houses[J], I * 10);

          if Houses[J] >= FPresents then
            if Result > J then
              Result := J;

          Inc(J, I);
        end;
    end;
end;

function TTask_AoC.Part2: Integer;
var
  I, J, L, Delivered: Integer;
  Houses: TArray<Integer>;
begin
  L := FPresents div 10;
  Result := MaxInt;
  SetLength(Houses, L);

  for I := 1 to L do
    begin
      J := I;
      Delivered := 50;
      while (J <= L) and (Delivered > 0) do
        begin
          Inc(Houses[J], I * 11);
          Inc(Houses[J]);

          if Houses[J] >= FPresents then
            if Result > J then
              Result := J;

          Inc(J, I);
          Dec(Delivered);
        end;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 20, 'Infinite Elves and Infinite Houses');

finalization
  GTask.Free;

end.
