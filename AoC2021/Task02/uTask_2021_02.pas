unit uTask_2021_02;

interface

uses
  uTask, System.Generics.Collections;

type
  TInstructionType = ( ttForward, ttDown, ttUp );

  TInstruction = record
    InstructionType: TInstructionType;
    Amount: Integer;
    constructor Create(const AType: TInstructionType; AAmount: Integer);
  end;

  TInstructions = TList<TInstruction>;

  TTask_AoC = class (TTask)
  private
    FInstructions: TInstructions;
    procedure LoadInstructions;
    function GetFinalPosition: Integer;
    function GetFinalPositionWithAim: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Types;

var
  GTask: TTask_AoC;

{ TInstruction }

constructor TInstruction.Create(const AType: TInstructionType; AAmount: Integer);
begin
  InstructionType := AType;
  Amount := AAmount;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadInstructions;
    OK('Part 1: %d, Part 2: %d', [ GetFinalPosition, GetFinalPositionWithAim ]);
  finally
    FInstructions.Free;
  end;
end;


function TTask_AoC.GetFinalPosition: Integer;
var
  Pos: TPoint;
  I: Integer;
begin
  Pos := TPoint.Zero;
  for I := 0 to FInstructions.Count - 1 do
    with FInstructions[I] do
      case InstructionType of
        ttForward: Inc(Pos.X, Amount);
        ttDown:    Inc(Pos.Y, Amount);
        ttUp:      Dec(Pos.Y, Amount);
      end;
  Result := Pos.X * Pos.Y;
end;

function TTask_AoC.GetFinalPositionWithAim: Integer;
var
  Pos: TPoint;
  I, Aim: Integer;
begin
  Pos := TPoint.Zero;
  Aim := 0;
  for I := 0 to FInstructions.Count - 1 do
    with FInstructions[I] do
      case InstructionType of
        ttForward:
          begin
            Inc(Pos.X, Amount);
            Inc(Pos.Y, Amount * Aim);
          end;
        ttDown:
          Inc(Aim, Amount);
        ttUp:
          Dec(Aim, Amount);
      end;
  Result := Pos.X * Pos.Y;
end;

procedure TTask_AoC.LoadInstructions;
var
  I: Integer;
  S: String;
begin
  FInstructions := TInstructions.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          S := Strings[I];
          if S.StartsWith('forward') then
            FInstructions.Add(TInstruction.Create(ttForward, S.Replace('forward ', '').ToInteger))
          else if S.StartsWith('down') then
            FInstructions.Add(TInstruction.Create(ttDown, S.Replace('down ', '').ToInteger))
          else if S.StartsWith('up') then
            FInstructions.Add(TInstruction.Create(ttUp, S.Replace('up ', '').ToInteger));
        end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2021, 02, 'Dive!');

finalization
  GTask.Free;

end.
