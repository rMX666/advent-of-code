unit uTask_2020_14;

interface

uses
  uTask, System.Generics.Collections, uBitmaskProcessor;

type
  TTask_AoC = class (TTask)
  private
    FInstructions: TList<TInstruction>;
    procedure LoadInstructions;
    function GetMemSumAfterInitialization(const Part: Integer): Int64;
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
  try
    LoadInstructions;
    Ok('Part 1: %d, Part 2: %d', [ GetMemSumAfterInitialization(1), GetMemSumAfterInitialization(2) ]);
  finally
    FInstructions.Free;
  end;
end;

function TTask_AoC.GetMemSumAfterInitialization(const Part: Integer): Int64;
var
  I: Integer;
  Value: Int64;
  Processor: TBitmaskProcessor;
begin
  case Part of
    1: Processor := TBitmaskProcessor.Create;
    2: Processor := TBitmaskProcessorV2.Create;
  end;

  try
    for I := 0 to FInstructions.Count - 1 do
      Processor.ExecuteInstruction(FInstructions[I]);

    Result := 0;
    for Value in Processor.Values do
      Inc(Result, Value);
  finally
    Processor.Free;
  end;
end;

procedure TTask_AoC.LoadInstructions;
var
  I: Integer;
begin
  FInstructions := TList<TInstruction>.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FInstructions.Add(TInstruction.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 14, 'Docking Data');

finalization
  GTask.Free;

end.
