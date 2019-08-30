unit uTask_2017_07;

interface

uses
  uTask;

type
  PNode = ^TNode;
  TNode = record
    Name: String;
    Weight, FullWeight: Integer;
    Names: TArray<String>;
    Parent: PNode;
    Children: TArray<PNode>;
    class function Pointer(const S: String): PNode; static;
    function Ready: Boolean;
    function HasChildren: Boolean;
    function GetDisbalanced: PNode;
    function GetFullWeight: Integer;
    procedure Free;
  end;

  TTask_AoC = class (TTask)
  private
    FRoot: PNode;
    procedure BuildTree;
    function FindDisbalanced: PNode;
    function FindCorrectWeight: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.Generics.Collections,  System.RegularExpressions, System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TNode }

procedure TNode.Free;
var
  I: Integer;
begin
  for I := 0 to Length(Children) - 1 do
    Children[I].Free;
  SetLength(Children, 0);
  SetLength(Names, 0);
  Parent := nil;
  Name := '';
  Dispose(@Self);
end;

function TNode.Ready: Boolean;
begin
  Result := (Length(Names) = 0) or (Length(Names) = Length(Children));
end;

function TNode.GetDisbalanced: PNode;

  function Scrabble(const Weight, I: Integer): Integer;
  begin
    Result := (Weight shl 3) or I;
  end;

  function GetWeight(const Scrabbled: Integer): Integer;
  begin
    Result := Scrabbled shr 3;
  end;

  function GetI(const Scrabbled: Integer): Integer;
  begin
    Result := Scrabbled and 7;
  end;

var
  Weights: TArray<Integer>;
  I, L: Integer;
begin
  L := Length(Children);
  SetLength(Weights, L);
  for I := 0 to L - 1 do
    Weights[I] := Scrabble(Children[I].GetFullWeight, I);

  TArray.Sort<Integer>(Weights);
  if GetWeight(Weights[0]) <> GetWeight(Weights[1]) then
    Result := Children[GetI(Weights[0])]
  else
    Result := Children[GetI(Weights[L - 1])];
end;

function TNode.GetFullWeight: Integer;
var
  Node: PNode;
  I: Integer;
begin
  Result := Weight;
  Node := @Self;
  if Length(Node.Children) > 0 then
    for I := 0 to Length(Node.Children) - 1 do
      Inc(Result, Node.Children[I].GetFullWeight);
  FullWeight := Result;
end;

function TNode.HasChildren: Boolean;
begin
  Result := Length(Children) > 0;
end;

class function TNode.Pointer(const S: String): PNode;
var
  Node: PNode;
begin
  New(Node);
  with TRegEx.Match(S, '^([a-z]+) \(([0-9]+)\)( -> ([a-z ,]+))?$') do
    begin
      Node.Name := Groups[1].Value;
      Node.Weight := Groups[2].Value.ToInteger;
      if Groups.Count > 3 then
        Node.Names := Groups[4].Value.Split([', ']);
    end;
  Node.Parent := nil;
  Result := Node;
end;

{ TTask_AoC }

procedure TTask_AoC.BuildTree;
var
  Nodes: TDictionary<String,PNode>;
  Node, Child: PNode;
  I: Integer;
begin
  Nodes := TDictionary<String,PNode>.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          Node := TNode.Pointer(Strings[I]);
          Nodes.Add(Node.Name, Node);
        end;

      for Node in Nodes.Values do
        if not Node.Ready then
          begin
            SetLength(Node.Children, Length(Node.Names));
            for I := 0 to Length(Node.Names) - 1 do
              begin
                Child := Nodes[Node.Names[I]];
                Child.Parent := Node;
                Node.Children[I] := Child;
              end;
          end;

      for Node in Nodes.Values do
        if Node.Parent = nil then
          begin
            FRoot := Node;
            Break;
          end;
    finally
      Free;
      Nodes.Free;
    end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    BuildTree;

    OK(Format('Part 1: %s, Part 2: %d', [ FRoot.Name, FindCorrectWeight ]));
  finally
    FRoot.Free;
  end;
end;

function TTask_AoC.FindCorrectWeight: Integer;
var
  Node: PNode;
  Siblings: TArray<PNode>;
  I: Integer;
begin
  Node := FindDisbalanced.Parent;
  Siblings := Node.Parent.Children;
  Result := -1;
  for I := 0 to Length(Siblings) - 1 do
    if Siblings[I] <> Node then
      Exit(Node.Weight + Siblings[I].FullWeight - Node.FullWeight);
end;

function TTask_AoC.FindDisbalanced: PNode;
begin
  Result := FRoot.GetDisbalanced;

  while Result.HasChildren do
    Result := Result.GetDisbalanced;
end;

initialization
  GTask := TTask_AoC.Create(2017, 7, 'Recursive Circus');

finalization
  GTask.Free;

end.
