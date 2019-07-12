unit uTask_2017_14;

interface

uses
  System.Generics.Collections, System.Classes, uTask;

type
  TTask_AoC = class (TTask)
  private
    FHashes: TObjectList<TBits>;
    procedure FillHashes;
    function UsedBlocks: Integer;
    function GroupCount: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Types, System.Math, uKnotHash;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    FillHashes;

    OK(Format('Part 1: %d, Part 2: %d', [ UsedBlocks, GroupCount ]));
  finally
    FHashes.Free;
  end;
end;


procedure TTask_AoC.FillHashes;
var
  Salt: String;
  I: Integer;
begin
  with Input do
    try
      Salt := Text.Trim + '-';
    finally
      Free;
    end;

  FHashes := TObjectList<TBits>.Create;
  for I := 0 to 127 do
    FHashes.Add(TKnotHash.HashBits(Salt + I.ToString));
end;

function TTask_AoC.GroupCount: Integer;
const
  Directions: array [0..3] of TPoint =
    (
      ( X: -1; Y:  0 )
    , ( X:  1; Y:  0 )
    , ( X:  0; Y: -1 )
    , ( X:  0; Y:  1 )
    );
var
  FCache: TDictionary<TPoint,Integer>;
  FGroups: TList<Integer>;

  function CanGo(const P: TPoint): Boolean;
  begin
    if FCache.ContainsKey(P) then
      Exit(False);

    Result := (P.X >= 0) and (P.X < FHashes.Count)
          and (P.Y >= 0) and (P.Y < FHashes[P.X].Size);

    if Result then
      Result := FHashes[P.X][P.Y];
  end;

  function FindSiblings(const P: TPoint; const Index: Integer): Boolean;
  var
    Next: TPoint;
    I: Integer;
  begin
    Result := True;

    if FCache.ContainsKey(P) then
      Exit(False)
    else
      FCache.Add(P, Index);

    if not FGroups.Contains(Index) then
      FGroups.Add(Index);

    for I := 0 to 3 do
      begin
        Next := P + Directions[I];
        if CanGo(Next) then
          FindSiblings(Next, Index);
      end;
  end;

var
  I, J: Integer;
  P: TPoint;
begin
  FCache := TDictionary<TPoint,Integer>.Create;
  FGroups := TList<Integer>.Create;
  Result := 0;

  try
    for I := 0 to FHashes.Count - 1 do
      for J := 0 to FHashes[I].Size - 1 do
        begin
          P := TPoint.Create(I, J);
          if FHashes[I][J] and not FCache.ContainsKey(P) then
            if FindSiblings(P, Result) then
              Inc(Result);
        end;
  finally
    FCache.Free;
    FGroups.Free;
  end;
end;

function TTask_AoC.UsedBlocks: Integer;
var
  I, J: Integer;
begin
  Result := 0;
  for I := 0 to FHashes.Count - 1 do
    for J := 0 to FHashes[I].Size - 1 do
      if FHashes[I][J] then
        Inc(Result);
end;

initialization
  GTask := TTask_AoC.Create(2017, 14, 'Disk Defragmentation');

finalization
  GTask.Free;

end.
