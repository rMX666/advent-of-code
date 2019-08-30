unit uTask_2017_25;

interface

uses
  System.Generics.Collections, uTask;

type
  TStateAction = reference to function: Char;
  TStates = TDictionary<Char,TStateAction>;

  TTape = class
  strict private const
    INT_SIZE: Byte = SizeOf(Integer) * 8;
  private
    FIndex: Integer;
    FSize: Integer;
    FTape: TArray<Integer>;
    procedure GrowLeft;
    procedure GrowRight;
  public
    constructor Create;
    function Read(const Index: Integer = -1): Boolean;
    procedure Write(const B: Boolean);
    procedure Move(const D: Boolean);
    property Size: Integer read FSize;
    property Bit[const Index: Integer]: Boolean read Read; default;
  end;

  TTask_AoC = class (TTask)
  private
    FInitialState: Char;
    FStepCount: Integer;
    FStates: TStates;
    FTape: TTape;
    procedure InitializeStates;
    function RunMachine: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Classes;

var
  GTask: TTask_AoC;

{ TTape }

constructor TTape.Create;
begin
  FIndex := 0;
  FSize := INT_SIZE;
  SetLength(FTape, 1);
  FTape[0] := 0;
end;

procedure TTape.GrowLeft;
begin
  Insert(0, FTape, 0);
  FIndex := INT_SIZE - 1;
  Inc(FSize, INT_SIZE);
end;

procedure TTape.GrowRight;
begin
  if FSize mod INT_SIZE = 0 then
    SetLength(FTape, Length(FTape) + 1);

  Inc(FSize)
end;

procedure TTape.Move(const D: Boolean);
begin
  // True = Left, False = Right
  if D then
    begin
      if FIndex > 0 then
        Dec(FIndex)
      else
        GrowLeft;
    end
  else
    begin
      if FIndex < FSize then
        Inc(FIndex)
      else
        GrowRight;
    end;
end;

function TTape.Read(const Index: Integer): Boolean;
var
  I, ArrIndex, BitIndex: Integer;
begin
  if Index = -1 then
    I := FIndex
  else
    I := Index;

  ArrIndex := I div INT_SIZE;
  BitIndex := I mod INT_SIZE;

  Result := (FTape[ArrIndex] shr BitIndex) and 1 = 1;
end;

procedure TTape.Write(const B: Boolean);
var
  ArrIndex, BitIndex: Integer;
begin
  ArrIndex := FIndex div INT_SIZE;
  BitIndex := FIndex mod INT_SIZE;

  if B then
    FTape[ArrIndex] := 1 shl BitIndex or FTape[ArrIndex]
  else
    FTape[ArrIndex] := not (1 shl BitIndex) and FTape[ArrIndex];
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    FTape := TTape.Create;
    InitializeStates;

    OK(Format('Result: %d', [ RunMachine ]));
  finally
    FStates.Free;
    FTape.Free;
  end;
end;

procedure TTask_AoC.InitializeStates;
var
  I: Integer;
  InputList: TStrings;

  procedure ParseState;
  var
    Name: Char;
    IfFalseVal, IfFalseMov, IfTrueVal, IfTrueMov: Boolean; // Mov - False = Right, True = Left
    IfFalseState, IfTrueState: Char;
  begin
    with InputList do
      begin
        Name         := Strings[I].Split([' '])[2][1];            {|} Inc(I, 2);
        //
        IfFalseVal   := Strings[I].Trim.Split([' '])[4][1] = '1'; {|} Inc(I);
        IfFalseMov   := Strings[I].Trim.Split([' '])[6][1] = 'l'; {|} Inc(I);
        IfFalseState := Strings[I].Trim.Split([' '])[4][1];       {|} Inc(I, 2);
        //
        IfTrueVal    := Strings[I].Trim.Split([' '])[4][1] = '1'; {|} Inc(I);
        IfTrueMov    := Strings[I].Trim.Split([' '])[6][1] = 'l'; {|} Inc(I);
        IfTrueState  := Strings[I].Trim.Split([' '])[4][1];       {|} Inc(I, 2);
      end;

    FStates.Add(Name, function: Char
      begin
        if FTape.Read then
          begin
            FTape.Write(IfTrueVal);
            FTape.Move(IfTrueMov);
            Result := IfTrueState;
          end
        else
          begin
            FTape.Write(IfFalseVal);
            FTape.Move(IfFalseMov);
            Result := IfFalseState;
          end;
      end);
  end;

begin
  FStates := TStates.Create;
  InputList := Input;
  with InputList do
    try
      FInitialState := Strings[0].Split([' '])[3][1];
      FStepCount := Strings[1].Split([' '])[5].ToInteger;

      I := 3;
      while I < Count do
        ParseState;
    finally
      Free;
    end;
end;

function TTask_AoC.RunMachine: Integer;
var
  I: Integer;
  State: Char;
begin
  State := FInitialState;
  for I := 1 to FStepCount do
    State := FStates[State]();

  Result := 0;
  for I := 0 to FTape.Size - 1 do
    if FTape[I] then
      Inc(Result);
end;

initialization
  GTask := TTask_AoC.Create(2017, 25, 'The Halting Problem');

finalization
  GTask.Free;

end.
