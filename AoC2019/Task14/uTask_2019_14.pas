unit uTask_2019_14;

interface

uses
  uTask, System.Generics.Collections;

type
  TElement = record
    Name: String;
    Quantity: Integer;
    constructor Create(const S: String);
    function ToString: String;
  end;

  TReaction = record
    Output: TElement;
    Input: TArray<TElement>;
    constructor Create(const S: String);
    function ToString: String;
  end;

  TReactionFlow = TDictionary<String,TReaction>;
  TIngridients = TDictionary<String,Int64>;

  TTask_AoC = class (TTask)
  private
    FReactions: TReactionFlow;
    FSpare: TIngridients;
    FUsed: TIngridients;
    FCostOfOneFuel: Integer;
    procedure LoadReactions;
    procedure ProduceFuel(const Amount: Int64 = 1);
    function CostOfOneFuel: Integer;
    function MaxFuelCount(const OreAmount: Int64): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TElement }

constructor TElement.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Split([' ']);
  Name := A[1];
  Quantity := A[0].ToInteger;
end;

function TElement.ToString: String;
begin
  Result := Format('%d %s', [ Quantity, Name ])
end;

{ TReaction }

constructor TReaction.Create(const S: String);
var
  A: TArray<String>;
  I: Integer;
begin
  A := S.Split([' => ']);
  Output := TElement.Create(A[1]);
  A := A[0].Split([', ']);
  SetLength(Input, Length(A));
  for I := 0 to Length(A) - 1 do
    Input[I] := TElement.Create(A[I]);
end;

function TReaction.ToString: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(Input) - 1 do
    Result := Result + ', ' + Input[I].ToString;

  Result := Result.Substring(2) + ' => ' + Output.ToString;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  FCostOfOneFuel := 0;
  LoadReactions;
  try
    OK('Part 1: %d, Part 2: %d', [ CostOfOneFuel, MaxFuelCount(1000000000000) ]);
  finally
    FReactions.Free;
  end;
end;

procedure TTask_AoC.LoadReactions;
var
  I: Integer;
  R: TReaction;
begin
  FReactions := TReactionFlow.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          R := TReaction.Create(Strings[I]);
          FReactions.Add(R.Output.Name, R);
        end;
    finally
      Free;
    end;
end;

procedure TTask_AoC.ProduceFuel(const Amount: Int64);
var
  Level: Integer;

  function Pad: String;
  begin
    Result := ''.PadLeft(Level * 2, ' ');
  end;

  procedure Use(const Name: String; const Quantity: Int64);
  begin
    Logger.WriteLine(Pad + '  Using: %s %d', [ Name, Quantity ]);

    if FSpare.ContainsKey(Name) then
      begin
        FSpare[Name] := FSpare[Name] - Quantity;
        Logger.WriteLine(Pad + '    Spare left: %d', [ FSpare[Name] ]);
      end;

    if FUsed.ContainsKey(Name) then
      FUsed[Name] := FUsed[Name] + Quantity
    else
      FUsed.Add(Name, Quantity);

    Logger.WriteLine(Pad + '    Used for now: %d', [ FUsed[Name] ]);
  end;

  procedure CountReaction(const R: TReaction; const Quantity: Int64);
  var
    I: Integer;
    Q: Int64;
  begin
    // Check spare record, create if not exists
    if not FSpare.ContainsKey(R.Output.Name) then
      FSpare.Add(R.Output.Name, 0);

    Logger.WriteLine(Pad + 'Doing reaction: %s => %d (Spare: %d)', [ R.ToString, Quantity, FSpare[R.Output.Name] ]);

    // If spare is enough for output, use it and exit
    if FSpare[R.Output.Name] >= Quantity then
      Exit;

    // Make enough spare parts
    while FSpare[R.Output.Name] < Quantity do
      begin
        Q := Ceil((Quantity - FSpare[R.Output.Name]) / R.Output.Quantity);
        // Process input ingridients to assure they've been used to make output
        for I := 0 to Length(R.Input) - 1 do
          begin
            if FReactions.ContainsKey(R.Input[I].Name) then
              try
                Inc(Level);
                CountReaction(FReactions[R.Input[I].Name], R.Input[I].Quantity * Q);
              finally
                Dec(Level);
              end;
            Use(R.Input[I].Name, R.Input[I].Quantity * Q);
          end;
        // Add spare quantity
        FSpare[R.Output.Name] := FSpare[R.Output.Name] + R.Output.Quantity * Q;
        Logger.WriteLine(Pad + '  Spare now: %d %s', [ FSpare[R.Output.Name], R.Output.Name ]);
      end;
  end;

begin
  Level := 0;
  CountReaction(FReactions['FUEL'], Amount);
  Use('FUEL', Amount);
end;

function TTask_AoC.CostOfOneFuel: Integer;
begin
  if FCostOfOneFuel > 0 then
    Exit(FCostOfOneFuel);

  LoggerEnabled := True;

  FSpare := TIngridients.Create;
  FUsed := TIngridients.Create;
  try
    ProduceFuel;
    FCostOfOneFuel := FUsed['ORE'];
    Result := FCostOfOneFuel;
  finally
    FSpare.Free;
    FUsed.Free;
  end;
end;

function TTask_AoC.MaxFuelCount(const OreAmount: Int64): Integer;
var
  Amount: Integer;
begin
  LoggerEnabled := False;

  FSpare := TIngridients.Create;
  FUsed := TIngridients.Create;
  FUsed.Add('ORE', 0);
  try
    Result := 0;

    // Roughly estimate minimal amount of fuel
    while OreAmount - FUsed['ORE'] > CostOfOneFuel * 4 do
      begin
        Amount := ((OreAmount - FUsed['ORE']) div CostOfOneFuel) shr 1;
        repeat
          ProduceFuel(Amount);
          Inc(Result, Amount);
          Amount := Amount shr 1;
        until Amount = 0;
      end;

    // Precisely count last drops
    while FUsed['ORE'] < OreAmount do
      begin
        ProduceFuel;
        if FUsed['ORE'] <= OreAmount then
          Inc(Result);
      end;
  finally
    FSpare.Free;
    FUsed.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 14, 'Space Stoichiometry');

finalization
  GTask.Free;

end.
