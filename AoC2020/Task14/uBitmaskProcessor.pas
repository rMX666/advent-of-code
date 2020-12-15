unit uBitmaskProcessor;

interface

uses
  System.SysUtils, System.Generics.Collections, System.RegularExpressions;

type
  TInstructionType = ( itNone, itMask, itMem );
  TInstruction = record
  private
    function ParseMask(const S: String): Boolean;
    function ParseMem(const S: String): Boolean;
  public
    InstructionType: TInstructionType;
    Values: TArray<String>;
    constructor Create(const S: String);
  end;

  TBitmaskProcessor = class (TDictionary<Int64,Int64>)
  public const
    BITMASK_SIZE = 36;
  strict private type
    TBitState = ( wbNone, wbZero, wbOne );
    TBitMask = array [ 0 .. (BITMASK_SIZE - 1) ] of TBitState;
  private
    FBitMask: TBitMask;
  protected
    function ApplyMask(const Value: Int64): Int64;
    procedure SetBitMask(const Mask: String);
    procedure SetMem(const MemID, Value: Int64); virtual;
  public
    procedure ExecuteInstruction(const Instruction: TInstruction);
  end;

  TBitmaskProcessorV2 = class (TBitmaskProcessor)
  protected
    procedure SetMem(const MemID, Value: Int64); override;
  end;

implementation

{ TInstruction }

constructor TInstruction.Create(const S: String);
begin
  SetLength(Values, 0);
  InstructionType := itNone;

  if not (ParseMask(S) or ParseMem(S)) then
    raise Exception.CreateFmt('Incorrect instruction: %s', [ S ]);
end;

function TInstruction.ParseMask(const S: String): Boolean;
const
  RE_MASK = '^mask = ([01X]{36})$';
begin
  Result := True;

  with TRegEx.Match(S, RE_MASK) do
    begin
      if not Success then
        Exit(False);

      InstructionType := itMask;

      SetLength(Values, 1);
      Values[0] := Groups[1].Value;
    end;
end;

function TInstruction.ParseMem(const S: String): Boolean;
const
  RE_MEM  = '^mem\[([0-9]+)\] = ([0-9]+)$';
begin
  Result := True;

  with TRegEx.Match(S, RE_MEM) do
    begin
      if not Success then
        Exit(False);

      InstructionType := itMem;

      SetLength(Values, 2);
      Values[0] := Groups[1].Value;
      Values[1] := Groups[2].Value;
    end;
end;

{ TBitmaskProcessor }

function TBitmaskProcessor.ApplyMask(const Value: Int64): Int64;
var
  I: Integer;
begin
  Result := Value;
  for I := 0 to BITMASK_SIZE - 1 do
    case FBitMask[I] of
      wbZero: Result := Result and (not (Int64(1) shl I));
      wbOne:  Result := Result or (Int64(1) shl I);
    end;
end;

procedure TBitmaskProcessor.ExecuteInstruction(const Instruction: TInstruction);
begin
  with Instruction do
    case InstructionType of
      itMask:
        SetBitMask(Values[0]);
      itMem:
        SetMem(Values[0].ToInt64, Values[1].ToInt64)
    end;
end;

procedure TBitmaskProcessor.SetBitMask(const Mask: String);
var
  I: Integer;
begin
  for I := 1 to BITMASK_SIZE do
    case Mask[I] of
      'X': FBitMask[BITMASK_SIZE - I] := wbNone;
      '0': FBitMask[BITMASK_SIZE - I] := wbZero;
      '1': FBitMask[BITMASK_SIZE - I] := wbOne;
    end;
end;

procedure TBitmaskProcessor.SetMem(const MemID, Value: Int64);
begin
  AddOrSetValue(MemID, ApplyMask(Value));
end;

{ TBitmaskProcessorV2 }

procedure TBitmaskProcessorV2.SetMem(const MemID, Value: Int64);
var
  I, J, Amount: Integer;
begin
  with TList<Int64>.Create do
    try
      Add(MemID);
      Amount := 1;
      for I := 0 to BITMASK_SIZE - 1 do
        case FBitMask[I] of
          wbNone:
            begin
              for J := 0 to Count - 1 do
                Items[J] := Items[J] and (not (Int64(1) shl I));
              for J := 0 to Amount - 1 do
                Add(Items[J] or (Int64(1) shl I));
              Inc(Amount, Amount);
            end;
          wbOne:
            for J := 0 to Count - 1 do
              Items[J] := Items[J] or (Int64(1) shl I);
        end;

      for I := 0 to Count - 1 do
        Self.AddOrSetValue(Items[I], Value);
    finally
      Free;
    end;
end;

end.
