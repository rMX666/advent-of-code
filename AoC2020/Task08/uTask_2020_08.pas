unit uTask_2020_08;

interface

uses
  System.Classes, uTask;

type
  TTask_AoC = class (TTask)
  private
    FInstructions: TStrings;
    function RunUntilLoop(var Finished: Boolean): Integer;
    function TryToFixProgram: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Generics.Collections;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  Finished: Boolean;
begin
  try
    FInstructions := Input;
    Ok('Part 1: %d, Part 2: %d', [ RunUntilLoop(Finished), TryToFixProgram ]);
  finally
    FInstructions.Free;
  end;
end;

function TTask_AoC.RunUntilLoop(var Finished: Boolean): Integer;
var
  I, V: Integer;
  Visited: TDictionary<Integer,Boolean>;
begin
  Visited := TDictionary<Integer,Boolean>.Create;

  Finished := False;

  try
    Result := 0;
    I := 0;
    while I < FInstructions.Count do
      begin
        if Visited.ContainsKey(I) then
          Exit;
        Visited.Add(I, True);

        V := FInstructions[I].Split([' '])[1].Replace('+', '').ToInteger;

        if FInstructions[I].StartsWith('nop') then
          Inc(I)
        else if FInstructions[I].StartsWith('acc') then
          begin
            Inc(Result, V);
            Inc(I);
          end
        else if FInstructions[I].StartsWith('jmp') then
          Inc(I, V);
      end;
  finally
    Visited.Free;
  end;

  Finished := True;
end;

function TTask_AoC.TryToFixProgram: Integer;

  procedure SwapInstruction(const I: Integer);
  begin
    if FInstructions[I].StartsWith('nop') then
      FInstructions[I] := FInstructions[I].Replace('nop', 'jmp')
    else if FInstructions[I].StartsWith('jmp') then
      FInstructions[I] := FInstructions[I].Replace('jmp', 'nop');
  end;

  function TryToRun(const I: Integer; var Acc: Integer): Boolean;
  begin
    SwapInstruction(I);
    Acc := RunUntilLoop(Result);
    SwapInstruction(I);
  end;

var
  I: Integer;
begin
  for I := 0 to FInstructions.Count - 1 do
    if not FInstructions[I].StartsWith('acc') then
      if TryToRun(I, Result) then
        Exit;
end;

initialization
  GTask := TTask_AoC.Create(2020, 8, 'Handheld Halting');

finalization
  GTask.Free;

end.
