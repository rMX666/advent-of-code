unit uTask_2018_24;

interface

uses
  System.Generics.Collections, System.Generics.Defaults, uTask;

type
  TSystemType = ( stNone, stImmune, stInfection );

  TDamageType = ( dtNone, dtFire, dtRadiation, dtCold, dtSlashing, dtBludgeoning );
  TDamageTypes = set of TDamageType;

  PUnitGroup = ^TUnitGroup;
  TUnitGroup = packed record
    SystemType: TSystemType;
    Index: Integer;
    UnitCount: Integer;
    HP: Integer;
    Damage: Integer;
    DamageType: TDamageType;
    Weakness, Immunity: TDamageTypes;
    Initiative: Integer;
    Target: PUnitGroup;
    constructor Create(const S: String; const ASystemType: TSystemType; const AIndex: Integer);
    procedure Free;
    class function Pointer(const S: String; const ASystemType: TSystemType; const AIndex: Integer): PUnitGroup; static;
    function Clone: PUnitGroup;
    function EffectivePower: Integer;
    function IsDead: Boolean;
    function IsEnemy(const Target: PUnitGroup): Boolean;
    function DamageAmount(const Target: PUnitGroup): Integer;
    function AttackTarget: Boolean;
  end;

  TUnitGroups = class(TList<PUnitGroup>)
  strict private type
    TSortMode = ( smTargetSelecting, smAttacking );
    TComparer = class(TCustomComparer<PUnitGroup>)
    private
      FMode: TSortMode;
    protected
      function Compare(const Left, Right: PUnitGroup): Integer; override;
      function Equals(const Left, Right: PUnitGroup): Boolean; override;
      function GetHashCode(const Value: PUnitGroup): Integer; override;
    public
      property Mode: TSortMode read FMode write FMode;
    end;
  private
    FComparer: TComparer;
    FBoost: Integer;
    FWinner: TSystemType;
    procedure SortForTargetSelecting;
    procedure SortForAttack;
    procedure SelectTargets;
    function Attack: Boolean;
    function GetWinner: TSystemType;
    procedure SetBoost(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function Step: Boolean;
    function GetWinnerScore: Integer;
    function Clone: TUnitGroups;
    property Boost: Integer read FBoost write SetBoost;
  end;

  TTask_AoC = class (TTask)
  private
    FGroups: TUnitGroups;
    procedure LoadGroups;
    function FindTheWinnerScore: Integer;
    function BoostedImmuneScore: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.RegularExpressions, System.Hash, Vcl.Forms, Windows;

var
  GTask: TTask_AoC;

{ TUnitGroup }

constructor TUnitGroup.Create(const S: String; const ASystemType: TSystemType; const AIndex: Integer);

  function StrToDamageType(const S: String): TDamageType;
  begin
    Result := dtNone;
    if      S = 'fire'        then Result := dtFire
    else if S = 'radiation'   then Result := dtRadiation
    else if S = 'cold'        then Result := dtCold
    else if S = 'slashing'    then Result := dtSlashing
    else if S = 'bludgeoning' then Result := dtBludgeoning;
  end;

  function ParseDamageTypes(const S, RegExp: String): TDamageTypes;
  var
    A: TArray<String>;
    I: Integer;
    // Who the hell got a great thought to create a function called "Result"? (╯°□°)╯︵ ┻━┻
    Res: TDamageTypes;
  begin
    Res := [];
    with TRegEx.Match(S, RegExp) do // <- (╯°□°)╯︵ ┻━┻
      if Success and (Groups.Count > 0) then
        begin
          A := Groups[1].Value.Split([', ']);
          for I := 0 to System.Length(A) - 1 do
            Include(Res, StrToDamageType(A[I]));
        end;
    Result := Res;
  end;

const
  //                UnitCount                 HP                  Weakness,Immunity                       Damage  DamageType                    Initiative
  //        Groups: 1                         2                   3                                       4       5                             6
  MAIN_REG_EXP   = '^([0-9]+) units each with ([0-9]+) hit points (?:\(([^)]+)\) )?with an attack that does (\d+) ([a-z]+) damage at initiative (\d+)$';
  WEAK_REG_EXP   = 'weak to ([a-z, ]+)';
  IMMUNE_REG_EXP = 'immune to ([a-z, ]+)';
begin
  SystemType := ASystemType;
  Index := AIndex;
  Target := nil;

  with TRegEx.Match(S, MAIN_REG_EXP) do
    begin
      UnitCount  := Groups[1].Value.ToInteger;
      HP         := Groups[2].Value.ToInteger;
      if Groups[3].Value.Length > 0 then
        begin
          Weakness := ParseDamageTypes(Groups[3].Value, WEAK_REG_EXP);
          Immunity := ParseDamageTypes(Groups[3].Value, IMMUNE_REG_EXP);
        end
      else
        begin
          Weakness := [];
          Immunity := [];
        end;
      Damage     := Groups[4].Value.ToInteger;
      DamageType := StrToDamageType(Groups[5].Value);
      Initiative := Groups[6].Value.ToInteger;
    end;
end;

class function TUnitGroup.Pointer(const S: String; const ASystemType: TSystemType; const AIndex: Integer): PUnitGroup;
begin
  New(Result);
  Result^ := TUnitGroup.Create(S, ASystemType, AIndex);
end;

procedure TUnitGroup.Free;
begin
  Dispose(@Self);
end;

function TUnitGroup.Clone: PUnitGroup;
begin
  New(Result);
  CopyMemory(Result, @Self, SizeOf(TUnitGroup));
end;

function TUnitGroup.IsDead: Boolean;
begin
  Result := UnitCount <= 0;
end;

function TUnitGroup.IsEnemy(const Target: PUnitGroup): Boolean;
begin
  Result := SystemType <> Target.SystemType;
end;

function TUnitGroup.EffectivePower: Integer;
begin
  Result := UnitCount * Damage;
end;

function TUnitGroup.DamageAmount(const Target: PUnitGroup): Integer;
begin
  if Target = nil then
    Exit(0);

  if DamageType in Target.Immunity then
    Exit(0);

  Result := EffectivePower;
  if DamageType in Target.Weakness then
    Result := Result * 2;
end;

function TUnitGroup.AttackTarget: Boolean;
var
  Amount: Integer;
begin
  if Target = nil then
    Exit(False);

  if Target.IsDead then
    Exit(False);

  Amount := DamageAmount(Target);
  Dec(Target.UnitCount, Amount div Target.HP);

  Result := (Amount div Target.HP) > 0;
end;

{ TUnitGroups.TComparer }

function TUnitGroups.TComparer.Compare(const Left, Right: PUnitGroup): Integer;
begin
  // Decreasing order: Right - Left

  Result := 0;

  if FMode = smTargetSelecting then
    Result := Right.EffectivePower - Left.EffectivePower;

  if Result = 0 then
    Result := Right.Initiative - Left.Initiative;
end;

function TUnitGroups.TComparer.Equals(const Left, Right: PUnitGroup): Boolean;
begin
  Result := Compare(Left, Right) = 0;
end;

function TUnitGroups.TComparer.GetHashCode(const Value: PUnitGroup): Integer;
begin
  Result := THashBobJenkins.GetHashValue(Value, SizeOf(PUnitGroup), 0);
end;

{ TUnitGroups }

function TUnitGroups.Clone: TUnitGroups;
var
  I: Integer;
begin
  Result := TUnitGroups.Create;
  for I := 0 to Count - 1 do
    Result.Add(Items[I].Clone);
end;

constructor TUnitGroups.Create;
begin
  FComparer := TUnitGroups.TComparer.Create;
  inherited Create(FComparer);
  FWinner := stNone;
end;

destructor TUnitGroups.Destroy;
var
  I: Integer;
begin
  FComparer.Free;
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited;
end;

procedure TUnitGroups.SelectTargets;
var
  I, J, AmountJ, AmountCandidate: Integer;
  Candidate: PUnitGroup;
  Selected: TList<PUnitGroup>;
begin
  SortForTargetSelecting;

  Selected := TList<PUnitGroup>.Create;
  try
    for I := 0 to Count - 1 do
      begin
        Candidate       := nil;
        Items[I].Target := nil;
        if Items[I].IsDead then
          Continue;
        for J := 0 to Count - 1 do
          if not Items[J].IsDead and Items[I].IsEnemy(Items[J]) and not Selected.Contains(Items[J]) then
            begin
              AmountJ         := Items[I].DamageAmount(Items[J]);
              AmountCandidate := Items[I].DamageAmount(Candidate);
              if AmountJ = 0 then
                Continue;
              if AmountJ > AmountCandidate then
                Candidate := Items[J]
              else if Assigned(Candidate) and (AmountJ = AmountCandidate) and (FComparer.Compare(Items[J], Candidate) < 0) then
                Candidate := Items[J];
            end;
        if Assigned(Candidate) then
          begin
            Items[I].Target := Candidate;
            Selected.Add(Candidate);
          end;
      end;
  finally
    Selected.Free;
  end;
end;

procedure TUnitGroups.SetBoost(const Value: Integer);
var
  I: Integer;
begin
  FBoost := Value;
  for I := 0 to Count - 1 do
    if Items[I].SystemType = stImmune then
      Inc(Items[I].Damage, FBoost);
end;

function TUnitGroups.Attack: Boolean;
var
  I: Integer;
begin
  SortForAttack;

  Result := False;
  for I := 0 to Count - 1 do
    Result := Items[I].AttackTarget or Result;
end;

procedure TUnitGroups.SortForAttack;
begin
  FComparer.Mode := smAttacking;
  Sort;
end;

procedure TUnitGroups.SortForTargetSelecting;
begin
  FComparer.Mode := smTargetSelecting;
  Sort;
end;

function TUnitGroups.Step: Boolean;
begin
  SelectTargets;
  // No attacks - exit, no one can move
  if not Attack then
    Exit(False);

  Result := GetWinner = stNone;
end;

function TUnitGroups.GetWinner: TSystemType;
var
  Counts: array [ stImmune..stInfection ] of Integer;
  I: Integer;
begin
  if FWinner <> stNone then
    Exit(FWinner);

  FillChar(Counts, SizeOf(Counts), 0);
  for I := 0 to Count - 1 do
    if not Items[I].IsDead then
      Inc(Counts[Items[I].SystemType]);

  Result := stNone;
  if (Counts[stImmune] > 0) and (Counts[stInfection] > 0) then
    Result := stNone
  else if Counts[stImmune] > 0 then
    Result := stImmune
  else if Counts[stInfection] > 0 then
    Result := stInfection;

  FWinner := Result;
end;

function TUnitGroups.GetWinnerScore: Integer;
var
  I: Integer;
begin
  while Step do;

  if GetWinner = stNone then
    Exit(0);

  Result := 0;
  for I := 0 to Count - 1 do
    if not Items[I].IsDead then
      Inc(Result, Items[I].UnitCount);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadGroups;

    OK('Part 1: %d, Part 2: %d', [ FindTheWinnerScore, BoostedImmuneScore ]);
  finally
    FGroups.Free;
  end;
end;

function TTask_AoC.FindTheWinnerScore: Integer;
begin
  with FGroups.Clone do
    try
      Result := GetWinnerScore;
    finally
      Free;
    end;
end;

function TTask_AoC.BoostedImmuneScore: Integer;
var
  B: Integer;
  Winner: TSystemType;
begin
  B := 1;

  repeat
    with FGroups.Clone do
      try
        Boost := B;
        Result := GetWinnerScore;
        Winner := GetWinner;
        Inc(B);
      finally
        Free;
      end;
  until Winner = stImmune;
end;

procedure TTask_AoC.LoadGroups;
var
  I: Integer;
  CurrentSystem: TSystemType;
  Counts: array [stImmune..stInfection] of Integer;
begin
  FGroups := TUnitGroups.Create;
  CurrentSystem := stNone;
  FillChar(Counts, SizeOf(Counts), 0);
  with Input do
    try
      for I := 0 to Count - 1 do
        if Strings[I].Contains('Immune') then
          CurrentSystem := stImmune
        else if Strings[I].Contains('Infection') then
          CurrentSystem := stInfection
        else if Strings[I].Trim <> '' then
          begin
            Inc(Counts[CurrentSystem]);
            FGroups.Add(TUnitGroup.Pointer(Strings[I], CurrentSystem, Counts[CurrentSystem]));
          end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 24, 'Immune System Simulator 20XX');

finalization
  GTask.Free;

end.
