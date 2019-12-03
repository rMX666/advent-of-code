unit uTask_2018_16;

interface

uses
  System.Generics.Collections, uTask;

type
  TOpType = ( otNone
            , otAddR, otAddI
            , otMulR, otMulI
            , otBAnR, otBAnI
            , otBOrR, otBOrI
            , otSetR, otSetI
            , otGtIR, otGtRI, otGtRR
            , otEqIR, otEqRI, otEqRR
            );

  TState = array [0..3] of Integer;

  TOp = record
    OpCode: Integer;
    A, B, C: Integer;
    constructor Create(const S: String);
    function Apply(const Before: TState; const OpType: TOpType): TState;
  end;

  TCapturedOp = record
    Before, After: TState;
    Op: TOp;
    BehavesLike: TArray<TOpType>;
    constructor Create(const ABefore, AOp, AAfter: String);
    procedure Match;
  end;

  TCapturedOps = TList<TCapturedOp>;
  TProgram = TList<TOp>;
  TOpCodeDictionary = TDictionary<Integer,TOpType>;

  TTask_AoC = class (TTask)
  private
    FCapturedOps: TCapturedOps;
    FTestProgram: TProgram;
    FOpCodes: TOpCodeDictionary;
    procedure ParseInput;
    procedure DetectOpCodes;
    function ExecuteTestProgram: TState;
    function BehavesLikeThreeOrMore: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

function MakeState(const S: String): TState;
var
  A: TArray<String>;
begin
  A := S.Replace('Before: ', '').Replace('After:  ', '').Replace('[', '').Replace(']', '').Split([', ']);
  FillChar(Result, SizeOf(Result), 0);
  Result[0] := A[0].ToInteger;
  Result[1] := A[1].ToInteger;
  Result[2] := A[2].ToInteger;
  Result[3] := A[3].ToInteger;
end;

function StateEquals(const A, B: TState): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := Low(A) to High(A) do
    Result := Result and (A[I] = B[I]);
end;

{ TOp }

function TOp.Apply(const Before: TState; const OpType: TOpType): TState;
begin
  Result := Before;
  case OpType of
    otNone: raise Exception.Create('Wrong op code');
    //
    otAddR: Result[C] := Before[A] + Before[B];
    otAddI: Result[C] := Before[A] + B;
    //
    otMulR: Result[C] := Before[A] * Before[B];
    otMulI: Result[C] := Before[A] * B;
    //
    otBAnR: Result[C] := Before[A] and Before[B];
    otBAnI: Result[C] := Before[A] and B;
    //
    otBOrR: Result[C] := Before[A] or Before[B];
    otBOrI: Result[C] := Before[A] or B;
    //
    otSetR: Result[C] := Before[A];
    otSetI: Result[C] := A;
    //
    otGtIR: if A         > Before[B] then Result[C] := 1 else Result[C] := 0;
    otGtRI: if Before[A] > B         then Result[C] := 1 else Result[C] := 0;
    otGtRR: if Before[A] > Before[B] then Result[C] := 1 else Result[C] := 0;
    //
    otEqIR: if A         = Before[B] then Result[C] := 1 else Result[C] := 0;
    otEqRI: if Before[A] = B         then Result[C] := 1 else Result[C] := 0;
    otEqRR: if Before[A] = Before[B] then Result[C] := 1 else Result[C] := 0;
  end;
end;

constructor TOp.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Split([' ']);
  Self.OpCode := A[0].ToInteger;
  Self.A      := A[1].ToInteger;
  Self.B      := A[2].ToInteger;
  Self.C      := A[3].ToInteger;
end;

{ TCapturedOps }

constructor TCapturedOp.Create(const ABefore, AOp, AAfter: String);
begin
  Before := MakeState(ABefore);
  Op := TOp.Create(AOp);
  After := MakeState(AAfter);

  Match;
end;

procedure TCapturedOp.Match;
var
  I: TOpType;
begin
  for I := TOpType(Integer(Low(TOpType)) + 1) to High(TOpType) do
    if StateEquals(After, Op.Apply(Before, I)) then
      begin
        SetLength(BehavesLike, Length(BehavesLike) + 1);
        BehavesLike[Length(BehavesLike) - 1] := I;
      end;
end;

{ TTask_AoC }

function TTask_AoC.BehavesLikeThreeOrMore: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to FCapturedOps.Count - 1 do
    if Length(FCapturedOps[I].BehavesLike) >= 3 then
      Inc(Result);
end;

procedure TTask_AoC.DetectOpCodes;
type
  TPossible = TList<TOpType>;

  function Behaves(const A: TArray<TOpType>; const T: TOpType): Boolean;
  var
    I: Integer;
  begin
    Result := False;

    // If opcode is already detected it cannot behave like some other
    if FOpCodes.ContainsValue(T) then
      Exit(False);

    for I := 0 to Length(A) - 1 do
      if A[I] = T then
        Exit(True);
  end;

var
  I, J, K: Integer;
  Found: Boolean;
  Possible: TObjectDictionary<Integer,TPossible>;
begin
  Possible := TObjectDictionary<Integer,TPossible>.Create([doOwnsValues]);

  try
    // Fill Possible with all possible behaves of operations
    for I := 0 to FCapturedOps.Count - 1 do
      with FCapturedOps[I] do
        begin
          if not Possible.ContainsKey(Op.OpCode) then
            Possible.Add(Op.OpCode, TPossible.Create);

          for J := 0 to Length(BehavesLike) - 1 do
            if not Possible[Op.OpCode].Contains(BehavesLike[J]) then
              begin
                Found := True;
                for K := 0 to FCapturedOps.Count - 1 do
                  if Op.OpCode = FCapturedOps[K].Op.OpCode then
                    if not Behaves(FCapturedOps[K].BehavesLike, BehavesLike[J]) then
                      begin
                        Found := False;
                        Break;
                      end;

                if Found then
                  Possible[Op.OpCode].Add(BehavesLike[J]);
              end;
        end;

    // Filter out Op codes
    for I := 0 to FCapturedOps.Count - 1 do
      if FOpCodes.ContainsKey(FCapturedOps[I].Op.OpCode) then
        Continue
      else
        with Possible[FCapturedOps[I].Op.OpCode] do
          begin
            J := 0;
            while J < Count do
              if not Behaves(FCapturedOps[I].BehavesLike, Items[J]) then
                Delete(J)
              else
                Inc(J);

            if Count = 1 then
              FOpCodes.Add(FCapturedOps[I].Op.OpCode, Items[0]);
          end;
  finally
    Possible.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    ParseInput;

    OK('Part 1: %d, Part 2: %d', [ BehavesLikeThreeOrMore, ExecuteTestProgram[0] ]);
  finally
    FTestProgram.Free;
    FCapturedOps.Free;
    FOpCodes.Free;
  end;
end;

function TTask_AoC.ExecuteTestProgram: TState;
var
  I: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);

  for I := 0 to FTestProgram.Count - 1 do
    Result := FTestProgram[I].Apply(Result, FOpCodes[FTestProgram[I].OpCode]);
end;

procedure TTask_AoC.ParseInput;
var
  I: Integer;
begin
  FCapturedOps := TCapturedOps.Create;
  FTestProgram := TProgram.Create;
  FOpCodes := TOpCodeDictionary.Create;

  with Input do
    try
      I := 0;
      while I < Count do
        if (Strings[I].Length > 0) and (Strings[I][1] = 'B') then
          begin
            FCapturedOps.Add(TCapturedOp.Create(Strings[I], Strings[I + 1], Strings[I + 2]));
            Inc(I, 4);
          end
        else
          begin
            if Strings[I] <> '' then
              FTestProgram.Add(TOp.Create(Strings[I]));
            Inc(I);
          end;
    finally
      Free;
    end;

  DetectOpCodes;
end;

initialization
  GTask := TTask_AoC.Create(2018, 16, 'Chronal Classification');

finalization
  GTask.Free;

end.
