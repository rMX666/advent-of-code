unit uTask_2016_19;

interface

uses
  uTask;

type
  PElf = ^TElf;
  TElf = record
  public
    class var ElfCount: Integer;
  public
    Number: Integer;
    Presents: Integer;
    Next, Prev: PElf;
    procedure Remove;
    function StealFrom(const Elf: PElf): PElf;
    function NextN(const N: Integer): PElf;
  strict private
    constructor Create(const ANumber: Integer; const ANext, APrev: PElf);
  public
    class function Pointer(const ANumber: Integer; const ANext, APrev: PElf): PElf; static;
  end;

  TTask_AoC = class (TTask)
  private
    FElfCount: Integer;
    FRootElf: PElf;
    procedure InitElvs;
    function WinnerID(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TElf }

constructor TElf.Create(const ANumber: Integer; const ANext, APrev: PElf);
begin
  Number := ANumber;
  Next := ANext;
  Prev := APrev;
  Presents := 1;
  if ANumber = 1 then
    ElfCount := 1
  else
    Inc(ElfCount);
end;

function TElf.NextN(const N: Integer): PElf;
var
  I: Integer;
begin
  Result := @Self;
  for I := 1 to N do
    Result := Result.Next;
end;

class function TElf.Pointer(const ANumber: Integer; const ANext, APrev: PElf): PElf;
begin
  New(Result);
  Result^ := TElf.Create(ANumber, ANext, APrev);
end;

procedure TElf.Remove;
begin
  if Assigned(Next) then
    Next.Prev := Prev;
  if Assigned(Prev) then
    Prev.Next := Next;
  Next := nil;
  Prev := nil;
  Dispose(@Self);
  Dec(TElf.ElfCount);
end;

function TElf.StealFrom(const Elf: PElf): PElf;
begin
  Inc(Presents, Elf.Presents);
  Elf.Remove;
  Result := Next;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      FElfCount := Text.Trim.ToInteger;
    finally
      Free;
    end;

  OK(Format('Part 1: %d, Part 2: %d', [ WinnerID(1), WinnerID(2) ]));
end;

procedure TTask_AoC.InitElvs;
var
  I: Integer;
  Current, Next: PElf;
begin
  FRootElf := TElf.Pointer(1, nil, nil);
  Current := FRootElf;
  for I := 2 to FElfCount do
    begin
      Next := TElf.Pointer(I, nil, Current);
      Current.Next := Next;
      Current := Next;
    end;
  FRootElf.Prev := Current;
  Current.Next := FRootElf;
end;

function TTask_AoC.WinnerID(const Part: Integer): Integer;
var
  Opposite: PElf;
begin
  InitElvs;

  try
    Opposite := nil;
    if Part = 2 then
      Opposite := FRootElf.NextN(TElf.ElfCount div 2);

    while TElf.ElfCount > 1 do
      case Part of
        1: FRootElf := FRootElf.StealFrom(FRootElf.Next);
        2:
          begin
            // Move cursor to the next opposite
            Opposite := Opposite.Next;
            // Steal from the opposite and move current cursor to the next elf
            FRootElf := FRootElf.StealFrom(Opposite.Prev);
            // If Opposite count is even, move cursor to the next opposite
            if TElf.ElfCount mod 2 = 0 then
              Opposite := Opposite.Next;
          end;
      end;

    Result := FRootElf.Number;
  finally
    while TElf.ElfCount > 0 do
      FRootElf.Next.Remove;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 19, 'An Elephant Named Joseph');

finalization
  GTask.Free;

end.
