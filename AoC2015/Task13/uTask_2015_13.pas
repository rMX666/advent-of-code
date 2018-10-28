unit uTask_2015_13;

interface

uses
  uTask, System.Generics.Collections;

type
  TRelation = String;
  TGraph = TDictionary<TRelation, Integer>;
  TPersons = TList<String>;

  TTask_AoC = class (TTask)
  private
    FRelationGraph: TGraph;
    FPersons: TPersons;
    procedure LoadRelationGraph;
    procedure AddMyselfToRelations;
    function FindBestSeating: Integer;
    function GetRelationCost(const Person1, Person2: String): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uUtil;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.AddMyselfToRelations;
var
  I: Integer;
begin
  for I := 0 to FPersons.Count - 1 do
    begin
      FRelationGraph.Add('Me/' + FPersons[I], 0);
      FRelationGraph.Add(FPersons[I] + '/Me', 0);
    end;

  FPersons.Add('Me');
end;

procedure TTask_AoC.DoRun;
var
  Part1, Part2: Integer;
begin
  LoadRelationGraph;

  try
    Part1 := FindBestSeating;

    AddMyselfToRelations;

    Part2 := FindBestSeating;

    OK(Format('Part 1: %d, Part 2: %d', [ Part1, Part2 ]));
  finally
    FRelationGraph.Free;
    FPersons.Free;
  end;
end;

function TTask_AoC.FindBestSeating: Integer;
var
  BestHappiness: Integer;
begin
  BestHappiness := 0;

  RunPermutations(FPersons.Count, procedure (const Seating: TArray<Integer>)
    var
      I, NextI, Happiness: Integer;
    begin
      Happiness := 0;

      for I := 0 to FPersons.Count - 1 do
        begin
          NextI := I + 1;
          if NextI = FPersons.Count then
            NextI := 0;

          Inc(Happiness, GetRelationCost(FPersons[Seating[I]], FPersons[Seating[NextI]]));
          Inc(Happiness, GetRelationCost(FPersons[Seating[NextI]], FPersons[Seating[I]]));
        end;
      if Happiness > BestHappiness then
        BestHappiness := Happiness;
    end);

  Result := BestHappiness;
end;

function TTask_AoC.GetRelationCost(const Person1, Person2: String): Integer;
begin
  Result := FRelationGraph[Person1 + '/' + Person2];
end;

procedure TTask_AoC.LoadRelationGraph;

  procedure AppendPerson(const Person: String);
  begin
    if not FPersons.Contains(Person) then
      FPersons.Add(Person);
  end;

  procedure AppendRelation(const S: String);
  var
    A: TArray<String>;
    Person1, Person2: String;
    Cost: Integer;
  begin
    A := S.Replace('.', '').Split([' ']);
    Person1 := A[0];
    Person2 := A[10];
    Cost := A[3].ToInteger;
    if A[2] = 'lose' then
      Cost := -Cost;
    FRelationGraph.Add(Person1 + '/' + Person2, Cost);

    AppendPerson(Person1);
    AppendPerson(Person2);
  end;

var
  I: Integer;
begin
  FRelationGraph := TGraph.Create;
  FPersons := TPersons.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        AppendRelation(Strings[I]);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 13, 'Knights of the Dinner Table');

finalization
  GTask.Free;

end.
