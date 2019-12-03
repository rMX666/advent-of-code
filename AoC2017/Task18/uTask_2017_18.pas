unit uTask_2017_18;

interface

uses
  System.Generics.Collections, uTask;

type
  TRegisters = TDictionary<Char,Int64>;
  TCommand = reference to function (var Index: Integer; const Part: Integer): Boolean;

  TProgram = class (TList<TCommand>)
  private
    FSnd: Int64;
    FIndex: Integer;
    FRegisters: TRegisters;
    FPartner: TProgram;
    FQueue: TQueue<Int64>;
    FWaiting: Boolean;
    function GetReg(const Name: Char): Int64;
    procedure SetReg(const Name: Char; const Value: Int64);
    function GetCommand(const S: String): TCommand;
    function ValOrReg(const S: String): Int64;
    function Step(const Part: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    function RunProgram(const Part: Integer): Int64;
    procedure AddCommand(const S: String);
    property Reg[const Name: Char]: Int64 read GetReg write SetReg;
    property Partner: TProgram read FPartner write FPartner;
  end;

  TTask_AoC = class (TTask)
  private
    FPrograms: TArray<TProgram>;
    procedure LoadCommands;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TProgram }

procedure TProgram.AddCommand(const S: String);
begin
  Add(GetCommand(S));
end;

constructor TProgram.Create;
begin
  inherited Create;
  FRegisters := TRegisters.Create;
  FQueue := TQueue<Int64>.Create;
end;

destructor TProgram.Destroy;
begin
  FRegisters.Free;
  FQueue.Free;
  inherited;
end;

function TProgram.Step(const Part: Integer): Boolean;
begin
  Result := True;

  if (FIndex < 0) or (FIndex >= Count) then
    Exit(False);

  if not Items[FIndex](FIndex, Part) then
    Exit(False);
end;

procedure TProgram.Reset;
begin
  FRegisters.Clear;
  FIndex := 0;
  FSnd := 0;
  FWaiting := False;
end;

function TProgram.RunProgram(const Part: Integer): Int64;
begin
  Reset;
  if Assigned(FPartner) then
    Partner.Reset;

  while Step(Part) and Partner.Step(Part) do;

  Result := FSnd div 2;
end;

function TProgram.GetCommand(const S: String): TCommand;
var
  A: TArray<String>;
begin
  A := S.Split([' ']);

  if A[0] = 'set' then
    Result := function (var Index: Integer; const Part: Integer): Boolean
      begin
        Result := True;
        Reg[A[1][1]] := ValOrReg(A[2]);
        Inc(Index);
      end
  else if A[0] = 'add' then
    Result := function (var Index: Integer; const Part: Integer): Boolean
      begin
        Result := True;
        Reg[A[1][1]] := Reg[A[1][1]] + ValOrReg(A[2]);
        Inc(Index);
      end
  else if A[0] = 'mul' then
    Result := function (var Index: Integer; const Part: Integer): Boolean
      begin
        Result := True;
        Reg[A[1][1]] := Reg[A[1][1]] * ValOrReg(A[2]);
        Inc(Index);
      end
  else if A[0] = 'mod' then
    Result := function (var Index: Integer; const Part: Integer): Boolean
      begin
        Result := True;
        Reg[A[1][1]] := Reg[A[1][1]] mod ValOrReg(A[2]);
        Inc(Index);
      end
  else if A[0] = 'jgz' then
    Result := function (var Index: Integer; const Part: Integer): Boolean
      begin
        Result := True;
        if ValOrReg(A[1]) > 0 then
          Inc(Index, ValOrReg(A[2]))
        else
          Inc(Index);
      end
  else if A[0] = 'snd' then
    Result := function (var Index: Integer; const Part: Integer): Boolean
      begin
        Result := True;
        case Part of
          1:
            FSnd := ValOrReg(A[1]);
          2:
            begin
              FPartner.FQueue.Enqueue(ValOrReg(A[1]));
              FPartner.FWaiting := False;
              Inc(FSnd);
            end;
        end;
        Inc(Index);
      end
  else if A[0] = 'rcv' then
    Result := function (var Index: Integer; const Part: Integer): Boolean
      begin
        Result := True;
        case Part of
          1:
            if ValOrReg(A[1]) <> 0 then
              Result := False;
          2:
            if FQueue.Count = 0 then
              begin
                FWaiting := True;
                Exit(not FPartner.FWaiting);
              end
            else
              Reg[A[1][1]] := FQueue.Dequeue;
        end;
        Inc(Index);
      end;
end;

function TProgram.GetReg(const Name: Char): Int64;
begin
  if not FRegisters.ContainsKey(Name) then
    FRegisters.Add(Name, 0);
  Result := FRegisters[Name];
end;

procedure TProgram.SetReg(const Name: Char; const Value: Int64);
begin
  if not FRegisters.ContainsKey(Name) then
    FRegisters.Add(Name, Value)
  else
    FRegisters[Name] := Value;
end;

function TProgram.ValOrReg(const S: String): Int64;
begin
  if CharInSet(S[1], ['-', '0'..'9']) then
    Result := S.ToInt64
  else
    Result := Reg[S[1]];
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  SetLength(FPrograms, 2);
  FPrograms[0] := TProgram.Create;
  FPrograms[1] := TProgram.Create;
  FPrograms[0].Partner := FPrograms[1];
  FPrograms[1].Partner := FPrograms[0];
  try
    LoadCommands;

    OK('Part 1: %d, Part 2: %d', [ FPrograms[0].RunProgram(1), FPrograms[0].RunProgram(2) ]);
  finally
    FPrograms[0].Free;
    FPrograms[1].Free;
  end;
end;

procedure TTask_AoC.LoadCommands;
var
  I, J: Integer;
begin
  with Input do
    try
      for I := 0 to Count - 1 do
        for J := 0 to 1 do
          FPrograms[J].AddCommand(Strings[I]);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 18, 'Duet');

finalization
  GTask.Free;

end.
