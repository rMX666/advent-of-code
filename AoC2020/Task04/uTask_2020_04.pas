unit uTask_2020_04;

interface

uses
  System.Generics.Collections, uTask;

type
  TPassport = record
  public type
    TField = ( fBirthYear, fIssueYear, fExpirationYear, fHeight
             , fHairColor, fEyeColor, fPassportID, fCountryID );
  strict private const
    FIELD_CODES: array [Low(TField)..High(TField)] of String[3] =
      (
        'byr' // Birth Year
      , 'iyr' // Issue Year
      , 'eyr' // Expiration Year
      , 'hgt' // Height
      , 'hcl' // Hair Color
      , 'ecl' // Eye Color
      , 'pid' // Passport ID
      , 'cid' // Country ID
      );
  private
    FFields: array[Low(TField)..High(TField)] of String;
    function GetField(const Index: TField): String;
    function GetFieldByCode(const Code: String): TField;
  public
    constructor Create(const S: String);
    function IsValid(const Part: Integer): Boolean;
    property Fields[const Index: TField]: String read GetField;
  end;

  TTask_AoC = class (TTask)
  private
    FPassports: TList<TPassport>;
    procedure LoadPassports;
    function ValidAmount(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.RegularExpressions;

var
  GTask: TTask_AoC;

{ TPassport }

constructor TPassport.Create(const S: String);
var
  A, Pair: TArray<String>;
  I: Integer;
  F: TField;
begin
  for F := Low(TField) to High(TField) do
    FFields[F] := '';
  A := S.Replace(#13#10, ' ').Trim.Split([ ' ' ]);
  for I := 0 to Length(A) - 1 do
    begin
      Pair := A[I].Split([ ':' ]);
      FFields[GetFieldByCode(Pair[0])] := Pair[1];
    end;
end;

function TPassport.GetField(const Index: TField): String;
begin
  Result := FFields[Index];
end;

function TPassport.GetFieldByCode(const Code: String): TField;
begin
  for Result := Low(TField) to High(TField) do
    if String(FIELD_CODES[Result]) = Code then
      Break;
end;

function TPassport.IsValid(const Part: Integer): Boolean;
var
  F: TField;
  V: String;
  I: Integer;
begin
  Result := True;
  for F := Low(TField) to High(TField) do
    begin
      // Part 1 validations (works also for the part 2)
      if F = fCountryID then
        Continue
      else if FFields[F] = '' then
        Exit(False);

      // Part 2 extended validations
      if Part = 2 then
        begin
          V := FFields[F];
          // May have made a set of external validation rules assigned to
          // the fields, but I really don't want to mess with it, too much
          // business logic outside of the workplace for today. :)
          case F of
            fBirthYear:
              if not TRegEx.IsMatch(V, '^[0-9]{4}$') then
                Exit(False)
              else if (V.ToInteger < 1920) or (V.ToInteger > 2002) then
                Exit(False);
            fIssueYear:
              if not TRegEx.IsMatch(V, '^[0-9]{4}$') then
                Exit(False)
              else if (V.ToInteger < 2010) or (V.ToInteger > 2020) then
                Exit(False);
            fExpirationYear:
              if not TRegEx.IsMatch(V, '^[0-9]{4}$') then
                Exit(False)
              else if (V.ToInteger < 2020) or (V.ToInteger > 2030) then
                Exit(False);
            fHeight:
              begin
                with TRegEx.Match(V, '^([0-9]+)(cm|in)$') do
                  begin
                    if not Success then
                      Exit(False);
                    I := String(Groups[1].Value).ToInteger;
                    if (Groups[2].Value = 'cm') and ((I < 150) or (I > 193)) then
                      Exit(False);
                    if (Groups[2].Value = 'in') and ((I < 59) or (I > 76)) then
                      Exit(False);
                  end;
              end;
            fHairColor:
              if not TRegEx.IsMatch(V, '^#[0-9a-f]{6}$') then
                Exit(False);
            fEyeColor:
              if (V <> 'amb') and (V <> 'blu') and (V <> 'brn') and (V <> 'gry')
                and (V <> 'grn') and (V <> 'hzl') and (V <> 'oth') then
                Exit(False);
            fPassportID:
              if not TRegEx.IsMatch(V, '^[0-9]{9}$') then
                Exit(False);
            fCountryID: ; // nop
          end;
        end;
    end;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadPassports;
    OK('Part 1: %d, Part 2: %d', [ ValidAmount(1), ValidAmount(2) ]);
  finally
    FPassports.Free;
  end;
end;

procedure TTask_AoC.LoadPassports;
var
  I: Integer;
  S: String;
begin
  FPassports := TList<TPassport>.Create;
  with Input do
    try
      S := '';
      for I := 0 to Count - 1 do
        if Strings[I] = '' then
          begin
            if S <> '' then
              FPassports.Add(TPassport.Create(S));
            S := '';
          end
        else
          S := S + ' ' + Strings[I];
      // Add last passport
      FPassports.Add(TPassport.Create(S));
    finally
      Free;
    end;
end;

function TTask_AoC.ValidAmount(const Part: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FPassports.Count - 1 do
    if FPassports[I].IsValid(Part) then
      Inc(Result);
end;

initialization
  GTask := TTask_AoC.Create(2020, 4, 'Passport Processing');

finalization
  GTask.Free;

end.
