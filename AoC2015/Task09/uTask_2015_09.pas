unit uTask_2015_09;

interface

uses
  uTask, System.Types, System.Generics.Collections;

type
  TNode = record
    Start, Finish: String;
    Cost: Integer;
    constructor Create(const S: String);
    function Clone(const NewCost: Integer): TNode;
  end;

  TGraph = TDictionary<TPoint, TNode>;
  TLocations = TList<String>;

  TTask_AoC = class (TTask)
  private
    FGraph: TGraph;
    FLocations: TLocations;
  protected
    procedure DoRun; override;
  public
    property Graph: TGraph read FGraph;
    property Locations: TLocations read FLocations;
  end;

implementation

uses
  System.SysUtils, uUtil, uForm_2015_09;

var
  GTask: TTask_AoC;

{ TNode }

function TNode.Clone(const NewCost: Integer): TNode;
begin
  Result.Start := Start;
  Result.Finish := Finish;
  if NewCost < 0 then
    Result.Cost := Cost
  else
    Result.Cost := NewCost;
end;

constructor TNode.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Split([' ']);

  Start := A[0];
  Finish := A[2];
  Cost := StrToInt(A[4]);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;

var
  Form: TfForm_2015_09;

  procedure AddLocation(const S: String);
  begin
    if not FLocations.Contains(S) then
      FLocations.Add(S);
  end;

  function GetLocation(const S: String): Integer;
  begin
    AddLocation(S);
    Result := FLocations.IndexOf(S);
  end;

  procedure AddToGraph(const Node: TNode);

    procedure Add(const Node: TNode; const Point: TPoint);
    begin
      if not FGraph.ContainsKey(Point) then
        FGraph.Add(Point, Node);
    end;

  var
    X, Y: Integer;
  begin
    X := GetLocation(Node.Start);
    Y := GetLocation(Node.Finish);

    Add(Node, TPoint.Create(X, Y));
    Add(Node.Clone(-1), TPoint.Create(Y, X));
    Add(Node.Clone(0), TPoint.Create(X, X));
    Add(Node.Clone(0), TPoint.Create(Y, Y));
  end;

  procedure FindBestPath(out MinPath, MaxPath: Integer);
  var
    MinPathA, MaxPathA, NextPath: TPermutationItems;
    L, J, PathLength, MinPathI, MaxPathI: Integer;
    Permutations: TPermutations;
  begin
    L := FLocations.Count;

    MinPathI := MaxInt;
    MaxPathI := 0;

    Permutations := TPermutations.Create(L);
    try
      for NextPath in Permutations do
        begin
          PathLength := 0;
          for J := 0 to L - 2 do
            Inc(PathLength, FGraph[TPoint.Create(NextPath[J], NextPath[J + 1])].Cost);

          if PathLength < MinPathI then
            begin
              MinPathI := PathLength;
              MinPathA := Copy(NextPath, 0, L);
            end;
          if PathLength > MaxPathI then
            begin
              MaxPathI := PathLength;
              MaxPathA := Copy(NextPath, 0, L);
            end;
        end;
    finally
      Permutations.Free;
    end;

    MinPath := MinPathI;
    MaxPath := MaxPathI;

    Form.HighLightPath(MinPathA, True);
    Form.HighLightPath(MaxPathA, False);
  end;

var
  MinPath, MaxPath: Integer;
  I: Integer;
begin
  MinPath := MaxInt;
  MaxPath := 0;

  FGraph := TGraph.Create;
  FLocations := TLocations.Create;
  Form := TfForm_2015_09.Create(nil);
  Form.SetTask(Self);
  with Input do
    try
      for I := 0 to Count - 1 do
        AddToGraph(TNode.Create(Strings[I]));

      Form.DrawGraph;

      FindBestPath(MinPath, MaxPath);

      Form.ShowModal;

      Ok(Format('Part 1: %d, Part 2: %d', [ MinPath, MaxPath ]));
    finally
      FLocations.Free;
      FGraph.Free;
      Form.Free;
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 9, 'All in a Single Night');

finalization
  GTask.Free;

end.
