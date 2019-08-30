unit uTask_2016_14;

interface

uses
  System.Generics.Collections, uTask;

type
  TPadKey = class
    Key: String;
    Num: Integer;
    Counter: Integer;
    constructor Create(const AKey: String; ANum: Integer);
    function Step: Boolean;
    function Clone: TPadKey;
  end;

  TTask_AoC = class (TTask)
  private
    FSalt: String;
    function GetHash(const S: String; const Strength: Integer): String;
    function FindThreeInARow(const Hash: String): String;
    function GetNthPass(const N: Integer; const Strength: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Generics.Defaults, System.Math, IdHashMessageDigest, idHash, System.Hash;

var
  GTask: TTask_AoC;

type
  TPadKeyComparer = class(TCustomComparer<TPadKey>)
  public
    function Compare(const Left, Right: TPadKey): Integer; override;
    function Equals(const Left, Right: TPadKey): Boolean; override;
    function GetHashCode(const Value: TPadKey): Integer; override;
  end;

{ TPadKeyComparer }

function TPadKeyComparer.Compare(const Left, Right: TPadKey): Integer;
begin
  Result := Left.Num - Right.Num;
end;

function TPadKeyComparer.Equals(const Left, Right: TPadKey): Boolean;
begin
  Result := Left.Num = Right.Num;
end;

function TPadKeyComparer.GetHashCode(const Value: TPadKey): Integer;
begin
  Result := THashBobJenkins.GetHashValue(Value, SizeOf(TPadKey), 0);
end;

{ TPadKey }

function TPadKey.Clone: TPadKey;
begin
  Result := TPadKey.Create(Key, Num);
  Result.Counter := Counter;
end;

constructor TPadKey.Create(const AKey: String; ANum: Integer);
begin
  Key := AKey;
  Num := ANum;
  Counter := 0;
end;

function TPadKey.Step: Boolean;
begin
  Inc(Counter);
  Result := Counter <= 1000;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      FSalt := Text.Trim;
    finally
      Free;
    end;

  OK(Format('Part 1: %d, Part 2: %d', [ GetNthPass(64, 0), GetNthPass(64, 2016) ]));
end;

function TTask_AoC.FindThreeInARow(const Hash: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Hash.Length - 2 do
    if (Hash[I] = Hash[I + 1]) and (Hash[I + 1] = Hash[I + 2]) then
      Exit(String.Create(Hash[I], 5));
end;

function TTask_AoC.GetHash(const S: String; const Strength: Integer): String;
var
  MD5: TIdHashMessageDigest5;
  I: Integer;
begin
  MD5 := TIdHashMessageDigest5.Create;
  try
    Result := MD5.HashStringAsHex(S).ToLower;
    for I := 1 to Strength do
      Result := MD5.HashStringAsHex(Result).ToLower;
  finally
    FreeAndNil(MD5);
  end;
end;

function TTask_AoC.GetNthPass(const N: Integer; const Strength: Integer): Integer;
var
  Candidates, PadKeys: TObjectList<TPadKey>;

  procedure CheckKeys(const Hash: String);
  var
    I: Integer;
    Key: TPadKey;
  begin
    I := 0;
    while I < Candidates.Count do
      begin
        Key := Candidates[I];
        if Hash.Contains(Key.Key) then
          begin
            PadKeys.Add(Key.Clone);
            Candidates.Delete(I);
          end
        else
          if not Key.Step then
            Candidates.Delete(I)
          else
            Inc(I);
      end;
  end;

var
  I: Integer;
  Hash, Key: String;
  Comparer: TPadKeyComparer;
begin
  I := 0;
  Candidates := TObjectList<TPadKey>.Create;
  Comparer := TPadKeyComparer.Create;
  PadKeys := TObjectList<TPadKey>.Create(Comparer);
  try
    while PadKeys.Count < N do
      begin
        Hash := GetHash(FSalt + I.ToString, Strength);

        CheckKeys(Hash);

        Key := FindThreeInARow(Hash);
        if Key <> '' then
          Candidates.Add(TPadKey.Create(Key, I));

        Inc(I);
      end;
    PadKeys.Sort;
    Result := PadKeys[N - 1].Num;
  finally
    Candidates.Free;
    PadKeys.Free;
    Comparer.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 14, 'One-Time Pad');

finalization
  GTask.Free;

end.
