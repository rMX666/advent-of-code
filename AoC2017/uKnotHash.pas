unit uKnotHash;

interface

uses
  SysUtils;

const
  KNOT_SALT_LENGTH = 5;
  KNOT_SALT: array [ 0..KNOT_SALT_LENGTH - 1 ] of Byte = ( 17, 31, 73, 47, 23 );
  KNOT_ROUNDS = 64;

type
  TByteArray256 = array [0..255] of Byte;
  TKnotKey      = TArray<Byte>;

  TCiclingList = class
  private
    FList: TByteArray256;
    procedure Rot(const Value: Integer);
    procedure Reverse(const N: Integer);
  public
    constructor Create;
  end;

  TKnotHash = class
  private
    FList: TCiclingList;
    FKey: TKnotKey;
    function GetRawList: TByteArray256;
    procedure AddSalt;
    function StrToKey(const S: String): TKnotKey;
    function XorAndHex: String;
  public
    constructor Create(const AKey: TKnotKey; const Salted: Boolean = False); overload;
    constructor Create(const SKey: String; const Salted: Boolean = False); overload;
    destructor Destroy; override;
    procedure Hash(const Rounds: Integer = 1);
    property RawList: TByteArray256 read GetRawList;
    class function HashHex(const S: String): String;
  end;

implementation

{ TCiclingList }

constructor TCiclingList.Create;
var
  I: Integer;
begin
  for I := 0 to 255 do
    FList[I] := I;
end;

procedure TCiclingList.Reverse(const N: Integer);
var
  Next: TByteArray256;
  I: Integer;
begin
  Next := FList;
  for I := 0 to N - 1 do
    FList[I] := Next[N - I - 1];
end;

procedure TCiclingList.Rot(const Value: Integer);
var
  Next: TByteArray256;
  I: Integer;
begin
  Next := FList;
  for I := 0 to 255 do
    FList[I] := Next[(I + Value + 256) mod 256];
end;

{ TKnotHash }

constructor TKnotHash.Create(const AKey: TKnotKey; const Salted: Boolean);
begin
  FKey := AKey;

  if Salted then
    AddSalt;

  FList := TCiclingList.Create;
end;

constructor TKnotHash.Create(const SKey: String; const Salted: Boolean);
begin
  Create(StrToKey(SKey), Salted);
end;

destructor TKnotHash.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TKnotHash.AddSalt;
var
  I, L: Integer;
begin
  L := Length(FKey);
  SetLength(FKey, L + KNOT_SALT_LENGTH);
  for I := 0 to KNOT_SALT_LENGTH - 1 do
    FKey[L + I] := KNOT_SALT[I];
end;

function TKnotHash.GetRawList: TByteArray256;
begin
  Result := FList.FList;
end;

procedure TKnotHash.Hash(const Rounds: Integer);
var
  I, J, Skip, Reverse: Integer;
begin
  Skip := 0;
  Reverse := 0;
  for J := 1 to Rounds do
    for I := 0 to Length(FKey) - 1 do
      begin
        FList.Reverse(FKey[I]);
        FList.Rot(FKey[I] + Skip);
        Inc(Reverse, FKey[I] + Skip);
        Inc(Skip);
      end;

  FList.Rot(-(Reverse mod 256));
end;

class function TKnotHash.HashHex(const S: String): String;
begin
  with TKnotHash.Create(S, True) do
    try
      Hash(KNOT_ROUNDS);
      Result := XorAndHex;
    finally
      Free;
    end;
end;

function TKnotHash.StrToKey(const S: String): TKnotKey;
var
  I: Integer;
begin
  SetLength(Result, S.Length);
  for I := 1 to S.Length do
    Result[I - 1] := Ord(S[I]);
end;

function TKnotHash.XorAndHex: String;
var
  Part, I, X: Integer;
begin
  Part := 0;
  while Part < 256 do
    begin
      X := FList.FList[Part];
      for I := Part + 1 to Part + 15 do
        X := X xor FList.FList[I];
      Result := Result + X.ToHexString.TrimLeft(['0']).PadLeft(2, '0');
      Inc(Part, 16);
    end;
end;

end.
