unit uTask_2016_08;

interface

uses
  System.Generics.Collections, uTask;

const
  DISPLAY_WIDTH = 50;
  DISPLAY_HEIGHT = 6;

type
  TDisplay = array [1..DISPLAY_WIDTH] of array [1..DISPLAY_HEIGHT] of Boolean;

  TCommandType = ( ctRect, ctRotateRow, ctRotateColumn );
  TCommand = record
    CommandType: TCommandType;
    P1, P2: Integer;
    {
      ctRect:
        P1 - x, P2 - y
      ctRotateRow
        P1 - row number, P2 - shift
      ctRotateColumn
        P1 - column number, P2 - shift
    }
    constructor Create(const S: String);
  end;

  TCommands = TList<TCommand>;

  TTask_AoC = class (TTask)
  private
    FCommands: TCommands;
    FDisplay: TDisplay;
    procedure LoadCommands;
    function ProcessCommands: Integer;
    procedure DrawDisplay;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uForm_2016_08;

var
  GTask: TTask_AoC;

{ TCommand }

constructor TCommand.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Replace('x=', '').Replace('y=', '').Split([' ', 'x']);
  if A[0] = 'rect' then
    begin
      CommandType := ctRect;
      P1 := A[1].ToInteger;
      P2 := A[2].ToInteger;
    end
  else if A[1] = 'row' then
    begin
      CommandType := ctRotateRow;
      P1 := A[2].ToInteger;
      P2 := A[4].ToInteger;
    end
  else
    begin
      CommandType := ctRotateColumn;
      P1 := A[2].ToInteger;
      P2 := A[4].ToInteger;
    end;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadCommands;
  fMain_2016_08 := TfMain_2016_08.Create(nil);
  FillChar(FDisplay, SizeOf(FDisplay), 0);

  try
    fMain_2016_08.Show;

    OK('Part 1: %d', [ ProcessCommands ]);
  finally
    FCommands.Free;
  end;
end;

function TTask_AoC.ProcessCommands: Integer;
var
  I, J, K: Integer;
  Row: array [1..DISPLAY_WIDTH] of Boolean;
  Column: array [1..DISPLAY_HEIGHT] of Boolean;
begin
  for I := 0 to FCommands.Count - 1 do
    begin
      with FCommands[I] do
        case CommandType of
          ctRect:
            for J := 1 to P1 do
              for K := 1 to P2 do
                FDisplay[J, K] := True;
          ctRotateRow:
            begin
              for J := 1 to DISPLAY_WIDTH do
                Row[J] := FDisplay[J, P1 + 1];
              for J := 1 to DISPLAY_WIDTH do
                FDisplay[J, P1 + 1] := Row[(DISPLAY_WIDTH + J - 1 - P2) mod DISPLAY_WIDTH + 1];
            end;
          ctRotateColumn:
            begin
              for J := 1 to DISPLAY_HEIGHT do
                Column[J] := FDisplay[P1 + 1, J];
              for J := 1 to DISPLAY_HEIGHT do
                FDisplay[P1 + 1, J] := Column[(DISPLAY_HEIGHT + J - 1 - P2) mod DISPLAY_HEIGHT + 1];
            end;
        end;
      DrawDisplay;
    end;

  Result := 0;
  for I := 1 to DISPLAY_WIDTH do
    for J := 1 to DISPLAY_HEIGHT do
      if FDisplay[I, J] then
        Inc(Result);
end;

procedure TTask_AoC.DrawDisplay;
begin
  fMain_2016_08.DrawDisplay(FDisplay);
end;

procedure TTask_AoC.LoadCommands;
var
  I: Integer;
begin
  with Input do
    try
      FCommands := TCommands.Create;
      for I := 0 to Count - 1 do
        FCommands.Add(TCommand.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 8, 'Two-Factor Authentication');

finalization
  GTask.Free;

end.
