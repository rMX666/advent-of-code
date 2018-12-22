unit uProgram_2018_19;

interface

uses
  System.Generics.Collections;

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

  TState = array [0..5] of Int64;

  TOp = record
    OpName: String;
    OpType: TOpType;
    A, B, C: Int64;
    constructor Create(const S: String);
    function Apply(const Before: TState): TState;
    function ToString: String;
  end;

  TProgram = class (TList<TOp>)
  private
    FIP: Integer;
    FState: TState;
    function GetIP: Integer;
    procedure SetIP(const Value: Integer);
    function GetState(const Index: Integer): Int64;
    procedure SetState(const Index: Integer; const Value: Int64);
    function GetCountStates: Integer;
  public
    function Execute(const InitialState: TState; const BreakOnEnter: Boolean = False): TState;
    function Step: Boolean;
    procedure SetIPRegister(const AIP: Integer);
    property IP: Integer read GetIP write SetIP;
    property State[const Index: Integer]: Int64 read GetState write SetState;
    property CountStates: Integer read GetCountStates;
  end;

implementation

uses
  System.SysUtils;

{ TOp }

function TOp.Apply(const Before: TState): TState;
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

  function StrToOpType(const S: String): TOpType;
  begin
    Result := otNone;
    if      S = 'addr' then Result := otAddR
    else if S = 'addi' then Result := otAddI
    else if S = 'mulr' then Result := otMulR
    else if S = 'muli' then Result := otMulI
    else if S = 'banr' then Result := otBAnR
    else if S = 'bani' then Result := otBAnI
    else if S = 'borr' then Result := otBOrR
    else if S = 'bori' then Result := otBOrI
    else if S = 'setr' then Result := otSetR
    else if S = 'seti' then Result := otSetI
    else if S = 'gtir' then Result := otGtIR
    else if S = 'gtri' then Result := otGtRI
    else if S = 'gtrr' then Result := otGtRR
    else if S = 'eqir' then Result := otEqIR
    else if S = 'eqri' then Result := otEqRI
    else if S = 'eqrr' then Result := otEqRR;
  end;

var
  A: TArray<String>;
begin
  A := S.Split([' ']);
  Self.OpName := A[0];
  Self.OpType := StrToOpType(A[0]);
  Self.A := A[1].ToInteger;
  Self.B := A[2].ToInteger;
  Self.C := A[3].ToInteger;
end;

function TOp.ToString: String;
begin
  Result := Format('%s %d %d %d', [ OpName, A, B, C ]);
end;

{ TProgram }

function TProgram.Execute(const InitialState: TState; const BreakOnEnter: Boolean): TState;
begin
  FState := InitialState;

  if BreakOnEnter then
    Exit(FState);

  while Step do;

  Result := FState;
end;

function TProgram.GetCountStates: Integer;
begin
  Result := Length(FState);
end;

function TProgram.GetIP: Integer;
begin
  Result := FState[FIP];
end;

function TProgram.GetState(const Index: Integer): Int64;
begin
  Result := FState[Index];
end;

procedure TProgram.SetIP(const Value: Integer);
begin
  FState[FIP] := Value;
end;

procedure TProgram.SetIPRegister(const AIP: Integer);
begin
  FIP := AIP;
end;

procedure TProgram.SetState(const Index: Integer; const Value: Int64);
begin
  FState[Index] := Value;
end;

function TProgram.Step: Boolean;
begin
  if IP >= Count then
    Exit(False);

  FState := Items[IP].Apply(FState);
  IP := IP + 1;

  Result := IP < Count;
end;

end.
