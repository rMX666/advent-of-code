unit uTask_2020_06;

interface

uses
  System.Classes, System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FGroups: TObjectList<TStrings>;
    procedure LoadGroups;
    function SumOfGroupsAny: Integer;
    function SumOfGroupsAll: Integer;
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
    LoadGroups;
    Ok('Part 1: %d, Part 2: %d', [ SumOfGroupsAny, SumOfGroupsAll ]);
  finally
    FGroups.Free;
  end;
end;


procedure TTask_AoC.LoadGroups;
var
  I: Integer;
  Group: TStrings;
begin
  FGroups := TObjectList<TStrings>.Create(True);
  with Input do
    try
      Group := TStringList.Create;
      for I := 0 to Count - 1 do
        if Strings[I] = '' then
          begin
            if Group.Count > 0 then
              FGroups.Add(Group);
            Group := TStringList.Create;
          end
        else
          Group.Add(Strings[I]);
      FGroups.Add(Group);
    finally
      Free;
    end;
end;

function TTask_AoC.SumOfGroupsAll: Integer;
var
  I, J, K: Integer;
  S, T: String;
begin
  Result := 0;
  for I := 0 to FGroups.Count - 1 do
    begin
      S := FGroups[I].Strings[0];
      for J := 1 to FGroups[I].Count - 1 do
        begin
          T := '';
          for K := 1 to FGroups[I].Strings[J].Length do
            if S.IndexOf(FGroups[I].Strings[J][K]) >= 0 then
              T := T + FGroups[I].Strings[J][K];
          S := T;
          if S.Length = 0 then
            Break;
        end;
      Inc(Result, S.Length);
    end;
end;

function TTask_AoC.SumOfGroupsAny: Integer;
var
  I, J, K: Integer;
  S: String;
begin
  Result := 0;
  for I := 0 to FGroups.Count - 1 do
    begin
      S := FGroups[I].Strings[0];
      for J := 1 to FGroups[I].Count - 1 do
        for K := 1 to FGroups[I].Strings[J].Length do
          if S.IndexOf(FGroups[I].Strings[J][K]) = -1 then
            S := S + FGroups[I].Strings[J][K];
      Inc(Result, S.Length);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 6, 'Custom Customs');

finalization
  GTask.Free;

end.
