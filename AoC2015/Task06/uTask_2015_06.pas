unit uTask_2015_06;

interface

uses
  uTask, System.Types, System.Generics.Collections;

type
  TLightGridAction = ( lgaTurnOn, lgaTurnOff, lgaToggle );
  TRule = record
    LeftTop, RightBottom: TPoint;
    Action: TLightGridAction;
    constructor Create(const S: String);
  end;

  TRules = TList<TRule>;
  TLightGrid = TDictionary<TPoint, Integer>;

  TTask_AoC = class (TTask)
  private
    FLightGrid: TLightGrid;
    FRules: TRules;
    procedure InitializeLightGrid;
    procedure InitializeRules;
    function CalculateGrid(const Part: Integer): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TRule }

{
turn on 0,0 through 999,999
toggle 0,0 through 999,0
turn off 499,499 through 500,500
}
constructor TRule.Create(const S: String);

  function ParsePoint(const S: String): TPoint;
  var
    Point: TArray<String>;
  begin
    Point := S.Split([',']);
    Result.X := StrToInt(Point[0]);
    Result.Y := StrToInt(Point[1]);
  end;

var
  Rule: TArray<String>;
begin
  Rule := S.Split([' ']);
  if Rule[0] = 'toggle' then
    begin
      Action := lgaToggle;
      LeftTop := ParsePoint(Rule[1]);
      RightBottom := ParsePoint(Rule[3]);
    end
  else
    begin
      if Rule[1] = 'on' then
        Action := lgaTurnOn
      else
        Action := lgaTurnOff;
      LeftTop := ParsePoint(Rule[2]);
      RightBottom := ParsePoint(Rule[4]);
    end;
end;

{ TTask_AoC }

function TTask_AoC.CalculateGrid(const Part: Integer): Integer;

  procedure ApplyRule(const Rule: TRule);
  var
    I, J: Integer;
    Point: TPoint;
  begin
    for I := Rule.LeftTop.X to Rule.RightBottom.X do
      for J := Rule.LeftTop.Y to Rule.RightBottom.Y do
        begin
          Point := TPoint.Create(I, J);
          case Rule.Action of
            lgaTurnOn:
              if Part = 1 then
                FLightGrid[Point] := 1
              else
                FLightGrid[Point] := FLightGrid[Point] + 1;
            lgaTurnOff:
              if Part = 1 then
                FLightGrid[TPoint.Create(I, J)] := 0
              else
                if FLightGrid[Point] > 0 then
                  FLightGrid[Point] := FLightGrid[Point] - 1;
            lgaToggle:
              if Part = 1 then
                if FLightGrid[Point] = 1 then
                  FLightGrid[Point] := 0
                else
                  FLightGrid[Point] := 1
              else
                FLightGrid[Point] := FLightGrid[Point] + 2;
          end;
        end;
  end;

var
  I: Integer;
begin
  Result := 0;

  try
    InitializeLightGrid;

    for I := 0 to FRules.Count - 1 do
      ApplyRule(FRules[I]);

    for I in FLightGrid.Values do
      Inc(Result, I);
  finally
    if Assigned(FLightGrid) then
      FreeAndNil(FLightGrid);
  end;
end;

procedure TTask_AoC.DoRun;
begin
  try
    InitializeRules;

    Ok(Format('Part 1: %d, Part 2: %d', [ CalculateGrid(1), CalculateGrid(2) ]));
  finally
    FreeAndNil(FRules);
  end;
end;

procedure TTask_AoC.InitializeLightGrid;
var
  I, J: Integer;
begin
  FLightGrid := TLightGrid.Create(1000000);
  for I := 0 to 999 do
    for J := 0 to 999 do
      FLightGrid.Add(TPoint.Create(I, J), 0);
end;

procedure TTask_AoC.InitializeRules;
var
  I: Integer;
begin
  FRules := TRules.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FRules.Add(TRule.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2015, 6, 'Probably a Fire Hazard');

finalization
  GTask.Free;

end.
