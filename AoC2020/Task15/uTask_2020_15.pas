unit uTask_2020_15;

interface

uses
  System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FStartSequence: TList<Integer>;
    procedure LoadStartSequence;
    function GetNthNumber(const N: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadStartSequence;
    Ok('Part 1: %d, Part 2: %d', [ GetNthNumber(2020), GetNthNumber(30000000) ]);
  finally
    FStartSequence.Free;
  end;
end;

function TTask_AoC.GetNthNumber(const N: Integer): Integer;

  procedure AddIndex(const List: TList<Integer>; const Index: Integer);
  begin
    List.Add(Index);
    if List.Count > 2 then
      List.Delete(0);
  end;

var
  Seq, L: TList<Integer>;
  I, X: Integer;
  Indices: TObjectDictionary<Integer,TList<Integer>>;

  procedure AddIndexToCache(const X, Index: Integer);
  begin
    if Indices.ContainsKey(X) then
      AddIndex(Indices[X], Index)
    else
      begin
        Indices.Add(X, TList<Integer>.Create);
        Indices[X].Add(Index);
      end;
  end;

begin
  Indices := TObjectDictionary<Integer,TList<Integer>>.Create([doOwnsValues]);
  Seq := TList<Integer>.Create(FStartSequence);
  try
    for I := 0 to N - 1 do
      if Seq.Count > I then
        AddIndexToCache(Seq[I], I)
      else
        begin
          X := Seq.Last;
          if Indices.ContainsKey(X) then
            begin
              if Indices[X].Count = 1 then
                begin
                  X := 0;
                  Seq.Add(X);
                  AddIndex(Indices[X], I);
                end
              else
                begin
                  X := Indices[X].Last - Indices[X].First;
                  Seq.Add(X);
                  AddIndexToCache(X, I);
                end;
            end;
        end;
    Result := Seq.Last;
  finally
    Seq.Free;
    Indices.Free;
  end;
end;

procedure TTask_AoC.LoadStartSequence;
var
  A: TArray<String>;
  I: Integer;
begin
  FStartSequence := TList<Integer>.Create;
  with Input do
    try
      A := Text.Trim.Split([',']);
      for I := 0 to Length(A) - 1 do
        FStartSequence.Add(A[I].ToInteger);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 15, 'Rambunctious Recitation');

finalization
  GTask.Free;

end.
