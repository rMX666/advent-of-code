unit uTask_2017_12;

interface

uses
  System.Generics.Collections, uTask;

type
  TPrograms = TDictionary<Integer,TArray<Integer>>;
  TGroup = TList<Integer>;
  TGroups = TObjectDictionary<Integer,TGroup>;

  TTask_AoC = class (TTask)
  private
    FPrograms: TPrograms;
    FGroups: TGroups;
    procedure LoadPrograms;
    procedure SplitGroups(const StartWith: Integer);
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
  FPrograms := TPrograms.Create;
  FGroups := TGroups.Create([doOwnsValues]);
  try
    LoadPrograms;
    SplitGroups(0);

    OK('Part 1: %d, Part 2: %d', [ FGroups[0].Count, FGroups.Count ]);
  finally
    FPrograms.Free;
    FGroups.Free;
  end;
end;

procedure TTask_AoC.LoadPrograms;
var
  A, B: TArray<String>;
  Val: TArray<Integer>;
  I, J: Integer;
begin
  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          A := Strings[I].Split([' <-> ']);
          B := A[1].Split([', ']);
          SetLength(Val, Length(B));
          for J := 0 to Length(B) - 1 do
            Val[J] := B[J].ToInteger;
          FPrograms.Add(A[0].ToInteger, Val);
        end;
    finally
      Free;
    end;
end;

procedure TTask_AoC.SplitGroups(const StartWith: Integer);
var
  Group: TGroup;
  Key: Integer;

  procedure ProcessGroup(const Key: Integer);
  var
    Keys: TArray<Integer>;
    I: Integer;
  begin
    if not Group.Contains(Key) then
      Group.Add(Key);
    Keys := FPrograms[Key];
    FPrograms.Remove(Key);
    for I := 0 to Length(Keys) - 1 do
      if not Group.Contains(Keys[I]) then
        begin
          Group.Add(Keys[I]);
          ProcessGroup(Keys[I]);
        end;
  end;

begin
  Key := StartWith;

  while FPrograms.Count > 0 do
    begin
      Group := TGroup.Create;
      // Recursively walk through programs to get the exact list of connected programs
      ProcessGroup(Key);
      FGroups.Add(Key, Group);
      // Just get next key from iterator, as TDictionary cannot give you "any" record
      for Key in FPrograms.Keys do
        Break;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 12, 'Digital Plumber');

finalization
  GTask.Free;

end.
