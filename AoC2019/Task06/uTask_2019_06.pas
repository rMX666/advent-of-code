unit uTask_2019_06;

interface

uses
  uTask, System.Generics.Collections;

type
  TOrbit = record
    Name: String;
    IsParent: Boolean;
    constructor Create(const AName: String; AIsParent: Boolean);
    class operator Implicit(const S: String): TOrbit; overload;
    class operator Implicit(const Orbit: TOrbit): String; overload;
  end;

  TOrbits = TList<TOrbit>;
  TOrbitMap = class(TObjectDictionary<String,TOrbits>)
  private
    FRoots: TOrbits;
    function GetRoots: TOrbits;
  public
    constructor Create(Ownerships: TDictionaryOwnerships; ACapacity: Integer = 0);
    destructor Destroy; override;
    property Roots: TOrbits read GetRoots;
  end;

  TTask_AoC = class (TTask)
  private
    FOrbitMap: TOrbitMap;
    procedure LoadOrbitMap;
    function CountOrbits: Integer;
    function BFS(const A, B: String): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TOrbit }

constructor TOrbit.Create(const AName: String; AIsParent: Boolean);
begin
  Name := AName;
  IsParent := AIsParent;
end;

class operator TOrbit.Implicit(const Orbit: TOrbit): String;
begin
  Result := Orbit.Name;
end;

class operator TOrbit.Implicit(const S: String): TOrbit;
begin
  Result.Name := S;
  Result.IsParent := False;
end;

{ TOrbitMap }

constructor TOrbitMap.Create(Ownerships: TDictionaryOwnerships; ACapacity: Integer);
begin
  inherited Create(Ownerships, ACapacity);
  FRoots := nil;
end;

destructor TOrbitMap.Destroy;
begin
  if Assigned(FRoots) then
    FreeAndNil(FRoots);
  inherited;
end;

function TOrbitMap.GetRoots: TOrbits;

  function Contains(const Orbits: TOrbits; const Orbit: String): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to Orbits.Count - 1 do
      if not Orbits[I].IsParent and (Orbits[I] = Orbit) then
        Exit(True);
  end;

var
  Key: String;
  Value: TOrbits;
  IsRoot: Boolean;
begin
  if Assigned(FRoots) then
    Exit(FRoots);

  FRoots := TOrbits.Create;

  for Key in Keys do
    begin
      IsRoot := True;
      for Value in Values do
        if Contains(Value, Key) then
          begin
            IsRoot := False;
            Break;
          end;
      if IsRoot then
        FRoots.Add(Key);
    end;

  Result := FRoots;
end;

{ TTask_AoC }

function TTask_AoC.CountOrbits: Integer;

  function CountOrbitsR(const Orbits: TOrbits; const Level: Integer): Integer;
  var
    I: Integer;
  begin
    Result := Level;
    for I := 0 to Orbits.Count - 1 do
      if not Orbits[I].IsParent then
        Inc(Result, CountOrbitsR(FOrbitMap[Orbits[I]], Level + 1));
  end;

var
  I: Integer;
begin
  Result := 0;
  with FOrbitMap.Roots do
    for I := 0 to Count - 1 do
      Inc(Result, CountOrbitsR(FOrbitMap[Items[I]], 0));
end;

function TTask_AoC.BFS(const A, B: String): Integer;
var
  Queue: TQueue<String>;
  Visited: TDictionary<String,String>;
  Next, Current: String;

  function GetPathLength(Item: String): Integer;
  begin
    Result := 0;
    while Visited.ContainsKey(Item) and (Visited[Item] <> A) do
      begin
        Item := Visited[Item];
        Inc(Result);
      end;
  end;

begin
  if not FOrbitMap.ContainsKey(A) or not FOrbitMap.ContainsKey(B) then
    Exit(0);

  Queue := TQueue<String>.Create;
  Visited := TDictionary<String,String>.Create;

  try
    Queue.Enqueue(A);
    while Queue.Count > 0 do
      begin
        Current := Queue.Dequeue;
        for Next in FOrbitMap[Current] do
          begin
            if Next = B then
              Exit(GetPathLength(Current));
            if Visited.ContainsKey(Next) then
              Continue;
            Queue.Enqueue(Next);
            Visited.Add(Next, Current);
          end;
      end;
  finally
    Queue.Free;
    Visited.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    LoadOrbitMap;

    OK('Part 1: %d, Part 2: %d', [ CountOrbits, BFS('YOU', 'SAN') ]);
  finally
    FOrbitMap.Free;
  end;
end;


procedure TTask_AoC.LoadOrbitMap;
var
  I: Integer;
  A: TArray<String>;
begin
  FOrbitMap := TOrbitMap.Create([ doOwnsValues ]);

  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          A := Strings[I].Split([')']);
          if not FOrbitMap.ContainsKey(A[0]) then
            FOrbitMap.Add(A[0], TOrbits.Create);
          if not FOrbitMap.ContainsKey(A[1]) then
            FOrbitMap.Add(A[1], TOrbits.Create);
          // For the first part parent matters, for the second - it doesn't.
          // So we need to keep all neighbours, but mark initial parent.
          FOrbitMap[A[0]].Add(TOrbit.Create(A[1], False));
          FOrbitMap[A[1]].Add(TOrbit.Create(A[0], True));
        end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 6, 'Universal Orbit Map');

finalization
  GTask.Free;

end.
