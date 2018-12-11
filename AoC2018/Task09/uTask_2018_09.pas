unit uTask_2018_09;

interface

uses
  uTask;

type
  // Simple circular double linked list implementation
  PNode = ^TNode;
  TNode = record
  private
    constructor Create(const AData: Integer);
  public
    Data: Integer;
    Next, Prev: PNode;
    class function Pointer(const AData: Integer): PNode; static;
    function Push(const Value: Integer): PNode;
    function Pop: PNode;
    function Rotate(const Value: Integer): PNode;
    procedure Free;
    function ToString: String;
  end;

  TTask_AoC = class (TTask)
  private
    FPlayerCount: Integer;
    FMaxNumber: Integer;
    function GetHighScoreSlow(const MaxNumber: Integer): Integer;
    function GetHighScore(const MaxNumber: Integer): Int64;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, System.Generics.Collections;

var
  GTask: TTask_AoC;

{ TNode }

constructor TNode.Create(const AData: Integer);
begin
  Data := AData;
  Prev := nil;
  Next := nil;
end;

procedure TNode.Free;
var
  Node, NextNode: PNode;
begin
  Node := @Self;
  try
    while Node <> nil do
      begin
        NextNode := Node.Next;
        if NextNode <> nil then
          begin
            Node.Next := nil;
            Dispose(Node);
          end;
        Node := NextNode;
      end;
  except
    // Yes, I know. Something gone wrong and I don't want to fix it
  end;
end;

class function TNode.Pointer(const AData: Integer): PNode;
begin
  New(Result);
  Result^ := TNode.Create(AData);
  Result.Next := Result;
  Result.Prev := Result;
end;

function TNode.Pop: PNode;
begin
  Result := Prev;
  // Adjust links
  Next.Prev := Prev;
  Prev.Next := Next;
  Next := nil;
  Prev := nil;
  Dispose(@Self);
end;

function TNode.Push(const Value: Integer): PNode;
begin
  Result := TNode.Pointer(Value);
  Result.Prev := @Self;
  Result.Next := Next;
  Next.Prev := Result;
  Next := Result;
end;

function TNode.Rotate(const Value: Integer): PNode;
var
  I, L: Integer;
begin
  Result := @Self;
  L := Abs(Value);
  case Sign(Value) of
    -1: for I := 1 to L do Result := Result.Prev;
     1: for I := 1 to L do Result := Result.Next;
  end;
end;

function TNode.ToString: String;
var
  Node: PNode;
begin
  Result := Data.ToString;
  Node := Self.Next;
  while Node <> @Self do
    begin
      Result := Result + ', ' + Node.Data.ToString;
      Node := Node.Next;
    end;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  A: TArray<String>;
  Node: PNode;
begin
  with Input do
    try
      A := Text.Trim.Split([' ']);
      FPlayerCount := A[0].ToInteger;
      FMaxNumber := A[6].ToInteger;
    finally
      Free;
    end;

  OK(Format('Part 1: %d, Part 2: %d', [ GetHighScore(FMaxNumber), GetHighScore(FMaxNumber * 100) ]));
end;

function TTask_AoC.GetHighScore(const MaxNumber: Integer): Int64;
var
  Players: TArray<Int64>;
  Marbles: PNode;
  I, CurrentPlayer: Integer;
begin
  SetLength(Players, FPlayerCount);

  Marbles := TNode.Pointer(0);
  Marbles := Marbles.Push(1);
  CurrentPlayer := 1;

  for I := 2 to MaxNumber do
    if I mod 23 = 0 then
      begin
        Inc(Players[CurrentPlayer], I);
        Marbles := Marbles.Rotate(-7);
        Inc(Players[CurrentPlayer], Marbles.Data);
        Marbles := Marbles.Pop.Rotate(1);
        CurrentPlayer := (CurrentPlayer + 1) mod FPlayerCount;
      end
    else
      begin
        Marbles := Marbles.Rotate(1);
        Marbles := Marbles.Push(I);
        CurrentPlayer := (CurrentPlayer + 1) mod FPlayerCount;
      end;

  Marbles.Free;

  Result := 0;
  for I := 0 to FPlayerCount - 1 do
    if Result < Players[I] then
      Result := Players[I];
end;

function TTask_AoC.GetHighScoreSlow(const MaxNumber: Integer): Integer;
var
  Players: TArray<Integer>;
  I, CurrentPlayer, CurrentPos: Integer;
  Marbles: TList<Integer>;
begin
  SetLength(Players, FPlayerCount);

  Marbles := TList<Integer>.Create;
  Marbles.Add(0);
  Marbles.Add(1);

  try
    CurrentPlayer := 1;
    CurrentPos := 1;
    for I := 2 to MaxNumber do
      if I mod 23 <> 0 then
        begin
          CurrentPos := (CurrentPos + 2);
          if CurrentPos > Marbles.Count then
            CurrentPos := CurrentPos mod Marbles.Count;
          Marbles.Insert(CurrentPos, I);
          CurrentPlayer := (CurrentPlayer + 1) mod FPlayerCount;
        end
      else
        begin
          Inc(Players[CurrentPlayer], I);
          CurrentPos := (CurrentPos + Marbles.Count - 7) mod Marbles.Count;
          Inc(Players[CurrentPlayer], Marbles[CurrentPos]);
          Marbles.Delete(CurrentPos);
          CurrentPlayer := (CurrentPlayer + 1) mod FPlayerCount;
        end;

    Result := 0;
    for I := 0 to FPlayerCount - 1 do
      if Result < Players[I] then
        Result := Players[I];
  finally
    Marbles.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 9, 'Marble Mania');

finalization
  GTask.Free;

end.
