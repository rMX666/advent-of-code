unit uTask_2015_16;

interface

uses
  uTask, System.Generics.Collections;

type
  TAuntProperties = TDictionary<String,Integer>;
  TAunts = TObjectList<TAuntProperties>;

  TTask_AoC = class (TTask)
  private
    FAunts: TAunts;
    procedure LoadAunts;
    function IsTheOne1(const A, B: TAuntProperties): Boolean;
    function IsTheOne2(const A, B: TAuntProperties): Boolean;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  I, Part1, Part2: Integer;
  Ethalon: TAuntProperties;
begin
  try
    LoadAunts;

    Ethalon := TAuntProperties.Create(10);
    Ethalon.Add('children', 3);
    Ethalon.Add('cats', 7);
    Ethalon.Add('samoyeds', 2);
    Ethalon.Add('pomeranians', 3);
    Ethalon.Add('akitas', 0);
    Ethalon.Add('vizslas', 0);
    Ethalon.Add('goldfish', 5);
    Ethalon.Add('trees', 3);
    Ethalon.Add('cars', 2);
    Ethalon.Add('perfumes', 1);

    for I := 0 to FAunts.Count - 1 do
      if IsTheOne1(Ethalon, FAunts[I]) then
        Break;
    Part1 := I + 1;

    for I := 0 to FAunts.Count - 1 do
      if IsTheOne2(Ethalon, FAunts[I]) then
        Break;
    Part2 := I + 1;

    OK(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
  finally
    Ethalon.Free;
    FAunts.Free;
  end;
end;

function TTask_AoC.IsTheOne1(const A, B: TAuntProperties): Boolean;
var
  Key: String;
begin
  Result := True;

  for Key in B.Keys do
    if not A.ContainsKey(Key) then
      Exit(False)
    else
      if A[Key] <> B[Key] then
        Exit(False);
end;

function TTask_AoC.IsTheOne2(const A, B: TAuntProperties): Boolean;

  function CheckKey(const Key: String): Boolean;
  begin
    if (Key = 'cats') or (key = 'trees') then
      Result := A[Key] < B[Key]
    else if (Key = 'pomeranians') or (Key = 'goldfish') then
      Result := A[Key] > B[Key]
    else
      Result := A[Key] = B[Key];
  end;

var
  Key: String;
begin
  Result := True;

  for Key in B.Keys do
    if not A.ContainsKey(Key) then
      Exit(False)
    else
      if not CheckKey(Key) then
        Exit(False);
end;

procedure TTask_AoC.LoadAunts;

  function ParseAuntProperties(const Index: Integer; const S: String): TAuntProperties;
  var
    A, B: TArray<String>;
    I: Integer;
  begin
    Result := TAuntProperties.Create;

    A := S.Replace('Sue ' + (Index + 1).ToString + ': ', '').Split([', ']);
    for I := 0 to Length(A) - 1 do
      begin
        B := A[I].Split([': ']);
        Result.Add(B[0], B[1].ToInteger);
      end;
  end;

var
  I: Integer;
begin
  FAunts := TAunts.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FAunts.Add(ParseAuntProperties(I, Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 16, 'Aunt Sue');

finalization
  GTask.Free;

end.
