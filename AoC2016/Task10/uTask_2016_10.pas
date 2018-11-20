unit uTask_2016_10;

interface

uses
  System.Generics.Collections, uTask;

type
  TConveyor = class;

  TOutType = ( otBot, otOutput );

  PBot = ^TBot;
  TBot = record
    Owner: TConveyor;
    Number: Integer;
    ValueLo, ValueHi: Integer;
    LoTo, HiTo: Integer;
    LoOutType, HiOutType: TOutType;
    constructor Create(const AOwner: TConveyor; const S: String);
    procedure SetValue(const Value: Integer);
    procedure SendValues;
  end;

  TIO = TList<Integer>;

  TBots = TDictionary<Integer, PBot>;
  TInputs =  TObjectDictionary<Integer, TIO>;
  TOutputs = TObjectDictionary<Integer, TIO>;

  TBotOnSendValue = procedure (const Bot: TBot) of object;

  TConveyor = class
  private
    FBots: TBots;
    FInputs: TInputs;
    FOutputs: TOutputs;
    FOnSendValue: TBotOnSendValue;
    procedure AddBot(const S: String);
    procedure AddInput(const S: String);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const S: String);
    procedure Run;
    property OnSendValue: TBotOnSendValue read FOnSendValue write FOnSendValue;
  end;

  TTask_AoC = class (TTask)
  private
    FConveyor: TConveyor;
    F_17_61_BotNo: Integer;
    procedure LoadConveyor;
    procedure DoOnSendValue(const Bot: TBot);
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TBot }

constructor TBot.Create(const AOwner: TConveyor; const S: String);

  function GetOutType(const S: String): TOutType;
  begin
    if S = 'bot' then
      Result := otBot
    else
      Result := otOutput;
  end;

var
  A: TArray<String>;
begin
  Owner := AOwner;
  A := S.Split([' ']);
  Number := A[1].ToInteger;
  LoTo := A[6].ToInteger;
  HiTo := A[11].ToInteger;
  LoOutType := GetOutType(A[5]);
  HiOutType := GetOutType(A[10]);
  ValueLo := -1;
  ValueHi := -1;
end;

procedure TBot.SendValues;

  procedure Give(const OutType: TOutType; const ATo, AValue: Integer);
  begin
    if OutType = otBot then
      Owner.FBots[ATo].SetValue(AValue)
    else
      begin
        if not Owner.FOutputs.ContainsKey(ATo) then
          Owner.FOutputs.Add(ATo, TIO.Create);
        Owner.FOutputs[ATo].Add(AValue);
      end;
  end;

begin
  if Assigned(Owner.FOnSendValue) then
    Owner.FOnSendValue(Self);
  Give(LoOutType, LoTo, ValueLo);
  Give(HiOutType, HiTo, ValueHi);
  ValueLo := -1;
  ValueHi := -1;
end;

procedure TBot.SetValue(const Value: Integer);
begin
  if ValueLo < 0 then
    ValueLo := Value
  else
    begin
      ValueHi := Max(ValueLo, Value);
      ValueLo := Min(ValueLo, Value);
      SendValues;
    end;
end;

{ TConveyor }

procedure TConveyor.Add(const S: String);
begin
  if S.StartsWith('value') then
    AddInput(S)
  else
    AddBot(S);
end;

procedure TConveyor.AddBot(const S: String);
var
  Bot: PBot;
begin
  New(Bot);
  Bot^ := TBot.Create(Self, S);
  FBots.Add(Bot.Number, Bot);
end;

procedure TConveyor.AddInput(const S: String);
var
  A: TArray<String>;
  Value, Bot: Integer;
begin
  A := S.Split([' ']);
  Value := A[1].ToInteger;
  Bot := A[5].ToInteger;
  if not FInputs.ContainsKey(Bot) then
    FInputs.Add(Bot, TIO.Create);
  FInputs[Bot].Add(Value);
end;

constructor TConveyor.Create;
begin
  FBots := TBots.Create;
  FInputs := TInputs.Create([ doOwnsValues ]);
  FOutputs := TOutputs.Create([ doOwnsValues ]);
end;

destructor TConveyor.Destroy;
var
  Bot: PBot;
begin
  for Bot in FBots.Values do
    Dispose(Bot);
  FBots.Free;
  FInputs.Free;
  FOutputs.Free;
  inherited;
end;

procedure TConveyor.Run;
var
  Bot, I: Integer;
begin
  for Bot in FInputs.Keys do
    for I := 0 to FInputs[Bot].Count - 1 do
      FBots[Bot].SetValue(FInputs[Bot][I]);
end;

{ TTask_AoC }

procedure TTask_AoC.DoOnSendValue(const Bot: TBot);
begin
  if (Bot.ValueLo = 17) and (Bot.ValueHi = 61) then
    F_17_61_BotNo := Bot.Number;
end;

procedure TTask_AoC.DoRun;
var
  Part2, I: Integer;
begin
  LoadConveyor;
  try
    FConveyor.Run;

    Part2 := 1;
    for I := 0 to 2 do
      Part2 := Part2 * FConveyor.FOutputs[I].First;

    OK(Format('Part 1: %d, Part 2: %d', [ F_17_61_BotNo, Part2 ]))
  finally
    FConveyor.Free;
  end;
end;

procedure TTask_AoC.LoadConveyor;
var
  I: Integer;
begin
  FConveyor := TConveyor.Create;
  FConveyor.OnSendValue := DoOnSendValue;
  with Input do
    try
      for I := 0 to Count - 1 do
        FConveyor.Add(Strings[I]);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 10, 'Balance Bots');

finalization
  GTask.Free;

end.
