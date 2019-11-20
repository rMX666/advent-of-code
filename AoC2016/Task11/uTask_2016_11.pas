unit uTask_2016_11;

interface

uses
  System.Generics.Collections, uTask, uSet_2016_11;

type


  TFloor = record
  private
    FRaw: Integer;
    function GetItem(const Name: TItemName; const ItemType: TItemType): Boolean;
    procedure SetItem(const Name: TItemName; const ItemType: TItemType; const Value: Boolean);
    function GetItemCount(const ItemType: TItemType): Integer;
  public
    class operator Explicit(const A: Integer): TFloor;
    class operator Implicit(const A: TFloor): Integer;
    function PairCount: Integer;
    function MicrochipCount: Integer;
    function GeneratorCount: Integer;
    property Item[const Name: TItemName; const ItemType: TItemType]: Boolean read GetItem write SetItem; default;
  end;

  TState = packed record
  public const
    LOW = 1;
    HIGH = 4;
  public type
    TStateArray = array [LOW..HIGH] of Integer; // TFloor
  private
    FState: TStateArray;
    FFloor: Integer;
    FMoveCount: Integer;
    function GetFloor(const Index: Integer): TFloor;
    function GetItem(const Floor: Integer; const ItemName: TItemName; const ItemType: TItemType): Boolean;
    procedure SetItem(const Floor: Integer; const ItemName: TItemName; const ItemType: TItemType; const Value: Boolean);
    function GetCurrentSets(const ItemType: TItemType): TItemNamesEx;
    function GetSets(const Floor: Integer; const ItemType: TItemType): TItemNamesEx;
  public
    constructor Create(const A, B, C, D: Integer); overload;
    constructor Create(const State: TState); overload;
    class operator Equal(const A, B: TState): Boolean;
    class operator LessThan(const A, B: TState): Boolean;
    class operator GreaterThan(const A, B: TState): Boolean;
    property Floors[const Index: Integer]: TFloor read GetFloor;
    property Items[const Floor: Integer; const ItemName: TItemName; const ItemType: TItemType]: Boolean read GetItem write SetItem;
    property CurrentSets[const ItemType: TItemType]: TItemNamesEx read GetCurrentSets;
    property Sets[const Floor: Integer; const ItemType: TItemType]: TItemNamesEx read GetSets;
    property MoveCount: Integer read FMoveCount;
    property Floor: Integer read FFloor write FFloor;
    function IsFinalState: Boolean;
    function TryMove(const DFloor: Integer; const ItemType: TItemType; const ItemName: TItemName): Boolean;
  end;

  TTask_AoC = class (TTask)
  private
    FInitialState: TState;
    procedure LoadInitialState;
    function GetInitialState(const Part: Integer): TState;
    function Steps(const Part: Integer): Integer;
    function Moves(const State: TState): TArray<TState>;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.RegularExpressions, System.Generics.Defaults, Generics.PriorityQueue, uUtil;

var
  GTask: TTask_AoC;

{ TFloor }

class operator TFloor.Explicit(const A: Integer): TFloor;
begin
  Result.FRaw := A;
end;

class operator TFloor.Implicit(const A: TFloor): Integer;
begin
  Result := A.FRaw;
end;

function TFloor.GetItemCount(const ItemType: TItemType): Integer;
begin
  Result := BitCount((FRaw shl Integer(ItemType)) and $55555555);
end;

function TFloor.GeneratorCount: Integer;
begin
  Result := GetItemCount(itGenerator);
end;

function TFloor.MicrochipCount: Integer;
begin
  Result := GetItemCount(itMicrochip);
end;

function TFloor.GetItem(const Name: TItemName; const ItemType: TItemType): Boolean;
var
  BitNumber: Integer;
begin
  BitNumber := Integer(Name) + Integer(ItemType);
  Result := (FRaw shr BitNumber) and 1 = 1;
end;

function TFloor.PairCount: Integer;
var
  I: TItemName;
begin
  Result := 0;
  for I := Low(TItemName) to High(TItemName) do
    if Item[I, itMicrochip] and Item[I, itGenerator] then
      Inc(Result);
end;

procedure TFloor.SetItem(const Name: TItemName; const ItemType: TItemType; const Value: Boolean);
var
  BitNumber: Integer;
begin
  BitNumber := Integer(Name) + Integer(ItemType);
  //           First unset bit in FRaw      then either enable or disable the bit
  FRaw := FRaw and not (1 shl BitNumber) or (Integer(Value) shl BitNumber);
end;

{ TState }

constructor TState.Create(const A, B, C, D: Integer);
begin
  FMoveCount := 0;
  FFloor := LOW;
  FState[LOW + 0] := A;
  FState[LOW + 1] := B;
  FState[LOW + 2] := C;
  FState[LOW + 3] := D;
end;

constructor TState.Create(const State: TState);
begin
  FState := State.FState;
  FFloor := State.FFloor;
  FMoveCount := State.FMoveCount + 1;
end;

class operator TState.Equal(const A, B: TState): Boolean;
var
  I: Integer;
begin
  Result := A.FFloor = B.FFloor;
  if Result then
    for I := LOW to HIGH do
      begin
        // Each floor should have same amount of chips and gens - either paired or unpaired
        if (A.Floors[I].MicrochipCount <> B.Floors[I].MicrochipCount) or (A.Floors[I].GeneratorCount <> B.Floors[I].GeneratorCount) then
          Exit(False);
        // Each floor should have same amount of (chip, gen) pairs
        if A.Floors[I].PairCount <> B.Floors[I].PairCount then
          Exit(False);
      end;
end;

class operator TState.GreaterThan(const A, B: TState): Boolean;
var
  I: Integer;
begin
  Result := A.FMoveCount > B.MoveCount;
  if Result then
    for I := HIGH downto LOW do
      begin
        if A.Floors[I].MicrochipCount + A.Floors[I].GeneratorCount < B.Floors[I].MicrochipCount + B.Floors[I].GeneratorCount then
          Exit(False);
        if A.Floors[I].PairCount < B.Floors[I].PairCount then
          Exit(False);
      end;
end;

class operator TState.LessThan(const A, B: TState): Boolean;
var
  I: Integer;
begin
  Result := A.FMoveCount < B.MoveCount;
  if Result then
    for I := HIGH downto LOW do
      begin
        if A.Floors[I].MicrochipCount + A.Floors[I].GeneratorCount > B.Floors[I].MicrochipCount + B.Floors[I].GeneratorCount then
          Exit(False);
        if A.Floors[I].PairCount > B.Floors[I].PairCount then
          Exit(False);
      end;
end;

function TState.TryMove(const DFloor: Integer; const ItemType: TItemType; const ItemName: TItemName): Boolean;
begin
  if not (FFloor + DFloor in [LOW..HIGH]) then
    Exit(False);

  Items[FFloor,          ItemName, ItemType] := False;
  Items[FFloor + DFloor, ItemName, ItemType] := True;
  Result := True;
end;

function TState.GetFloor(const Index: Integer): TFloor;
begin
  if (Index < LOW) or (Index > HIGH) then
    raise Exception.Create('Wrong floor');
  Result := TFloor(FState[Index]);
end;

function TState.GetItem(const Floor: Integer; const ItemName: TItemName; const ItemType: TItemType): Boolean;
begin
  Result := Self.Floors[Floor].Item[ItemName, ItemType];
end;

function TState.GetSets(const Floor: Integer; const ItemType: TItemType): TItemNamesEx;
var
  I: TItemName;
begin
  Result := [];
  I := System.Low(TItemName);
  while I <= System.High(TItemName) do
    begin
      if Items[Floor, I, ItemType] then
        Result.Add(I);
      I := TItemName(Integer(I) + 2);
    end;
end;

function TState.GetCurrentSets(const ItemType: TItemType): TItemNamesEx;
begin
  Result := Sets[FFloor, ItemType];
end;

function TState.IsFinalState: Boolean;
var
  I: Integer;
begin
  Result := FState[HIGH] <> 0;
  for I := LOW to HIGH - 1 do
    if FState[I] <> 0 then
      Exit(False);
end;

procedure TState.SetItem(const Floor: Integer; const ItemName: TItemName; const ItemType: TItemType;
  const Value: Boolean);
var
  F: TFloor;
begin
  F := Self.Floors[Floor];
  F.Item[ItemName, ItemType] := Value;
  FState[Floor] := F;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadInitialState;
  OK(Format('Part 1: %d, Part 2: %d', [ Steps(1), Steps(2) ]));
end;

procedure TTask_AoC.LoadInitialState;

  function StrToItemName(const S: String): TItemName;
  begin
    Result := inCobalt;
    if      S = 'cobalt'     then Result := inCobalt
    else if S = 'dilithium'  then Result := inDilithium
    else if S = 'elerium'    then Result := inElerium
    else if S = 'polonium'   then Result := inPolonium
    else if S = 'promethium' then Result := inPromethium
    else if S = 'ruthenium'  then Result := inRuthenium
    else if S = 'thulium'    then Result := inThulium;
  end;

  procedure ParseWithRegexp(const FloorNumber: Integer; const S, Regexp: String; const ItemType: TItemType);
  var
    Match: TMatch;
  begin
    Match := TRegEx.Match(S, Regexp);
    while Match.Success do
      begin
        FInitialState.Items[FloorNumber, StrToItemName(Match.Groups[1].Value), ItemType] := True;
        Match := Match.NextMatch;
      end;
  end;

  procedure ParseLine(const Floor: Integer; const S: String);
  const
    MICROCHIPS_REGEXP = '([a-z]+)-compatible microchip';
    GENERATORS_REGEXP = '([a-z]+) generator';
  begin
    ParseWithRegexp(Floor, S, MICROCHIPS_REGEXP, itMicrochip);
    ParseWithRegexp(Floor, S, GENERATORS_REGEXP, itGenerator);
  end;

var
  I: Integer;
begin
  FInitialState := TState.Create(0, 0, 0, 0);

  with Input do
    try
      for I := 0 to Count - 1 do
        ParseLine(I + 1, Strings[I]);
    finally
      Free;
    end;
end;

function TTask_AoC.GetInitialState(const Part: Integer): TState;
begin
  Result := TState.Create(FInitialState);

  if Part = 2 then
    begin
      Result.Items[TState.LOW, inElerium, itMicrochip] := True;
      Result.Items[TState.LOW, inElerium, itGenerator] := True;
      Result.Items[TState.LOW, inDilithium, itMicrochip] := True;
      Result.Items[TState.LOW, inDilithium, itGenerator] := True;
    end;
end;

function TTask_AoC.Moves(const State: TState): TArray<TState>;
var
  Chips, Gens, Paired, UnpairedChips, UnpairedGens: TItemNamesEx;

  function TryAddMoves(const Direction: Integer): TArray<TState>;
  type
    TItem = TPair<TItemType, TItemName>;
    TItems = TList<TItem>;
  var
    Next: TState;
    MoveSets: TObjectList<TItems>;
    NextChips, NextGens: TItemNamesEx;
    I, J: Integer;
    ItemArr: TArray<TItemName>;
    SubSeq: TSubSequences<TItemName>;

    procedure TryMoveChips(const Chips, NextGens: TItemNamesEx);
    var
      I: Integer;
      Items: TItems;
    begin
      Items := TItems.Create;
      try
        for I := 0 to Chips.Count - 1 do
          // Next floor contains generator or next floor does not contain generators
          if NextGens.Contains(Chips[I]) or (NextGens = []) then
            Items.Add(TItem.Create(itMicrochip, Chips[I]));
      finally
        if Items.Count > 0 then
          MoveSets.Add(Items)
        else
          Items.Free;
      end;
    end;

    procedure TryMoveGens(const Gens, NextChips: TItemNamesEx);
    var
      I: Integer;
      Items: TItems;
    begin
      Items := TItems.Create;
      try
        // Next floor contains only same chips as generators or no chips at all
        if (Gens = NextChips) or (NextChips = []) then
          for I := 0 to Gens.Count - 1 do
            Items.Add(TItem.Create(itGenerator, Gens[I]));
      finally
        if Items.Count > 0 then
          MoveSets.Add(Items)
        else
          Items.Free;
      end;
    end;

  begin
    SetLength(Result, 0);

    if not (State.FFloor + Direction in [TState.LOW..TState.HIGH]) then
      Exit;

    NextChips := State.Sets[State.Floor + Direction, itMicrochip];
    NextGens  := State.Sets[State.Floor + Direction, itGenerator];

    MoveSets := TObjectList<TItems>.Create;
    try
      if Paired.Count > 0 then
        begin
          MoveSets.Add(TItems.Create);
          MoveSets.Last.Add(TItem.Create(itMicrochip, Paired[0]));
          MoveSets.Last.Add(TItem.Create(itGenerator, Paired[0]));

          TryMoveChips(TItemNamesEx(Copy(Paired.ToArray, 0, 1)), NextGens);
          TryMoveChips(TItemNamesEx(Copy(Paired.ToArray, 0, 2)), NextGens);

          if UnpairedGens.Count = 0 then
            begin
              TryMoveGens(TItemNamesEx(Copy(Paired.ToArray, 0, 1)), NextChips);
              TryMoveGens(TItemNamesEx(Copy(Paired.ToArray, 0, 2)), NextChips);
            end;
        end;

      case UnpairedChips.Count of
        0: ; // Skip
        1, 2:
          TryMoveChips(UnpairedChips, NextGens);
        else
          begin
            SubSeq := TSubSequences<TItemName>.Create(UnpairedChips.ToArray, 2, 2);
            try
              for ItemArr in SubSeq do
                TryMoveChips(TItemNamesEx(ItemArr), NextGens);
            finally
              SubSeq.Free;
            end;
          end;
      end;

      case UnpairedGens.Count of
        0: ; // Skip
        1, 2:
          TryMoveGens(UnpairedGens, NextChips);
        else
          begin
            SubSeq := TSubSequences<TItemName>.Create(UnpairedGens.ToArray, 2, 2);
            try
              for ItemArr in SubSeq do
                TryMoveGens(TItemNamesEx(ItemArr), NextChips);
            finally
              SubSeq.Free;
            end;
          end;
      end;

      for I := 0 to MoveSets.Count - 1 do
        begin
          Next := TState.Create(State);
          for J := 0 to MoveSets[I].Count - 1 do
            with MoveSets[I][J] do
              Next.TryMove(Direction, Key, Value);
          Next.Floor := Next.Floor + Direction;
          System.Insert(Next, Result, 0);
        end;
    finally
      MoveSets.Free;
    end;
  end;

begin
  Chips := State.CurrentSets[itMicrochip];
  Gens := State.CurrentSets[itGenerator];

  Paired := Chips * Gens;
  UnpairedChips := Chips - Paired;
  UnpairedGens  := Gens - Paired;

  Result := Concat(TryAddMoves(1), TryAddMoves(-1));
end;

function TTask_AoC.Steps(const Part: Integer): Integer;
type
  TPQueue = TPriorityQueue<TState>;
var
  State: TState;
  Queue, Visited: TPQueue;
  I: Integer;
  M: TArray<TState>;
begin
  Result := 0;
  State := GetInitialState(Part);
  Queue := TPQueue.Create(TDelegatedComparer<TState>.Construct(function (const A, B: TState): Integer
    begin
      Result := 1;
      if A = B then
        Result := 0
      else if A < B then
        Result := -1;
    end));
  // No removals
  Visited := Queue.Clone;
  try
    Queue.Push(State);
    Visited.Push(State);

    while not Queue.IsEmpty do
      begin
        M := Moves(Queue.Pop);
        for I := 0 to Length(M) - 1 do
          begin
            if M[I].MoveCount > 100 then
              Continue;
            if M[I].IsFinalState then
              Exit(M[I].MoveCount - 1);
            if not Queue.Contains(M[I]) and not Visited.Contains(M[I]) then
              begin
                Queue.Push(M[I]);
                Visited.Push(M[I]);
              end;
          end;
      end;
  finally
    Queue.Free;
    Visited.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 11, 'Radioisotope Thermoelectric Generators');

finalization
  GTask.Free;

end.
