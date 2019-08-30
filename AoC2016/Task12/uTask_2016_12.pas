unit uTask_2016_12;

interface

uses
  System.Generics.Collections, uTask;

type
  TInstructionType = ( itNone, itCpy, itInc, itDec, itJnz );

  TInstruction = record
    InstructionType: TInstructionType;
    Vx, Vy: Integer;
    Rx, Ry: Char;
    constructor Create(const S: String);
    function IsRegisterX: Boolean;
    function IsRegisterY: Boolean;
  end;

  TRegisters = TDictionary<Char,Integer>;
  TProgram = TList<TInstruction>;

  TProcessor = class
  private
    FRegisters: TRegisters;
    FProgram: TProgram;
    FIndex: Integer;
    function ExecuteInstruction: Boolean;
    function GetRegister(const Index: Integer): Integer;
    procedure SetRegister(const Index, Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddInstruction(const Instruction: String);
    procedure Execute;
    procedure Reset;
    property RegisterA: Integer index 0 read GetRegister write SetRegister;
    property RegisterB: Integer index 1 read GetRegister write SetRegister;
    property RegisterC: Integer index 2 read GetRegister write SetRegister;
    property RegisterD: Integer index 3 read GetRegister write SetRegister;
  end;

  TTask_AoC = class (TTask)
  private
    FProcessor: TProcessor;
    procedure LoadInput;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TInstruction }

constructor TInstruction.Create(const S: String);

  procedure SetVal(const S: String; out V: Integer; out R: Char);
  begin
    if CharInSet(S[1], ['-', '0'..'9']) then
      begin
        R := #0;
        V := StrToInt(S);
      end
    else
      begin
        R := S[1];
        V := 0;
      end;
  end;

  procedure SetXY(const X, Y: String);
  begin
    SetVal(X, Vx, Rx);
    SetVal(Y, Vy, Ry);
  end;

var
  A: TArray<String>;
begin
  InstructionType := itNone;
  Rx := #0;
  Ry := #0;
  Vx := 0;
  Vy := 0;

  A := S.Split([' ']);
  if A[0] = 'cpy' then
    begin
      InstructionType := itCpy;
      SetXY(A[1], A[2]);
    end
  else if A[0] = 'inc' then
    begin
      InstructionType := itInc;
      SetXY(A[1], '0');
    end
  else if A[0] = 'dec' then
    begin
      InstructionType := itDec;
      SetXY(A[1], '0');
    end
  else if A[0] = 'jnz' then
    begin
      InstructionType := itJnz;
      SetXY(A[1], A[2]);
    end;
end;

function TInstruction.IsRegisterX: Boolean;
begin
  Result := Rx <> #0;
end;

function TInstruction.IsRegisterY: Boolean;
begin
  Result := Ry <> #0;
end;

{ TProcessor }

procedure TProcessor.AddInstruction(const Instruction: String);
begin
  FProgram.Add(TInstruction.Create(Instruction));
end;

constructor TProcessor.Create;
begin
  FRegisters := TRegisters.Create(4);
  FProgram := TProgram.Create;
  Reset;
end;

destructor TProcessor.Destroy;
begin
  FreeAndNil(FProgram);
  FreeAndNil(FRegisters);
  inherited;
end;

procedure TProcessor.Reset;
begin
  FRegisters.Clear;
  FRegisters.Add('a', 0);
  FRegisters.Add('b', 0);
  FRegisters.Add('c', 0);
  FRegisters.Add('d', 0);
  FIndex := 0;
end;

function TProcessor.GetRegister(const Index: Integer): Integer;
begin
  Result := FRegisters[Char(Ord('a') + Index)];
end;

procedure TProcessor.SetRegister(const Index, Value: Integer);
begin
  FRegisters[Char(Ord('a') + Index)] := Value;
end;

procedure TProcessor.Execute;
begin
  while ExecuteInstruction do;
end;

function TProcessor.ExecuteInstruction: Boolean;
var
  I: TInstruction;
  X, Y: Integer;
begin
  I := FProgram[FIndex];

  try
    case I.InstructionType of
      itNone:
        raise EInvalidArgument.Create('Wrong instruction type');
      itCpy:
        if I.IsRegisterX then
          FRegisters[I.Ry] := FRegisters[I.Rx]
        else
          FRegisters[I.Ry] := I.Vx;
      itInc:
        FRegisters[I.Rx] := FRegisters[I.Rx] + 1;
      itDec:
        FRegisters[I.Rx] := FRegisters[I.Rx] - 1;
      itJnz:
        begin
          if I.IsRegisterX then X := FRegisters[I.Rx] else X := I.Vx;
          if I.IsRegisterY then Y := FRegisters[I.Ry] else Y := I.Vy;

          if X <> 0 then
            begin
              Inc(FIndex, Y);
              Exit;
            end;
        end;
    end;

    Inc(FIndex);
  finally
    Result := (FIndex >= 0) and (FIndex < FProgram.Count);
  end;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  FProcessor := TProcessor.Create;

  try
    LoadInput;
    FProcessor.Execute;
    OK(Format('Part 1: %d', [ FProcessor.RegisterA ]));

    FProcessor.Reset;
    FProcessor.RegisterC := 1;
    FProcessor.Execute;
    OK(Format('Part 2: %d', [ FProcessor.RegisterA ]));
  finally
    FProcessor.Free;
  end;
end;

procedure TTask_AoC.LoadInput;
var
  I: Integer;
begin
  with Input do
    try
      for I := 0 to Count - 1 do
        FProcessor.AddInstruction(Strings[I]);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 12, 'Leonardo''s Monorail');

finalization
  GTask.Free;

end.
