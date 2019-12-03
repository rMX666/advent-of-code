unit uTask_2016_21;

interface

uses
  System.Generics.Collections, uTask;

type
  TScrambler = class;

  TAction = class
  private
    FParent: TScrambler;
  protected
    constructor Create(const Parent: TScrambler); virtual;
  public
    class function MakeAction(const Parent: TScrambler; const S: String): TAction;
    procedure DoAction(const Reverse: Boolean); virtual; abstract;
  end;

  TSwapPosAction = class(TAction)
  private
    FX, FY: Integer;
  protected
    constructor Create(const Parent: TScrambler; const X, Y: Integer); reintroduce; overload;
  public
    procedure DoAction(const Reverse: Boolean); override;
  end;

  TSwapLetterAction = class(TAction)
  private
    FX, FY: Char;
  protected
    constructor Create(const Parent: TScrambler; const X, Y: Char); reintroduce; overload;
  public
    procedure DoAction(const Reverse: Boolean); override;
  end;

  TReverseAction = class(TAction)
  private
    FX, FY: Integer;
    function ReverseStr(const S: String): String;
  protected
    constructor Create(const Parent: TScrambler; const X, Y: Integer); reintroduce; overload;
  public
    procedure DoAction(const Reverse: Boolean); override;
  end;

  TRotateAction = class(TAction)
  private
    FX: Integer; // Positive - Right
  protected
    constructor Create(const Parent: TScrambler; const X: Integer); reintroduce; overload;
  public
    procedure DoAction(const Reverse: Boolean); override;
  end;

  TRotateLetterAction = class(TAction)
  private
    FX: Char;
  protected
    constructor Create(const Parent: TScrambler; const X: Char); reintroduce; overload;
  public
    procedure DoAction(const Reverse: Boolean); override;
  end;

  TMoveAction = class(TAction)
  private
    FX, FY: Integer;
  protected
    constructor Create(const Parent: TScrambler; const X, Y: Integer); reintroduce; overload;
  public
    procedure DoAction(const Reverse: Boolean); override;
  end;

  TScrambler = class (TList<TAction>)
  private
    FStr: String;
    FReverse: Boolean;
  public
    constructor Create(const AStr: String; const AReverse: Boolean);
    destructor Destroy; override;
    function Run: String;
  end;

  TTask_AoC = class (TTask)
  private
    FScrambler: TScrambler;
    procedure LoadActions;
    function Scramble(const S: String; const Reverse: Boolean): String;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TAction }

constructor TAction.Create(const Parent: TScrambler);
begin
  FParent := Parent;
end;

class function TAction.MakeAction(const Parent: TScrambler; const S: String): TAction;
var
  A: TArray<String>;
begin
  A := S.Split([' ']);

  Result := nil;
  if A[0] = 'swap' then
    begin
      if A[1] = 'position' then
        Result := TSwapPosAction.Create(Parent, A[2].ToInteger + 1, A[5].ToInteger + 1)
      else if A[1] = 'letter' then
        Result := TSwapLetterAction.Create(Parent, A[2][1], A[5][1]);
    end
  else if A[0] = 'reverse' then
    Result := TReverseAction.Create(Parent, A[2].ToInteger, A[4].ToInteger)
  else if A[0] = 'rotate' then
    begin
      if A[1] = 'right' then
        Result := TRotateAction.Create(Parent, A[2].ToInteger)
      else if A[1] = 'left' then
        Result := TRotateAction.Create(Parent, -A[2].ToInteger)
      else if A[1] = 'based' then
        Result := TRotateLetterAction.Create(Parent, A[6][1]);
    end
  else if A[0] = 'move' then
    Result := TMoveAction.Create(Parent, A[2].ToInteger, A[5].ToInteger);

  if Result = nil then
    raise EInvalidArgument.Create('Wrong type of action');
end;

{ TSwapPosAction }

constructor TSwapPosAction.Create(const Parent: TScrambler; const X, Y: Integer);
begin
  inherited Create(Parent);
  FX := X;
  FY := Y;
end;

procedure TSwapPosAction.DoAction(const Reverse: Boolean);
var
  C: Char;
begin
  C := FParent.FStr[FX];
  FParent.FStr[FX] := FParent.FStr[FY];
  FParent.FStr[FY] := C;
end;

{ TSwapLetterAction }

constructor TSwapLetterAction.Create(const Parent: TScrambler; const X, Y: Char);
begin
  inherited Create(Parent);
  FX := X;
  FY := Y;
end;

procedure TSwapLetterAction.DoAction(const Reverse: Boolean);
var
  X, Y: Integer;
  C: Char;
begin
  X := FParent.FStr.IndexOf(FX) + 1;
  Y := FParent.FStr.IndexOf(FY) + 1;

  C := FParent.FStr[X];
  FParent.FStr[X] := FParent.FStr[Y];
  FParent.FStr[Y] := C;
end;

{ TReverseAction }

constructor TReverseAction.Create(const Parent: TScrambler; const X, Y: Integer);
begin
  inherited Create(Parent);
  FX := X;
  FY := Y;
end;

procedure TReverseAction.DoAction(const Reverse: Boolean);
begin
  FParent.FStr := FParent.FStr.Substring(0, FX) + ReverseStr(FParent.FStr.Substring(FX, FY - FX + 1)) + FParent.FStr.Substring(FY + 1);
end;

function TReverseAction.ReverseStr(const S: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := S.Length downto 1 do
    Result := Result + S[I];
end;

{ TRotateAction }

constructor TRotateAction.Create(const Parent: TScrambler; const X: Integer);
begin
  inherited Create(Parent);
  FX := X;
end;

procedure TRotateAction.DoAction(const Reverse: Boolean);
var
  X: Integer;
begin
  X := FX;
  if Reverse then
    X := -X;

  if X > 0 then
    X := FParent.FStr.Length - X
  else if X < 0 then
    X := -X;

  FParent.FStr := FParent.FStr.Substring(X) + FParent.FStr.Substring(0, X);
end;

{ TRotateLetterAction }

constructor TRotateLetterAction.Create(const Parent: TScrambler; const X: Char);
begin
  inherited Create(Parent);
  FX := X;
end;

procedure TRotateLetterAction.DoAction(const Reverse: Boolean);
{
  a_______  0 -> 1 (pos = 1) <LRotBack = 1> _a______
  _a______  1 -> 2 (pos = 3) <LRotBack = 2> ___a____
  __a_____  2 -> 3 (pos = 5) <LRotBack = 3> _____a__
  ___a____  3 -> 4 (pos = 7) <LRotBack = 4> _______a
  ____a___  4 -> 6 (pos = 2) <LRotBack = 6> __a_____
  _____a__  5 -> 7 (pos = 4) <LRotBack = 7> ____a___
  ______a_  6 -> 8 (pos = 6) <LRotBack = 0> ______a_
  _______a  7 -> 9 (pos = 0) <LRotBack = 1> a_______
}
const
  RevRot: array[0..7] of Integer = ( 1, 1, 6, 2, 7, 3, 0, 4 );
var
  X: Integer;
begin
  X := FParent.FStr.IndexOf(FX);
  if not Reverse then
    begin
      if X >= 4 then
        Inc(X);

      X := FParent.FStr.Length - ((X + 1) mod FParent.FStr.Length);
    end
  else
    X := RevRot[X];
  FParent.FStr := FParent.FStr.Substring(X) + FParent.FStr.Substring(0, X);
end;

{ TMoveAction }

constructor TMoveAction.Create(const Parent: TScrambler; const X, Y: Integer);
begin
  inherited Create(Parent);
  FX := X;
  FY := Y;
end;

procedure TMoveAction.DoAction(const Reverse: Boolean);
var
  C: Char;
  X, Y: Integer;
begin
  if not Reverse then
    begin
      X := FX;
      Y := FY;
    end
  else
    begin
      X := FY;
      Y := FX;
    end;

  C := FParent.FStr[X + 1];
  FParent.FStr := FParent.FStr.Remove(X, 1).Insert(Y, C);
end;

{ TScrambler }

constructor TScrambler.Create(const AStr: String; const AReverse: Boolean);
begin
  inherited Create;
  FStr := AStr;
  FReverse := AReverse;
end;

destructor TScrambler.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited;
end;

function TScrambler.Run: String;
var
  I: Integer;
begin
  if FReverse then
    Reverse;
  for I := 0 to Count - 1 do
    Items[I].DoAction(FReverse);
  Result := FStr;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  OK('Part 1: %s, Part 2: %s', [ Scramble('abcdefgh', False), Scramble('fbgdceah', True) ]);
end;

procedure TTask_AoC.LoadActions;
var
  I: Integer;
begin
  with Input do
    try
      for I := 0 to Count - 1 do
        FScrambler.Add(TAction.MakeAction(FScrambler, Strings[I]));
    finally
      Free;
    end;
end;

function TTask_AoC.Scramble(const S: String; const Reverse: Boolean): String;
begin
  FScrambler := TScrambler.Create(S, Reverse);
  try
    LoadActions;
    Result := FScrambler.Run;
  finally
    FScrambler.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 21, 'Scrambled Letters and Hash');

finalization
  GTask.Free;

end.
