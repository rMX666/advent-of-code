unit uTask_2015_19;

interface

uses
  uTask, System.Generics.Collections;

type
  TReplacement = TPair<String,String>;
  TReplacements = TDictionary<String,String>;
  TMolecules = TList<String>;

  TTask_AoC = class (TTask)
  private
    FMolecule: String;
    FReplacements: TReplacements;
    procedure Load;
    function CountDistinctMolecules: Integer;
    function ShuffleReplace: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uUtil;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.Load;

  procedure AddReplacement(const S: String);
  var
    A: TArray<String>;
  begin
    A := S.Split([' => ']);
    FReplacements.Add(A[1], A[0]);
  end;

var
  I: Integer;
begin
  FReplacements := TReplacements.Create;

  with Input do
    try
      I := 0;
      while Strings[I] <> '' do
        begin
          AddReplacement(Strings[I]);
          Inc(I);
        end;
      Inc(I);

      FMolecule := Strings[I];
    finally
      Free;
    end;
end;

function TTask_AoC.CountDistinctMolecules: Integer;

  function GetAllReplaces(const Source, Key, Value: String): TArray<String>;
  var
    Indexes: TArray<Integer>;
    Unique: TList<String>;
    I: Integer;
    NextValue: String;
  begin
    Unique := TList<String>.Create;
    try
      Indexes := KMP(Key, Source);
      for I := 0 to Length(Indexes) - 1 do
        begin
          NextValue := Source.Remove(Indexes[I] - 1, Key.Length).Insert(Indexes[I] - 1, Value);
          if not Unique.Contains(NextValue) then
            Unique.Add(NextValue);
        end;
    finally
      Result := Unique.ToArray;
      Unique.Free;
    end;
  end;

var
  Replacement: TReplacement;
  I: Integer;
  Next: TArray<String>;
  Possibilities: TMolecules;
begin
  Result := 0;

  Possibilities := TList<String>.Create;
  with Possibilities do
    try
      for Replacement in FReplacements do
        begin
          Next := GetAllReplaces(FMolecule, Replacement.Value, Replacement.Key);
          for I := 0 to Length(Next) - 1 do
            if not Contains(Next[I]) then
              Add(Next[I]);
        end;

      Result := Count;
    finally
      Free;
    end;
end;

function TTask_AoC.ShuffleReplace: Integer;

  function ReplaceAll(const Key, Value: String): Integer;
  var
    M: String;
  begin
    Result := 0;
    M := '';

    while M <> FMolecule do
      begin
        M := FMolecule;
        FMolecule := FMolecule.Replace(Key, Value, []);
        if M <> FMolecule then
          Inc(Result);
      end;
  end;

var
  I, L: Integer;
  Keys: TArray<String>;
  RestartCounter: Integer;
  InitialMolecule: String;
  DidReplace: Boolean;
begin
  Randomize;
  Keys := FReplacements.Keys.ToArray;
  L := Length(Keys);
  InitialMolecule := FMolecule;
  RestartCounter := 1000;
  Result := 0;

  while FMolecule <> 'e' do
    begin
      I := Random(L);
      Inc(Result, ReplaceAll(Keys[I], FReplacements[Keys[I]]));
      Dec(RestartCounter);

      if RestartCounter = 0 then
        begin
          FMolecule := InitialMolecule;
          RestartCounter := 1000;
          Result := 0;
        end;
    end;
end;

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Integer;
begin
  Load;

  try
    Part1 := CountDistinctMolecules;
    Part2 := ShuffleReplace;

    OK(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
  finally
    FReplacements.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 19, 'Medicine for Rudolph');

finalization
  GTask.Free;

end.
