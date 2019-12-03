unit uTask_2016_20;

interface

uses
  System.Generics.Collections, System.Generics.Defaults, uTask;

type
  TIPRange = record
    X1, X2: Int64;
    constructor Create(const S: String); overload;
    constructor Create(const AX1, AX2: Int64); overload;
  end;

  TIPRanges = class(TList<TIPRange>)
  strict private type
    TComparer = class(TCustomComparer<TIPRange>)
    public
      function Compare(const Left, Right: TIPRange): Integer; override;
      function Equals(const Left, Right: TIPRange): Boolean; override;
      function GetHashCode(const Value: TIPRange): Integer; override;
    end;
  private
    FComparer: TComparer;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TTask_AoC = class (TTask)
  private
    FBlacklist: TIPRanges;
    procedure LoadBlacklist;
    procedure MergeBlacklist;
    function FirstFree: Int64;
    function CountFree: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Hash;

var
  GTask: TTask_AoC;

{ TIPRange }

constructor TIPRange.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Split(['-']);
  X1 := A[0].ToInt64;
  X2 := A[1].ToInt64;
end;

constructor TIPRange.Create(const AX1, AX2: Int64);
begin
  X1 := AX1;
  X2 := AX2;
end;

{ TIPRanges.TComparer }

function TIPRanges.TComparer.Compare(const Left, Right: TIPRange): Integer;
  function Comp(const X1, X2: Int64): Integer;
  begin
    if X1 > X2 then
      Result := 1
    else if X1 < X2 then
      Result := -1
    else
      Result := 0;
  end;
begin
  Result := Comp(Left.X1, Right.X1);
  if Result = 0 then
    Result := Comp(Left.X2, Right.X2);
end;

function TIPRanges.TComparer.Equals(const Left, Right: TIPRange): Boolean;
begin
  Result := (Left.X1 = Right.X1) and (Left.X2 = Right.X2);
end;

function TIPRanges.TComparer.GetHashCode(const Value: TIPRange): Integer;
begin
  Result := System.Hash.THashBobJenkins.GetHashValue(Value, SizeOf(TIPRange), 0);
end;

{ TIPRanges }

constructor TIPRanges.Create;
begin
  FComparer := TIPRanges.TComparer.Create;
  inherited Create(FComparer);
end;

destructor TIPRanges.Destroy;
begin
  FComparer.Free;
  inherited;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadBlacklist;

    OK('Part 1: %d, Part 2: %d', [ FirstFree, CountFree ]);
  finally
    FBlacklist.Free;
  end;
end;

function TTask_AoC.CountFree: Integer;
var
  I: Integer;
  R: Int64;
begin
  R := Int64(256) * 256 * 256* 256; // WFT overflow?
  for I := 0 to FBlacklist.Count - 1 do
    Dec(R, FBlacklist[I].X2 - FBlacklist[I].X1 + 1);

  Result := R;
end;

function TTask_AoC.FirstFree: Int64;
var
  R: TIPRange;
begin
  R := FBlacklist[0];
  if R.X1 > 0 then
    Result := 0
  else
    Result := R.X2 + 1;
end;

procedure TTask_AoC.LoadBlacklist;
var
  I: Integer;
begin
  FBlacklist := TIPRanges.Create;
  with Input do
    try
      for I := 0 to Count - 1 do
        FBlacklist.Add(TIPRange.Create(Strings[I]));

      FBlacklist.Sort;
      MergeBlacklist;
    finally
      Free;
    end;
end;

procedure TTask_AoC.MergeBlacklist;
var
  I, J: Integer;
  A, B: TIPRange;
begin
  I := 0;
  J := 1;
  while J < FBlacklist.Count do
    begin
      A := FBlacklist[I];
      B := FBlacklist[J];

      if A.X2 >= B.X1 - 1 then
        begin
          FBlacklist.Delete(J);
          FBlacklist[I] := TIPRange.Create(A.X1, Max(A.X2, B.X2));
        end
      else
        begin
          Inc(I);
          J := I + 1;
        end;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 20, 'Firewall Rules');

finalization
  GTask.Free;

end.
