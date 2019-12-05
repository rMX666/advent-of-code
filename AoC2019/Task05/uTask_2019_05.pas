unit uTask_2019_05;

interface

uses
  uTask, IntCode, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    FInputID: Integer;
    FOutput: TList<Integer>;
    procedure LoadProgram;
    procedure OnInputHandler(const Sender: TIntCode; out Value: Integer);
    procedure OnOutputHandler(const Sender: TIntCode; const Value: Integer);
    function GetDiagnosticCode(const InputID: Integer): Integer;
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
  LoadProgram;
  FOutput := TList<Integer>.Create;
  try
    OK('Part 1: %d, Part 2: %d', [ GetDiagnosticCode(1), GetDiagnosticCode(5) ]);
  finally
    FOutput.Free;
    FInitialState.Free;
  end;
end;


function TTask_AoC.GetDiagnosticCode(const InputID: Integer): Integer;
var
  I: Integer;
begin
  FInputID := InputID;
  FOutput.Clear;

  with FInitialState.Clone do
    try
      Execute;
    finally
      Free;
    end;

  for I := 0 to FOutput.Count - 2 do
    if FOutput[I] <> 0 then
      raise Exception.CreateFmt('The output %d failed with %d', [ I, FOutput[I] ]);

  Result := FOutput[FOutput.Count - 1];
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TIntCode.LoadProgram(Text);
      FInitialState.OnInput := OnInputHandler;
      FInitialState.OnOutput := OnOutputHandler;
    finally
      Free;
    end;
end;

procedure TTask_AoC.OnInputHandler(const Sender: TIntCode; out Value: Integer);
begin
  Value := FInputID;
end;

procedure TTask_AoC.OnOutputHandler(const Sender: TIntCode; const Value: Integer);
begin
  FOutput.Add(Value);
end;

initialization
  GTask := TTask_AoC.Create(2019, 5, 'Sunny with a Chance of Asteroids');

finalization
  GTask.Free;

end.
