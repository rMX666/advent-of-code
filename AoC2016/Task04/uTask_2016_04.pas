unit uTask_2016_04;

interface

uses
  System.Generics.Collections, System.Generics.Defaults, uTask;

type
  TCounts = array ['a'..'z'] of Integer;

  TCharComparer = class(TCustomComparer<Char>)
  private
    FCounts: TCounts;
  public
    constructor Create(const Counts: TCounts);
    function Compare(const Left, Right: Char): Integer; override;
    function Equals(const Left, Right: Char): Boolean; reintroduce; overload; override;
    function GetHashCode(const Value: Char): Integer; reintroduce; overload; override;
  end;

  TTask_AoC = class (TTask)
  private
    FRooms: TList<String>;
    procedure LoadRooms;
    function GetRoomName(const Room: String): String;
    function GetRoomID(const Room: String): String;
    function GetRoomHash(const Room: String): String;
    function CalcHash(const S: String): String;
    function IsDecoy(const Room: String): Boolean;
    function CountRealRooms: Integer;
    function FindNorthPoleID: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TCharComparer }

function TCharComparer.Compare(const Left, Right: Char): Integer;
begin
  Result := FCounts[Right] - FCounts[Left];
  if Result = 0 then
    Result := Ord(Left) - Ord(Right);
end;

constructor TCharComparer.Create(const Counts: TCounts);
begin
  FCounts := Counts;
end;

function TCharComparer.Equals(const Left, Right: Char): Boolean;
begin
  Result := Left = Right;
end;

function TCharComparer.GetHashCode(const Value: Char): Integer;
begin
  Result := Ord(Value);
end;

{ TTask_AoC }

function TTask_AoC.CountRealRooms: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FRooms.Count - 1 do
    if not IsDecoy(FRooms[I]) then
      Inc(Result, GetRoomID(FRooms[I]).ToInteger);
end;

function TTask_AoC.FindNorthPoleID: Integer;

  function RotChar(const C: Char; const Rounds: Integer): Char;
  begin
    Result := Chr((Rounds + Ord(C) - Ord('a')) mod 26 + Ord('a'));
  end;

  function CesarDecrypt(const S: String; const Rounds: Integer): String;
  var
    I: Integer;
  begin
    Result := S;
    for I := 1 to S.Length do
      if CharInSet(S[I], [ 'a'..'z' ]) then
        Result[I] := RotChar(S[I], Rounds);
  end;

var
  Name: String;
  I, ID: Integer;
begin
  for I := 0 to FRooms.Count - 1 do
    if not IsDecoy(FRooms[I]) then
      begin
        Name := GetRoomName(FRooms[I]);
        ID := GetRoomID(FRooms[I]).ToInteger;

        if CesarDecrypt(Name, ID).Contains('northpole-object') then
          Exit(ID);
      end;

  Result := -1;
end;

function TTask_AoC.GetRoomHash(const Room: String): String;
begin
  Result := Room.Substring(Room.IndexOf('[') + 1, 5);
end;

function TTask_AoC.GetRoomID(const Room: String): String;
var
  I: Integer;
begin
  Result := '';
  I := Room.IndexOf('[');
  while CharInSet(Room[I], [ '0'..'9' ]) do
    begin
      Result := Room[I] + Result;
      Dec(I);
    end;
end;

function TTask_AoC.GetRoomName(const Room: String): String;
var
  I: Integer;
begin
  I := 1;
  while (I <= Room.Length) and not CharInSet(Room[I], [ '0'..'9' ]) do
    Inc(I);
  Result := Room.Substring(0, I - 2);
end;

function TTask_AoC.CalcHash(const S: String): String;
var
  Counts: TCounts;
  I: Integer;
  ResultC: TArray<Char>;
  CharComparer: TCharComparer;
begin
  Result := 'abcdefghijklmnopqrstuvwxyz';
  FillChar(Counts, SizeOf(Counts), 0);
  for I := 0 to S.Length do
    Inc(Counts[S[I]]);

  ResultC := Result.ToCharArray;
  CharComparer := TCharComparer.Create(Counts);
  try
    TArray.Sort<Char>(ResultC, CharComparer);
  finally
    CharComparer.Free;
  end;
  Result := String.Create(ResultC).Substring(0, 5);
end;

function TTask_AoC.IsDecoy(const Room: String): Boolean;
var
  Name, Hash: String;
begin
  Name := GetRoomName(Room);
  Hash := GetRoomHash(Room);

  Result := CalcHash(Name) <> Hash;
end;

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Integer;
begin
  LoadRooms;
  try
    Part1 := CountRealRooms;
    Part2 := FindNorthPoleID;
  finally
    FRooms.Free;
  end;

  OK(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
end;

procedure TTask_AoC.LoadRooms;
begin
  FRooms := TList<String>.Create;

  with Input do
    try
      FRooms.AddRange(ToStringArray);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 4, 'Security Through Obscurity');

finalization
  GTask.Free;

end.
