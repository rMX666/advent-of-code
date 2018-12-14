unit uTask_2018_14;

interface

uses
  System.Generics.Collections, uTask;

type
  //TRecipes = TList<Byte>;

  TTask_AoC = class (TTask)
  private
    FLastRecipe: Integer;
    procedure StepRecipes(var Recipes: String; var Elf1, Elf2: Int64);
    function GetRecipeScore(const Last: Integer): String;
    function GetRecipeCountBefore(const Last: Integer): Int64;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      FLastRecipe := Text.Trim.ToInteger;
    finally
      Free;
    end;

  OK(Format('Part 1: %s, Part 2: %d', [ GetRecipeScore(FLastRecipe), GetRecipeCountBefore(FLastRecipe) ]));
end;

function TTask_AoC.GetRecipeCountBefore(const Last: Integer): Int64;
var
  LastS: String;
  Recipes: String;
  Elf1, Elf2: Int64;
begin
  LastS := Last.ToString;
  Recipes := '37';
  Elf1 := 0;
  Elf2 := 1;

  // We can add either 1 or 2 recipes to the end, so we need to check whether we have digit sequence
  // in the end of the string and one digit before end
  while not (Recipes.EndsWith(LastS) or Recipes.EndsWith(LastS + Recipes[Recipes.Length])) do
    StepRecipes(Recipes, Elf1, Elf2);

  Result := Recipes.IndexOf(LastS);
end;

function TTask_AoC.GetRecipeScore(const Last: Integer): String;
var
  Recipes: String;
  Elf1, Elf2: Int64;
begin
  Recipes := '37';
  Elf1 := 0;
  Elf2 := 1;

  while Recipes.Length <= Last + 10 do
    StepRecipes(Recipes, Elf1, Elf2);

  Result := Recipes.Substring(Last, 10);
end;

procedure TTask_AoC.StepRecipes(var Recipes: String; var Elf1, Elf2: Int64);
var
  Val1, Val2, NextRecipe: Byte;
begin
  Val1 := String(Recipes[Elf1 + 1]).ToInteger;
  Val2 := String(Recipes[Elf2 + 1]).ToInteger;
  NextRecipe := Val1 + Val2;
  if NextRecipe >= 10 then
    Recipes := Recipes + (NextRecipe div 10).ToString + (NextRecipe mod 10).ToString
  else
    Recipes := Recipes + NextRecipe.ToString;

  Elf1 := (Elf1 + Val1 + 1) mod Recipes.Length;
  Elf2 := (Elf2 + Val2 + 1) mod Recipes.Length;
end;

initialization
  GTask := TTask_AoC.Create(2018, 14, 'Chocolate Charts');

finalization
  GTask.Free;

end.
