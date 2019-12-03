unit uTask_2015_21;

interface

uses
  uTask, System.Generics.Collections;

type
  TWarItem = record
    Cost, Damage, Armor: Integer;
    constructor Create(const ACost, ADamage, AArmor: Integer);
    class operator Add(A, B: TWarItem): TWarItem;
  end;

  TWarItems = TList<TWarItem>;

  TTask_AoC = class (TTask)
  private
    FWarSets: TWarItems;
    FPlayerHP,
    FBossHP, FBossDamage, FBossArmor: Integer;
    procedure InitializeItems;
    function MinimalCostWin: Integer;
    function MaximalCostLose: Integer;
    function HitCount(const HP, Damage: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uUtil;

var
  GTask: TTask_AoC;

{ TWarItem }

class operator TWarItem.Add(A, B: TWarItem): TWarItem;
begin
  Result.Cost := A.Cost + B.Cost;
  Result.Damage := A.Damage + B.Damage;
  Result.Armor := A.Armor + B.Armor;
end;

constructor TWarItem.Create(const ACost, ADamage, AArmor: Integer);
begin
  Cost := ACost;
  Damage := ADamage;
  Armor := AArmor;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  InitializeItems;
  try
    OK('Part 1: %d, Part 2: %d', [ MinimalCostWin, MaximalCostLose ]);
  finally
    FWarSets.Free;
  end;
end;

function TTask_AoC.HitCount(const HP, Damage: Integer): Integer;
begin
  Result := (HP - 1) div Max(1, Damage) + 1;
end;

procedure TTask_AoC.InitializeItems;
var
  Weapons, Armors, Rings: TWarItems;
  Weapon, Armor, Ring: TWarItem;
  RingSub: TArray<TWarItem>;
  RingSequences: TSubSequences<TWarItem>;
  ItemSet: TWarItem;
begin
  FPlayerHP := 100;
  with Input do
    try
      FBossHP     := Strings[0].Split([': '])[1].ToInteger;
      FBossDamage := Strings[1].Split([': '])[1].ToInteger;
      FBossArmor  := Strings[2].Split([': '])[1].ToInteger;
    finally
      Free;
    end;

  FWarSets := TWarItems.Create;

  Weapons := TWarItems.Create;
  with Weapons do
    begin
      Add(TWarItem.Create( 8, 4, 0));
      Add(TWarItem.Create(10, 5, 0));
      Add(TWarItem.Create(25, 6, 0));
      Add(TWarItem.Create(40, 7, 0));
      Add(TWarItem.Create(74, 8, 0));
    end;

  Armors := TWarItems.Create;
  with Armors do
    begin
      Add(TWarItem.Create(  0, 0, 0)); // Empty armor = no armor
      Add(TWarItem.Create( 13, 0, 1));
      Add(TWarItem.Create( 31, 0, 2));
      Add(TWarItem.Create( 53, 0, 3));
      Add(TWarItem.Create( 75, 0, 4));
      Add(TWarItem.Create(102, 0, 5));
    end;

  Rings := TWarItems.Create;
  with Rings do
    begin
      Add(TWarItem.Create( 25, 1, 0));
      Add(TWarItem.Create( 50, 2, 0));
      Add(TWarItem.Create(100, 3, 0));
      Add(TWarItem.Create( 20, 0, 1));
      Add(TWarItem.Create( 40, 0, 2));
      Add(TWarItem.Create( 80, 0, 3));
    end;

  RingSequences := TSubSequences<TWarItem>.Create(Rings.ToArray, 0, 2);

  try
    for Weapon in Weapons do
      for Armor in Armors do
        for RingSub in RingSequences do
          begin
            ItemSet := Weapon + Armor;              
            if Length(RingSub) > 0 then
              for Ring in RingSub do
                ItemSet := ItemSet + Ring;
            FWarSets.Add(ItemSet);
          end;
  finally
    Weapons.Free;
    Armors.Free;
    Rings.Free;
    RingSequences.Free;
  end;
end;

function TTask_AoC.MaximalCostLose: Integer;
var
  Item: TWarItem;
begin
  Result := 0;

  for Item in FWarSets do
    if HitCount(FPlayerHP, FBossDamage - Item.Armor) < HitCount(FBossHP, Item.Damage - FBossArmor) then
      if Result < Item.Cost then
        Result := Item.Cost;
end;

function TTask_AoC.MinimalCostWin: Integer;
var
  Item: TWarItem;
begin
  Result := MaxInt;

  for Item in FWarSets do
    if HitCount(FPlayerHP, FBossDamage - Item.Armor) >= HitCount(FBossHP, Item.Damage - FBossArmor) then
      if Result > Item.Cost then
        Result := Item.Cost;      
end;

initialization
  GTask := TTask_AoC.Create(2015, 21, 'RPG Simulator 20XX');

finalization
  GTask.Free;

end.
