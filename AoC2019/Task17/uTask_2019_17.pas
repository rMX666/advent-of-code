unit uTask_2019_17;

interface

uses
  uTask, IntCode, System.Classes, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    FMap: TStrings;
    procedure LoadProgram;
    function SumAlignmentParameters: Integer;
    function TracePath: String;
    function CountDust: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.CountDust: Integer;
{
  Base on the result of TracePath function I found the correct sequences manually
  Main: A,B,A,C,A,B,C,A,B,C
  A: R,12,R,4,R,10,R,12
  B: R,6,L,8,R,10
  C: L,8,R,4,R,4,R,6
}

  procedure OutputToString(const Robot: TIntCode);
  var
    I: Integer;
    S: String;
  begin
    S := '';
    for I := 0 to Robot.Output.Count - 1 do
      S := S + Char(Robot.Output[I]);
    OK(S);
  end;

  procedure InputSequence(const Seq: String; const Robot: TIntCode);
  var
    I: Integer;
  begin
    try
      if Robot.Execute = erWaitForInput then
        for I := 1 to Seq.Length do
          Robot.AddInput(Ord(Seq[I]))
      else
        raise Exception.Create('Execution error');
    finally
      OutputToString(Robot);
    end;
  end;

var
  Main, A, B, C: String;
  Robot: TIntCode;
begin
  Main := 'A,B,A,C,A,B,C,A,B,C'#10;
  A := 'R,12,R,4,R,10,R,12'#10;
  B := 'R,6,L,8,R,10'#10;
  C := 'L,8,R,4,R,4,R,6'#10;
  Robot := TIntCode.Create(FInitialState);
  Result := 0;
  with Robot do
    try
      Items[0] := 2;

      InputSequence(Main, Robot);
      InputSequence(A, Robot);
      InputSequence(B, Robot);
      InputSequence(C, Robot);
      InputSequence('n'#10, Robot);
      if Execute = erHalt then
        Result := Output.Last;
    finally
      Free;
    end;
end;

procedure TTask_AoC.DoRun;
begin
  LoadProgram;
  try
    OK('Part 1: %d, %s, Part 2: %d', [ SumAlignmentParameters, TracePath, CountDust ]);
  finally
    FInitialState.Free;
    FMap.Free;
  end;
end;

function TTask_AoC.SumAlignmentParameters: Integer;
var
  I, X, Y: Integer;
  S: String;
begin
  with TIntCode.Create(FInitialState) do
    try
      if Execute <> erHalt then
        raise Exception.Create('Execution error');

      for I := 0 to Output.Count - 1 do
        begin
          if Output[I] = 10 then
            S := S + '.';
          S := S + Chr(Output[I]);
        end;
    finally
      Free;
    end;

  FMap := TStringList.Create;
  with FMap do
    begin
      Text := S.Trim;
      Result := 0;
      for Y := 1 to Count - 2 do
        for X := 2 to Strings[Y].Length - 1 do
          if  CharInSet(Strings[Y][X],     ['^', '<', '>', 'v', '#'])
          and CharInSet(Strings[Y - 1][X], ['^', '<', '>', 'v', '#'])
          and CharInSet(Strings[Y + 1][X], ['^', '<', '>', 'v', '#'])
          and CharInSet(Strings[Y][X - 1], ['^', '<', '>', 'v', '#'])
          and CharInSet(Strings[Y][X + 1], ['^', '<', '>', 'v', '#']) then
            Inc(Result, (X - 1) * Y);

      // To get rid of "out of bounds" exception
      FMap.Insert(0, FMap[0].Replace('#', '.', [rfReplaceAll]));
      FMap.Add(FMap[0].Replace('#', '.', [rfReplaceAll]));
      for I := 0 to FMap.Count - 1 do
        FMap[I] := '.' + FMap[I] + '.';
    end;
end;

function TTask_AoC.TracePath: String;
var
  X, Y: Integer;
  D: Char;
  S: TList<String>;

  procedure FindRobot;
  var
    I, J: Integer;
  begin
    for I := 0 to FMap.Count - 1 do
      for J := 1 to FMap[I].Length do
        if CharInSet(FMap[I][J], ['^', '<', '>', 'v']) then
          begin
            X := J;
            Y := I;
            Exit;
          end;
  end;

  function Rotate: Boolean;
  begin
    Result := True;
    case D of
      '^': if      FMap[Y][X - 1] = '#' then begin D := '<'; S.Add('L'); end
           else if FMap[Y][X + 1] = '#' then begin D := '>'; S.Add('R'); end
           else Result := False;
      '>': if      FMap[Y - 1][X] = '#' then begin D := '^'; S.Add('L'); end
           else if FMap[Y + 1][X] = '#' then begin D := 'v'; S.Add('R'); end
           else Result := False;
      '<': if      FMap[Y + 1][X] = '#' then begin D := 'v'; S.Add('L'); end
           else if FMap[Y - 1][X] = '#' then begin D := '^'; S.Add('R'); end
           else Result := False;
      'v': if      FMap[Y][X + 1] = '#' then begin D := '>'; S.Add('L'); end
           else if FMap[Y][X - 1] = '#' then begin D := '<'; S.Add('R'); end
           else Result := False;
    end;
  end;

  function CanMove(const D: Char): Boolean;
  var
    NewX, NewY: Integer;
  begin
    NewX := X;
    NewY := Y;

    case D of
      '^': Dec(NewY);
      '>': Inc(NewX);
      '<': Dec(NewX);
      'v': Inc(NewY);
    end;

    Result := (NewY >= 0) and (NewY <  FMap.Count)
          and (NewX >  0) and (NewX <= FMap[NewY].Length)
          and CharInSet(FMap[NewY][NewX],  ['^', '<', '>', 'v', '#']);

    if Result then
      begin
        X := NewX;
        Y := NewY;
      end;
  end;

  function Move: Boolean;
  var
    Steps: Integer;
  begin
    Steps := 0;
    while CanMove(D) do
      Inc(Steps);
    S.Add(Steps.ToString);
    Result := Rotate;
  end;

begin
  FindRobot;
  D := FMap[Y][X];

  S := TList<String>.Create;
  try
    Rotate;
    while Move do;

    Result := String.Join(',', S.ToArray);
  finally
    S.Free;
  end;
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TIntCode.Create(Text);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 17, 'Set and Forget');

finalization
  GTask.Free;

end.
