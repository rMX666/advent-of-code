unit uTask_2018_06;

interface

uses
  System.Types, System.Generics.Collections, System.Classes, uTask;

type
  TAreas = class;

  TArea = class
  private
    FOwner: TAreas;
    FCenter: TPoint;
    FBorder: TDictionary<TPoint,Boolean>;
    FVisited: TDictionary<TPoint,Boolean>;
    FInfinite: Boolean;
    FCanExpand: Boolean;
    FAreaSize: Integer;
    procedure ExpandBorder;
    function CanExpandTo(const P: TPoint): Boolean;
    function Contains(const P: TPoint): Boolean;
  public
    constructor Create(const AOwner: TAreas; const S: String);
    destructor Destroy; override;
    property Border: TDictionary<TPoint,Boolean> read FBorder;
    property Visited: TDictionary<TPoint,Boolean> read FVisited;
    property Infinite: Boolean read FInfinite;
    property AreaSize: Integer read FAreaSize;
  end;

  TAreas = class (TObjectList<TArea>)
  private
    FOnExpand: TNotifyEvent;
    FBounds: TRect;
    procedure DoOnExpand;
    procedure CheckBorders;
    function TryExpand: Boolean;
    procedure CalcBoundingBox;
  public
    procedure Expand;
    property OnExpand: TNotifyEvent read FOnExpand write FOnExpand;
  end;

  TTask_AoC = class (TTask)
  private
    FAreas: TAreas;
    function MaximalFiniteArea: Integer;
    function SafePlacesCount: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uForm_2018_06;

var
  GTask: TTask_AoC;

const DIRECTIONS: array [1..4] of TPoint =
  (
    ( X: -1; Y:  0 ),
    ( X:  1; Y:  0 ),
    ( X:  0; Y: -1 ),
    ( X:  0; Y:  1 )
  );

{ TArea }

function TArea.CanExpandTo(const P: TPoint): Boolean;
var
  I: Integer;
begin
  if not FOwner.FBounds.Contains(P) then
    begin
      FInfinite := True;
      Exit(False);
    end;

  if Contains(P) then
    Exit(False);

  for I := 0 to FOwner.Count - 1 do
    // Areas can have same points on border but cannot visit each others points
    if FOwner[I].FVisited.ContainsKey(P) then
      Exit(False);

  Result := True;
end;

function TArea.Contains(const P: TPoint): Boolean;
begin
  if FVisited.ContainsKey(P) then
    Exit(True);

  if FBorder.ContainsKey(P) then
    Exit(True);

  Result := False;
end;

constructor TArea.Create(const AOwner: TAreas; const S: String);
var
  A: TArray<String>;
begin
  FOwner := AOwner;
  FInfinite := False;
  FCanExpand := True;
  FAreaSize := 1;

  A := S.Split([', ']);
  FCenter.X := A[0].ToInteger;
  FCenter.Y := A[1].ToInteger;

  FBorder := TDictionary<TPoint,Boolean>.Create;
  FBorder.Add(FCenter, True);

  FVisited := TDictionary<TPoint,Boolean>.Create;
end;

destructor TArea.Destroy;
begin
  FBorder.Free;
  FVisited.Free;
  FOwner := nil;
  inherited;
end;

procedure TArea.ExpandBorder;

  function GetNeighbours(const P: TPoint): TArray<TPoint>;
  var
    I: Integer;
  begin
    SetLength(Result, 0);
    for I := 1 to 4 do
      if CanExpandTo(P + DIRECTIONS[I]) then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := P + DIRECTIONS[I];
        end;
  end;

var
  Key: TPoint;
  Keys, Neightbours: TArray<TPoint>;
  I, L: Integer;
  DidExpand: Boolean;
begin
  DidExpand := False;
  Keys := FBorder.Keys.ToArray;
  for Key in Keys do
    if FBorder[Key] then
      begin
        Neightbours := GetNeighbours(Key);
        FBorder.Remove(Key);
        FVisited.Add(Key, True);

        L := Length(Neightbours);

        DidExpand := DidExpand or (L > 0);
        for I := 0 to L - 1 do
          begin
            FBorder.Add(Neightbours[I], True);
            Inc(FAreaSize);
          end;
      end;

  if not DidExpand then
    FCanExpand := False;
end;

{ TAreas }

procedure TAreas.CalcBoundingBox;
var
  I, MinX, MinY, MaxX, MaxY: Integer;
begin
  MinX := MaxInt;
  MinY := MaxInt;
  MaxX := 0;
  MaxY := 0;

  for I := 0 to Count - 1 do
    begin
      if MinX > Items[I].FCenter.X then
        MinX := Items[I].FCenter.X;
      if MinY > Items[I].FCenter.Y then
        MinY := Items[I].FCenter.Y;
      if MaxX < Items[I].FCenter.X then
        MaxX := Items[I].FCenter.X;
      if MaxY < Items[I].FCenter.Y then
        MaxY := Items[I].FCenter.Y;
    end;

  FBounds.Left := MinX - 10;
  FBounds.Top := MinY - 10;
  FBounds.Right := MaxX + 10;
  FBounds.Bottom := MaxY + 10;
end;

procedure TAreas.CheckBorders;
var
  I, J: Integer;
  Key: TPoint;
begin
  for I := 0 to Count - 1 do
    for Key in Items[I].FBorder.Keys do
      for J := 0 to Count - 1 do
        if I = J then
          Continue
        else
          if Items[J].Contains(Key) then
            begin
              Items[I].FBorder[Key] := False;
              if Items[J].FBorder.ContainsKey(Key) then
                Items[J].FBorder[Key] := False;
            end;

end;

procedure TAreas.DoOnExpand;
begin
  if Assigned(FOnExpand) then
    FOnExpand(Self);
end;

procedure TAreas.Expand;
begin
  CalcBoundingBox;

  while TryExpand do;
end;

function TAreas.TryExpand: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Items[I].FCanExpand then
      begin
        Items[I].ExpandBorder;
        Result := Result or Items[I].FCanExpand;
      end;

  CheckBorders;

  DoOnExpand;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  I: Integer;
begin
  FAreas := TAreas.Create;

  try
    with Input do
      try
        for I := 0 to Count - 1 do
          FAreas.Add(TArea.Create(FAreas, Strings[I]))
      finally
        Free;
      end;

    FAreas.Expand;

    OK('Part 1: %d, Part 2: %d', [ MaximalFiniteArea, SafePlacesCount ]);

    fMain_2018_06 := TfMain_2018_06.Create(nil);
    fMain_2018_06.Show;
    fMain_2018_06.DrawAreas(FAreas);
  finally
    FAreas.Free;
  end;
end;

function TTask_AoC.MaximalFiniteArea: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FAreas.Count - 1 do
    if not FAreas[I].Infinite and (Result < FAreas[I].Visited.Count) then
      Result := FAreas[I].Visited.Count;
end;

function TTask_AoC.SafePlacesCount: Integer;

  function GetDist(const X, Y, X1, Y1: Integer): Integer;
  begin
    Result := Abs(X - X1) + Abs(Y - Y1);
  end;

var
  X, Y, I, Dist: Integer;
begin
  Result := 0;

  for X := FAreas.FBounds.Left to FAreas.FBounds.Right do
    for Y := FAreas.FBounds.Top to FAreas.FBounds.Bottom do
      begin
        Dist := 0;
        for I := 0 to FAreas.Count - 1 do
          begin
            Inc(Dist, GetDist(X, Y, FAreas[I].FCenter.X, FAreas[I].FCenter.Y));
            if Dist >= 10000 then
              Break;
          end;
        if Dist < 10000 then
          Inc(Result);
      end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 6, 'Chronal Coordinates');

finalization
  GTask.Free;

end.
