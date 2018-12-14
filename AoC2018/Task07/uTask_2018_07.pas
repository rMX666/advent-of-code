unit uTask_2018_07;

interface

uses
  System.Generics.Collections, uTask;

type
  TStep = TPair<Char,String>;
  TSteps = TDictionary<Char,String>;

  TTask_AoC = class (TTask)
  private
    FSteps: TSteps;
    procedure LoadSteps;
    function GetStepOrder: String;
    function GetAssemblyTime: Integer;
    function GetFirstStepName: Char;
    function GetNextSteps(const Done: String): String;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uUtil;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadSteps;

    OK(Format('Part 1: %s, Part 2: %d', [ GetStepOrder, GetAssemblyTime ]));
  finally
    FSteps.Free;
  end;
end;

function TTask_AoC.GetAssemblyTime: Integer;
type
  TWorker = record
    Task: Char;
    TimeLeft: Integer;
  end;
var
  NextTasks, Done: String;
  Workers: array [1..5] of TWorker;

  function TryAssignWorker(const Task: Char): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 1 to 5 do
      if Workers[I].TimeLeft = 0 then
        begin
          Workers[I].TimeLeft := 61 + Ord(Task) - Ord('A');
          Workers[I].Task := Task;
          Exit(True);
        end;
  end;

  function GetNextTasks: String;
  var
    I: Integer;
  begin
    Result := GetNextSteps(Done);

    for I := 1 to 5 do
      if (Workers[I].TimeLeft > 0) and Result.Contains(Workers[I].Task) then
        Result := Result.Replace(Workers[I].Task, '');
  end;

  procedure StepWorkers;
  var
    I: Integer;
  begin
    for I := 1 to 5 do
      if Workers[I].TimeLeft > 0 then
        begin
          Dec(Workers[I].TimeLeft);
          if Workers[I].TimeLeft = 0 then
            begin
              Done := Done + Workers[I].Task;
              NextTasks := GetNextTasks;
            end;
        end;
  end;

begin
  Result := 0;
  NextTasks := GetNextTasks;
  FillChar(Workers, SizeOf(Workers), 0);
  while Done.Length < 26 do
    begin
      while NextTasks.Length > 0 do
        if TryAssignWorker(NextTasks[1]) then
          NextTasks := NextTasks.Remove(0, 1)
        else
          Break;
      StepWorkers;
      Inc(Result);
    end;
end;

function TTask_AoC.GetFirstStepName: Char;
var
  X: TStep;
begin
  Result := #0;
  for X in FSteps do
    if X.Value.IsEmpty then
      Exit(X.Key);
end;

function TTask_AoC.GetNextSteps(const Done: String): String;
var
  X: TStep;
  I: Integer;
  CanDo: Boolean;
begin
  Result := '';

  for X in FSteps do
    if not Done.Contains(X.Key) then
      begin
        CanDo := True;
        for I := 1 to X.Value.Length do
          if not Done.Contains(X.Value[I]) then
            begin
              CanDo := False;
              Break;
            end;

        if CanDo then
          Result := Result + X.Key;
      end;
  SortString(Result);
end;

function TTask_AoC.GetStepOrder: String;

  function StepsLeft(const Done: String): Boolean;
  var
    Key: Char;
  begin
    Result := False;

    for Key in FSteps.Keys do
      if not Done.Contains(Key) then
        Exit(True);
  end;

var
  Current: Char;
begin
  Current := GetFirstStepName;
  Result := Current;

  while StepsLeft(Result) do
    begin
      Current := GetNextSteps(Result)[1];
      Result := Result + Current;
    end;
end;

procedure TTask_AoC.LoadSteps;

  procedure GetNameAndNext(const S: String; out Name, Next: Char);
  var
    A: TArray<String>;
  begin
    A := S.Split([' ']);
    Name := A[1][1];
    Next := A[7][1];
  end;

var
  I: Integer;
  Name, Next: Char;
begin
  FSteps := TSteps.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          GetNameAndNext(Strings[I], Name, Next);
          if FSteps.ContainsKey(Next) then
            FSteps[Next] := FSteps[Next] + Name
          else
            FSteps.Add(Next, Name);

          if not FSteps.ContainsKey(Name) then
            FSteps.Add(Name, '');
        end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 7, 'The Sum of Its Parts');

finalization
  GTask.Free;

end.
