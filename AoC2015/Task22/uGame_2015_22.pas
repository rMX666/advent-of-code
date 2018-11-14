unit uGame_2015_22;

interface

uses
  System.Generics.Collections, System.Math;

type
  TPlayer = class;
  TSpell = class;

  TSpellHandler = procedure (Sender: TSpell) of object;

  TSpell = class
  private
    FOwner: TPlayer;
    FName: String;
    FDamage: Integer;
    FCost: Integer;
    FDuration: Integer;
    FTimer: Integer;
    FActive: Boolean;
    FOnFinish: TSpellHandler;
    FOnStart: TSpellHandler;
    FOnEffect: TSpellHandler;
  protected
    procedure DoStart;
    procedure DoEffect;
    procedure DoFinish;
    property Owner: TPlayer read FOwner;
  public
    constructor Create(const AOwner: TPlayer; const AName: String; const ACost, ADuration, ADamage: Integer);
    procedure Cast;
    procedure Turn;
    function IsFinished: Boolean;
    function CanCast: Boolean;
    function Clone(const AOwner: TPlayer): TSpell;
    property Cost: Integer read FCost;
    property Duration: Integer read FDuration;
    property Damage: Integer read FDamage;
    property OnStart: TSpellHandler read FOnStart write FOnStart;
    property OnFinish: TSpellHandler read FOnFinish write FOnFinish;
    property OnEffect: TSpellHandler read FOnEffect write FOnEffect;
  end;

  TSpellBook = class(TList<TSpell>)
  private
    FOwner: TPlayer;
    procedure CreateSpells;
  private
    // Spell handlers
    procedure MagicMissileEffect(Sender: TSpell);
    procedure DrainEffect(Sender: TSpell);
    procedure ShieldStart(Sender: TSpell);
    procedure ShieldFinish(Sender: TSpell);
    procedure PoisonEffect(Sender: TSpell);
    procedure RechargeEffect(Sender: TSpell);
  public
    constructor Create(const AOwner: TPlayer);
    destructor Destroy; override;
    procedure Turn;
  end;

  TPlayerType = (ptWizard, ptBoss);
  TPlayer = class
  private
    FHealth: Integer;
    FDamage: Integer;
    FArmor: Integer;
    FMana: Integer;
    FManaSpent: Integer;
    FSpellBook: TSpellBook;
    FSpellsDone: TSpellBook;
    FOpponent: TPlayer;
    FPlayerType: TPlayerType;
  public
    constructor Create(const APlayerType: TPlayerType; const AHealth, ADamage, AArmor, AMana, AManaSpent: Integer);
    destructor Destroy; override;
    procedure GetDamaged(const Value: Integer);
    procedure GetHealed(const Value: Integer);
    procedure SpendMana(const Value: Integer);
    procedure AddMana(const Value: Integer);
    procedure AddArmor(const Value: Integer);
    procedure Attack; virtual;
    function Clone: TPlayer;
    property PlayerType: TPlayerType read FPlayerType;
    property Opponent: TPlayer read FOpponent write FOpponent;
    property SpellBook: TSpellBook read FSpellBook;
    function IsDead: Boolean;
  end;

  TSimulator = class
  private
    FBoss: TPlayer;
    FWizard: TPlayer;
    FTurn: Integer;
    constructor Create; overload;
    constructor Create(const ABossHealth, ABossDamage: Integer); overload;
    destructor Destroy; override;
    function Clone: TSimulator;
  public
    // Mode: False - Regular mode, True - hard mode
    class function Simulate(const ABossHealth, ABossDamage: Integer; const Mode: Boolean): Integer;
  end;

implementation

uses
  System.SysUtils;

{ TSpell }

function TSpell.CanCast: Boolean;
begin
  Result := (not FActive or (FActive and (FTimer + 1 = FDuration))) and (FOwner.FMana >= Cost);
end;

procedure TSpell.Cast;
begin
  FOwner.FSpellsDone.Add(TSpell.Create(nil, FName, FCost, FDuration, FDamage));

  if FDuration > 0 then
    DoStart
  else
    DoEffect;

  FOwner.SpendMana(Cost);
end;

procedure TSpell.Turn;
begin
  if FActive then
    begin
      DoEffect;
      if IsFinished then
        DoFinish;
    end;
end;

function TSpell.Clone(const AOwner: TPlayer): TSpell;
begin
  Result := TSpell.Create(AOwner, FName, FCost, FDuration, FDamage);
  Result.FTimer := FTimer;
  Result.FActive := FActive;
  Result.FOnFinish := FOnFinish;
  Result.FOnStart := FOnStart;
  Result.FOnEffect := FOnEffect;
end;

constructor TSpell.Create(const AOwner: TPlayer; const AName: String; const ACost, ADuration, ADamage: Integer);
begin
  FOwner := AOwner;
  FName := AName;
  FCost := ACost;
  FDuration := ADuration;
  FTimer := 0;
  FDamage := ADamage;
  FActive := False;
end;

procedure TSpell.DoEffect;
begin
  if FActive then
    Inc(FTimer);
  if Assigned(FOnEffect) then
    FOnEffect(Self);
end;

procedure TSpell.DoFinish;
begin
  FActive := False;
  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TSpell.DoStart;
begin
  FActive := True;
  FTimer := 0;
  if Assigned(FOnStart) then
    FOnStart(Self);
end;

function TSpell.IsFinished: Boolean;
begin
  Result := FTimer >= FDuration;
end;

{ TSpellBook }

constructor TSpellBook.Create(const AOwner: TPlayer);
begin
  inherited Create;
  FOwner := AOwner;
  CreateSpells;
end;

procedure TSpellBook.CreateSpells;
var
  Spell: TSpell;
begin
  if FOwner = nil then
    Exit;

  if FOwner.PlayerType <> ptWizard then
    Exit;

  Spell := TSpell.Create(FOwner, 'Magic Missile', 53, 0, 4);
  Spell.OnEffect := MagicMissileEffect;
  Add(Spell);

  Spell := TSpell.Create(FOwner, 'Drain', 73, 0, 2);
  Spell.OnEffect := DrainEffect;
  Add(Spell);

  Spell := TSpell.Create(FOwner, 'Shield', 113, 6, 7);
  Spell.OnStart := ShieldStart;
  Spell.OnFinish := ShieldFinish;
  Add(Spell);

  Spell := TSpell.Create(FOwner, 'Poison', 173, 6, 3);
  Spell.OnEffect := PoisonEffect;
  Add(Spell);

  Spell := TSpell.Create(FOwner, 'Recharge', 229, 5, 101);
  Spell.OnEffect := RechargeEffect;
  Add(Spell);
end;

destructor TSpellBook.Destroy;
var
  I: Integer;
  Item: TSpell;
begin
  for I := 0 to Count - 1 do
    begin
      Item := Items[I];
      FreeAndNil(Item);
    end;
  Clear;
  inherited;
end;

procedure TSpellBook.DrainEffect(Sender: TSpell);
begin
  Sender.Owner.GetHealed(Sender.Damage);
  Sender.Owner.Opponent.GetDamaged(Sender.Damage);
end;

procedure TSpellBook.MagicMissileEffect(Sender: TSpell);
begin
  Sender.Owner.Opponent.GetDamaged(Sender.Damage);
end;

procedure TSpellBook.PoisonEffect(Sender: TSpell);
begin
  Sender.Owner.Opponent.GetDamaged(Sender.Damage);
end;

procedure TSpellBook.RechargeEffect(Sender: TSpell);
begin
  Sender.Owner.AddMana(Sender.Damage);
end;

procedure TSpellBook.ShieldFinish(Sender: TSpell);
begin
  Sender.Owner.AddArmor(-Sender.Damage);
end;

procedure TSpellBook.ShieldStart(Sender: TSpell);
begin
  Sender.Owner.AddArmor(Sender.Damage);
end;

procedure TSpellBook.Turn;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Turn;
end;

{ TPlayer }

procedure TPlayer.AddArmor(const Value: Integer);
begin
  Inc(FArmor, Value);
end;

procedure TPlayer.AddMana(const Value: Integer);
begin
  Inc(FMana, Value);
end;

procedure TPlayer.Attack;
begin
  Opponent.GetDamaged(FDamage);
end;

function TPlayer.Clone: TPlayer;
var
  I: Integer;
begin
  Result := TPlayer.Create(FPlayerType, FHealth, FDamage, FArmor, FMana, FManaSpent);

  if FPlayerType <> ptWizard then
    Exit;

  for I := 0 to Result.SpellBook.Count - 1 do
    Result.SpellBook[I].Free;
  Result.SpellBook.Clear;
  for I := 0 to FSpellBook.Count - 1 do
    Result.SpellBook.Add(FSpellBook[I].Clone(Result));

  for I := 0 to FSpellsDone.Count - 1 do
    Result.FSpellsDone.Add(FSpellsDone[I].Clone(nil));
end;

constructor TPlayer.Create(const APlayerType: TPlayerType; const AHealth, ADamage, AArmor, AMana, AManaSpent: Integer);
begin
  FPlayerType := APlayerType;
  FHealth := AHealth;
  FDamage := ADamage;
  FArmor := AArmor;
  FMana := AMana;
  FManaSpent := AManaSpent;

  FSpellBook := TSpellBook.Create(Self);
  FSpellsDone := TSpellBook.Create(nil);
end;

destructor TPlayer.Destroy;
begin
  FreeAndNil(FSpellBook);
  FreeAndNil(FSpellsDone);
  inherited;
end;

procedure TPlayer.GetDamaged(const Value: Integer);
begin
  Dec(FHealth, Max(1, Value - FArmor));
end;

procedure TPlayer.GetHealed(const Value: Integer);
begin
  Inc(FHealth, Value);
end;

function TPlayer.IsDead: Boolean;
var
  I: Integer;
begin
  Result := FHealth <= 0;

  if Result and (PlayerType = ptWizard) then
    begin
      Result := False;
      for I := 0 to SpellBook.Count - 1 do
        if not SpellBook[I].FActive and (SpellBook[I].Cost <= FMana) then
          Exit(True);
    end;
end;

procedure TPlayer.SpendMana(const Value: Integer);
begin
  Inc(FManaSpent, Value);
  AddMana(-Value);
end;

{ TSimulator }

function TSimulator.Clone: TSimulator;
begin
  Result := TSimulator.Create;
  Result.FBoss := FBoss.Clone;
  Result.FWizard := FWizard.Clone;
  Result.FTurn := FTurn + 2;

  with Result do
    begin
      FBoss.Opponent := FWizard;
      FWizard.Opponent := FBoss;
    end;
end;

constructor TSimulator.Create(const ABossHealth, ABossDamage: Integer);
begin
  FBoss := TPlayer.Create(ptBoss, ABossHealth, ABossDamage, 0, 0, 0);
  FWizard := TPlayer.Create(ptWizard, 50, 0, 0, 500, 0);

  FBoss.Opponent := FWizard;
  FWizard.Opponent := FBoss;

  FTurn := 0;
end;

destructor TSimulator.Destroy;
begin
  FreeAndNil(FBoss);
  FreeAndNil(FWizard);
  inherited;
end;

constructor TSimulator.Create;
begin
end;

class function TSimulator.Simulate(const ABossHealth, ABossDamage: Integer; const Mode: Boolean): Integer;
var
  SimQueue: TObjectQueue<TSimulator>;
  Sim, NextSim: TSimulator;
  I: Integer;

  function TurnSim(const Sim: TSimulator; const Index: Integer): Boolean;
  begin
    Result := True;

    if Mode then
      begin
        Sim.FWizard.GetHealed(-1);
        if Sim.FWizard.IsDead then
          Exit(False);
      end;

    Sim.FWizard.SpellBook.Turn;
    Sim.FWizard.SpellBook[Index].Cast;
    Sim.FWizard.SpellBook.Turn;
    Sim.FBoss.Attack;
  end;

begin
  Result := MaxInt;

  SimQueue := TObjectQueue<TSimulator>.Create(True);
  SimQueue.Enqueue(TSimulator.Create(ABossHealth, ABossDamage));

  try
    while SimQueue.Count > 0 do
      begin
        Sim := SimQueue.Peek;

        for I := 0 to Sim.FWizard.SpellBook.Count - 1 do
          if Sim.FWizard.SpellBook[I].CanCast then
            begin
              NextSim := Sim.Clone;

              if not TurnSim(NextSim, I) then
                FreeAndNil(NextSim)
              else
                begin
                  if NextSim.FBoss.IsDead then
                    if Result > NextSim.FWizard.FManaSpent then
                      Result := NextSim.FWizard.FManaSpent;

                  if not (NextSim.FWizard.IsDead or NextSim.FBoss.IsDead) and (Result > NextSim.FWizard.FManaSpent) then
                    SimQueue.Enqueue(NextSim)
                  else
                    FreeAndNil(NextSim);
                end;
            end;
        SimQueue.Dequeue;
      end;
  finally
    SimQueue.Free;
  end;
end;

end.
