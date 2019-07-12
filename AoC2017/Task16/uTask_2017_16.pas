unit uTask_2017_16;

interface

uses
  System.Generics.Collections, uTask;

type
  TPrograms = array [0..15] of Char;

  TMoveType = ( mtNone, mtSpin, mtExchange, mtPartner );

  TMove = record
    MoveType: TMoveType;
    N: Integer;
    X, Y: Integer;
    A, B: Char;
    constructor Create(const S: String);
    procedure Move(var Programs: TPrograms);
    // ------------------------
    {case MoveType: TMoveType of
      mtSpin:     (N: Integer);
      mtExchange: (X, Y: Integer);
      mtPartner:  (A, B: Char);}
  end;

  TTask_AoC = class (TTask)
  private
    FMoves: TList<TMove>;
    FPrograms: TPrograms;
    procedure LoadMoves;
    function MoveIt(const N: Integer): String;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TMove }

constructor TMove.Create(const S: String);
begin
  case S[1] of
    's':
      begin
        MoveType := mtSpin;
        N := S.Substring(1).ToInteger;
      end;
    'x':
      begin
        MoveType := mtExchange;
        X := S.Split(['/'])[0].Substring(1).ToInteger;
        Y := S.Split(['/'])[1].ToInteger;
      end;
    'p':
      begin
        MoveType := mtPartner;
        A := S[2];
        B := S[4];
      end;
  end;
end;

procedure TMove.Move(var Programs: TPrograms);

  procedure Swap(const X, Y: Integer);
  var
    C: Char;
  begin
    C := Programs[X];
    Programs[X] := Programs[Y];
    Programs[Y] := C;
  end;

  function Pos(const C: Char): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to 15 do
      if Programs[I] = C then
        Exit(I);
  end;

  procedure Rot(const N: Integer);
  var
    Current: TPrograms;
    I: Integer;
  begin
    Current := Programs;
    for I := 0 to 15 do
      Programs[(I + N) mod 16] := Current[I];
  end;

begin
  case MoveType of
    mtSpin:     Rot(N);
    mtExchange: Swap(X, Y);
    mtPartner:  Swap(Pos(A), Pos(B));
  end;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadMoves;

    OK(Format('Part 1: %s, Part 2: %s', [ MoveIt(1), MoveIt(1000000000) ]));
  finally
    FMoves.Free;
  end;
end;

procedure TTask_AoC.LoadMoves;
var
  A: TArray<String>;
  I: Integer;
begin
  FMoves := TList<TMove>.Create;
  with Input do
    try
      A := Text.Trim.Split([',']);
      for I := 0 to Length(A) - 1 do
        FMoves.Add(TMove.Create(A[I]));
    finally
      Free;
    end;
end;

function TTask_AoC.MoveIt(const N: Integer): String;
var
  I, J: Integer;
  // Cache for loop detection
  FCache: TList<TPrograms>;
begin
  for I := 0 to 15 do
    FPrograms[I] := Chr(Ord('a') + I);

  FCache := TList<TPrograms>.Create;
  try
    FCache.Add(FPrograms);
    for I := 0 to N - 1 do
      begin
        for J := 0 to FMoves.Count - 1 do
          FMoves[J].Move(FPrograms);
        // On loop stop performace
        if FCache.Contains(FPrograms) then
          Break;
        FCache.Add(FPrograms);
      end;
    // Get the result from cache
    Result := String(FCache[N mod FCache.Count]);
  finally
    FCache.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 16, 'Permutation Promenade');

finalization
  GTask.Free;

end.
