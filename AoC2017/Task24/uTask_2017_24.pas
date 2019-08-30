unit uTask_2017_24;

interface

uses
  System.Generics.Collections, uTask;

type
  TPort = record
    X, Y: Byte;
    constructor Create(const S: String); overload;
    constructor Create(const Port: TPort; const N: Integer); overload;
    class operator Equal(const A, B: TPort): Boolean; overload;
    class operator Equal(const A: TPort; const N: Integer): Boolean; overload;
    class operator Equal(const N: Integer; const B: TPort): Boolean; overload;
  end;

  TTask_AoC = class (TTask)
  private
    FPorts: TList<TPort>;
    procedure LoadPorts;
    function BuildBridge(const Longest: Boolean): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TPort }

constructor TPort.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Split(['/']);
  if A[0].ToInteger > A[1].ToInteger then
    begin
      X := A[1].ToInteger;
      Y := A[0].ToInteger;
    end
  else
    begin
      X := A[0].ToInteger;
      Y := A[1].ToInteger;
    end;
end;

constructor TPort.Create(const Port: TPort; const N: Integer);
begin
  if Port.X = N then
    begin
      X := Port.X;
      Y := Port.Y;
    end
  else
    begin
      X := Port.Y;
      Y := Port.X;
    end;
end;

class operator TPort.Equal(const A, B: TPort): Boolean;
begin
  Result := ((A.X = B.X) and (A.Y = B.Y))
         or ((A.Y = B.X) and (A.X = B.Y));
end;

class operator TPort.Equal(const A: TPort; const N: Integer): Boolean;
begin
  Result := (A.X = N) or (A.Y = N);
end;

class operator TPort.Equal(const N: Integer; const B: TPort): Boolean;
begin
  Result := B = N;
end;

{ TTask_AoC }

function TTask_AoC.BuildBridge(const Longest: Boolean): Integer;
type
  TBridge = TList<TPort>;
  TBridges = TObjectList<TBridge>;
var
  Bridges: TBridges;

  function Filter(const PortNum: Integer): TArray<TPort>;
  var
    I: Integer;
  begin
    SetLength(Result, 0);
    for I := 0 to FPorts.Count - 1 do
      if FPorts[I] = PortNum then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := TPort.Create(FPorts[I], PortNum);
        end;
  end;

  function Contains(const Bridge: TBridge; const Port: TPort): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to Bridge.Count - 1 do
      if Bridge[I] = Port then
        Exit(True);
  end;

  procedure Build(const Bridge: TBridge);
  var
    A: TArray<TPort>;
    I: Integer;
    NewBridge: TBridge;
    Added: Boolean;
  begin
    Added := False;
    try
      A := Filter(Bridge.Last.Y);
      for I := 0 to Length(A) - 1 do
        if not Contains(Bridge, A[I]) then
          begin
            NewBridge := TBridge.Create(Bridge);
            NewBridge.Add(A[I]);
            Build(NewBridge);
            Added := True;
          end;
    finally
      // "Not Added" means that it was the last step of building and now we can add bridge to list
      // We can add all bridges, but it would significantly increase the amount of bridges
      if not Added then
        Bridges.Add(Bridge)
      else
        Bridge.Free;
    end;
  end;

  function Sum(const Bridge: TBridge): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to Bridge.Count - 1 do
      Inc(Result, Bridge[I].X + Bridge[I].Y);
  end;

var
  A: TArray<TPort>;
  I: Integer;
  Bridge: TBridge;
  CurSum, MaxSum, CurLen, MaxLen: Integer;
begin
  Bridges := TBridges.Create;

  try
    A := Filter(0);

    // Build all possible bridges from 0 port
    for I := 0 to Length(A) - 1 do
      begin
        Bridge := TBridge.Create;
        Bridge.Add(A[I]);
        Build(Bridge);
      end;

    // Find maximums
    CurSum := Sum(Bridges[0]);
    MaxSum := CurSum;
    MaxLen := 0;
    if Longest then
      begin
        CurLen := Bridges[0].Count;
        MaxLen := CurLen;
      end;
    for I := 1 to Bridges.Count - 1 do
      begin
        CurSum := Sum(Bridges[I]);
        if MaxSum < CurSum then
          case Longest of
            // Part 1
            False:
              MaxSum := CurSum;
            // Part 2
            True:
              begin
                CurLen := Bridges[I].Count;
                if MaxLen <= CurLen then
                  begin
                    MaxLen := CurLen;
                    MaxSum := CurSum;
                  end;
              end;
          end;
      end;

    Result := MaxSum;
  finally
    Bridges.Free;
  end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    LoadPorts;

    OK(Format('Part 1: %d, Part 2: %d', [ BuildBridge(False), BuildBridge(True) ]));
  finally
    FPorts.Free;
  end;
end;

procedure TTask_AoC.LoadPorts;
var
  I: Integer;
begin
  FPorts := TList<TPort>.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FPorts.Add(TPort.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 24, 'Electromagnetic Moat');

finalization
  GTask.Free;

end.
