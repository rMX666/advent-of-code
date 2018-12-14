unit uTask_2015_07;

interface

uses
  uTask, System.SysUtils, System.Generics.Collections;

type
  ENotFound = Exception;

  TOperand = ( otNone, otValue, otWire );
  TGate = ( gtNone, gtNot, gtAnd, gtOr, gtRShift, gtLShift );

  PInstruction = ^TInstruction;
  TInstruction = record
    Owner: TObject;
    OpA, OpB, Output: String;
    OpAType, OpBType: TOperand;
    Gate: TGate;
    IOpA, IOpB: Integer;
    constructor Create(const AOwner: TObject; const AOpA, AOpB, AOutput: String; AOpAType, AOpBType: TOperand; AGate: TGate);
    function Run: Integer;
    function GetOpA: Integer;
    function GetOpB: Integer;
  end;

  TWires = TDictionary<String, PInstruction>;

  TTask_AoC = class (TTask)
  private
    FWires: TWires;
    procedure InitializeWires;
  protected
    procedure DoRun; override;
  end;

implementation

const
  E_OPERAND_NOT_FOUND = 'Operand: "%s" - not found';
  E_GATE_NOT_FOUND = 'Gate not found for operands: "%s" and "%s"';

var
  GTask: TTask_AoC;

{ TInstruction }

constructor TInstruction.Create(const AOwner: TObject; const AOpA, AOpB, AOutput: String; AOpAType, AOpBType: TOperand; AGate: TGate);
begin
  Owner := AOwner;
  OpA := AOpA;
  OpB := AOpB;
  Output := AOutput;
  OpAType := AOpAType;
  OpBType := AOpBType;
  Gate := AGate;

  IOpA := -1;
  IOpB := -1;
end;

function TInstruction.GetOpA: Integer;
begin
  if OpAType = otNone then
    raise ENotFound.CreateFmt(E_OPERAND_NOT_FOUND, [ OpA ]);

  if IOpA = -1 then
    case OpAType of
      otValue:
        IOpA := StrToInt(OpA);
      otWire:
        IOpA := TWires(Owner)[OpA].Run;
    end;

  Result := IOpA;
end;

function TInstruction.GetOpB: Integer;
begin
  if OpBType = otNone then
    raise ENotFound.CreateFmt(E_OPERAND_NOT_FOUND, [ OpB ]);

  if IOpB = -1 then
    case OpBType of
      otValue:
        IOpB := StrToInt(OpB);
      otWire:
        IOpB := TWires(Owner)[OpB].Run;
    end;

  Result := IOpB;
end;

function TInstruction.Run: Integer;
begin
  Result := -1;
  case Gate of
    gtNone:
      if OpBType = otNone then
        Result := GetOpA
      else
        raise ENotFound.CreateFmt(E_GATE_NOT_FOUND, [ OpA, OpB ]);
    gtNot:
      if OpBType = otNone then
        Result := not GetOpA
      else
        raise ENotFound.CreateFmt(E_GATE_NOT_FOUND, [ OpA, OpB ]);
    gtAnd:
      Result := GetOpA and GetOpB;
    gtOr:
      Result := GetOpA or GetOpB;
    gtRShift:
      Result := GetOpA shr GetOpB;
    gtLShift:
      Result := GetOpA shl GetOpB;
  end;
end;

{ TTask_AoC }

procedure TTask_AoC.InitializeWires;

  function GetOperandType(const Op: String): TOperand;
  begin
    Result := otNone;
    if Op.Length = 0 then
      Exit;

    if CharInSet(Op[1], [ '0' .. '9' ]) then
      Result := otValue
    else if CharInSet(Op[1], [ 'a' .. 'z' ]) then
      Result := otWire;
  end;

  procedure ParseWire(const S: String);
  var
    A: TArray<String>;
    OpA, OpB, Output: String;
    OpAType, OpBType: TOperand;
    Gate: TGate;
    Instruction: PInstruction;
  begin
    A := S.Split([' ']);
    Output := A[Length(A) - 1];
    OpBType := otNone;
    Gate := gtNone;

    if Length(A) in [ 3, 4 ] then
      begin
        OpA := A[0];

        if OpA = 'NOT' then
          begin
            Gate := gtNot;
            OpA := A[1];
          end;

        OpAType := GetOperandType(OpA);
      end
    else
      begin
        OpA := A[0];
        OpB := A[2];
        OpAType := GetOperandType(OpA);
        OpBType := GetOperandType(OpB);

        if A[1] = 'AND' then
          Gate := gtAnd
        else if A[1] = 'OR' then
          Gate := gtOr
        else if A[1] = 'LSHIFT' then
          Gate := gtLShift
        else if A[1] = 'RSHIFT' then
          Gate := gtRShift;
      end;

    New(Instruction);
    Instruction^ := TInstruction.Create(FWires, OpA, OpB, Output, OpAType, OpBType, Gate);

    FWires.Add(Output, Instruction);
  end;

var
  I: Integer;
begin
  FWires := TWires.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        ParseWire(Strings[I]);
    finally
      Free;
    end;
end;

procedure TTask_AoC.DoRun;
var
  Part1: Integer;
  Part2: Integer;
begin
  try
    InitializeWires;
    Part1 := FWires['a'].Run;

    InitializeWires;
    FWires['b'].IOpA := Part1;
    Part2 := FWires['a'].Run;

    Ok(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
  finally
    FWires.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 7, 'Some Assembly Required');

finalization
  GTask.Free;

end.
