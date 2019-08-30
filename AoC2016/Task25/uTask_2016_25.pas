unit uTask_2016_25;

interface

uses
  System.Classes, System.Generics.Collections, uTask;

type
  TInstructionType = ( itNone, itCpy, itInc, itDec, itJnz, itTgl, itOut );

  PInstruction = ^TInstruction;
  TInstruction = record
    InstructionType: TInstructionType;
    Vx, Vy: Integer;
    Rx, Ry: Char;
    constructor Create(const S: String);
    class function Pointer(const S: String): PInstruction; static;
    function IsRegisterX: Boolean;
    function IsRegisterY: Boolean;
  end;

  TRegisters = TDictionary<Char,Int64>;
  TProgram = class(TList<PInstruction>)
  public
    destructor Destroy; override;
    procedure Clear;
  end;

  TProcessor = class
  public type
    TOnExecuteInstruction = procedure (Processor: TProcessor; var Allow: Boolean) of object;
  private
    FRegisters: TRegisters;
    FProgram: TProgram;
    FIndex: Integer;
    FOutput: String;
    FOnExecuteInstruction: TOnExecuteInstruction;
    function ExecuteInstruction: Boolean;
    function GetRegister(const Index: Integer): Int64;
    procedure SetRegister(const Index: Integer; const Value: Int64);
    procedure DoOnExecuteInstruction(var Allow: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddInstruction(const Instruction: String);
    procedure Execute;
    procedure Reset;
    property RegisterA: Int64 index 0 read GetRegister write SetRegister;
    property RegisterB: Int64 index 1 read GetRegister write SetRegister;
    property RegisterC: Int64 index 2 read GetRegister write SetRegister;
    property RegisterD: Int64 index 3 read GetRegister write SetRegister;
    property OnExecuteInstruction: TOnExecuteInstruction read FOnExecuteInstruction write FOnExecuteInstruction;
  end;

  TTask_AoC = class (TTask)
  private const
    REF_SIGNAL: String = '0101010101010101';
  private
    FProcessor: TProcessor;
    procedure LoadInput;
    procedure OnInstruction(Processor: TProcessor; var Allow: Boolean);
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
    end
  else if A[0] = 'tgl' then
    begin
      InstructionType := itTgl;
      SetXY(A[1], '0');
    end
  else if A[0] = 'out' then
    begin
      InstructionType := itOut;
      SetXY(A[1], '0');
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

class function TInstruction.Pointer(const S: String): PInstruction;
begin
  New(Result);
  Result^ := TInstruction.Create(S);
end;

{ TProcessor }

procedure TProcessor.AddInstruction(const Instruction: String);
begin
  FProgram.Add(TInstruction.Pointer(Instruction));
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

procedure TProcessor.DoOnExecuteInstruction(var Allow: Boolean);
begin
  if Assigned(FOnExecuteInstruction) then
    FOnExecuteInstruction(Self, Allow);
end;

procedure TProcessor.Reset;
begin
  FOutput := '';
  FRegisters.Clear;
  FRegisters.Add('a', 0);
  FRegisters.Add('b', 0);
  FRegisters.Add('c', 0);
  FRegisters.Add('d', 0);
  FIndex := 0;
  FProgram.Clear;
end;

function TProcessor.GetRegister(const Index: Integer): Int64;
begin
  Result := FRegisters[Char(Ord('a') + Index)];
end;

procedure TProcessor.SetRegister(const Index: Integer; const Value: Int64);
begin
  FRegisters[Char(Ord('a') + Index)] := Value;
end;

procedure TProcessor.Execute;
begin
  while ExecuteInstruction do;
end;

function TProcessor.ExecuteInstruction: Boolean;
var
  I, TI: PInstruction;
  X, Y: Int64;
begin
  I := FProgram[FIndex];

  try
    case I.InstructionType of
      itNone:
        raise EInvalidArgument.Create('Wrong instruction type');
      itCpy:
        if I.IsRegisterY then
          begin
            if I.IsRegisterX then
              FRegisters[I.Ry] := FRegisters[I.Rx]
            else
              FRegisters[I.Ry] := I.Vx;
          end;
      itInc:
        if I.IsRegisterX then
          FRegisters[I.Rx] := FRegisters[I.Rx] + 1;
      itDec:
        if I.IsRegisterX then
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
      itTgl:
        begin
          if I.IsRegisterX then X := FRegisters[I.Rx] else X := I.Vx;
          X := FIndex + X;
          if (X >= 0) and (X < FProgram.Count) then
            begin
              TI := FProgram[X];
              case TI.InstructionType of
                itInc: TI.InstructionType := itDec;
                itTgl,
                itDec: TI.InstructionType := itInc;
                itCpy: TI.InstructionType := itJnz;
                itJnz: TI.InstructionType := itCpy;
              end;
            end;
        end;
      itOut:
        begin
          if I.IsRegisterX then X := FRegisters[I.Rx] else X := I.Vx;
          FOutput := FOutput + X.ToString;
        end;
    end;

    Inc(FIndex);
  finally
    Result := (FIndex >= 0) and (FIndex < FProgram.Count);
    if Result then
      DoOnExecuteInstruction(Result);
  end;
end;

{ TProgram }

procedure TProgram.Clear;
var
  I: Integer;
  Instruction: PInstruction;
begin
  for I := 0 to Count - 1 do
    begin
      Instruction := Items[I];
      Dispose(Instruction);
    end;

  inherited Clear;
end;

destructor TProgram.Destroy;
begin
  Clear;
  inherited;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  I: Integer;
begin
  FProcessor := TProcessor.Create;
  try
    FProcessor.OnExecuteInstruction := OnInstruction;
    I := -1;
    repeat
      Inc(I);
      FProcessor.Reset;
      LoadInput;
      FProcessor.RegisterA := I;
      FProcessor.Execute;
    until FProcessor.FOutput.StartsWith(REF_SIGNAL);
    OK(Format('Part 1: %d', [ I ]));
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

procedure TTask_AoC.OnInstruction(Processor: TProcessor; var Allow: Boolean);
begin
  if FProcessor.FOutput.Length < REF_SIGNAL.Length then
    Exit;

  Allow := False;
end;

initialization
  GTask := TTask_AoC.Create(2016, 25, 'Clock Signal');

finalization
  GTask.Free;

end.
