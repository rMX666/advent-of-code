unit uTask_2018_17;

interface

uses
  uTask, uWater_2018_17;

type
  TTask_AoC = class (TTask)
  private
    FMap: TMap;
    procedure LoadMap;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Types, System.Generics.Collections, System.Math, System.Classes, uForm_2018_17;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadMap;

    fMain_2018_17 := TfMain_2018_17.Create(nil);
    fMain_2018_17.SetMap(FMap);
    FMap.OnSimulationStep := fMain_2018_17.DoOnSimulationStep;
    fMain_2018_17.Show;
    FMap.Simulate;

    OK(Format('Part 1: %d, Part 2: %d', [ FMap.CountOf([ stWater, stWetSand ]), FMap.CountOf([ stWater ]) ]));
  finally
    if Assigned(fMain_2018_17) and not fMain_2018_17.Visible then
      FMap.Free;
  end;
end;

procedure TTask_AoC.LoadMap;
var
  I, X, Y: Integer;
  Rect: TRect;
  Clay: TList<TPoint>;
  A: TArray<String>;

  procedure AddClay(const X, Y: Integer);
  begin
    Clay.Add(TPoint.Create(X, Y));
    if Rect.Left > X then
      Rect.Left := X;
    if Rect.Top > Y then
      Rect.Top := Y;
    if Rect.Right < X then
      Rect.Right := X;
    if Rect.Bottom < Y then
      Rect.Bottom := Y;
  end;

begin
  Clay := TList<TPoint>.Create;

  Rect := TRect.Empty;
  Rect.Left := MaxInt;
  Rect.Top := MaxInt;

  try
    with Input do
      try
        for I := 0 to Count - 1 do
          begin
            A := Strings[I].Replace('x=', '').Replace('y=', '').Replace(',', '').Replace('..', ' ').Split([' ']);
            if Strings[I].StartsWith('x=') then
              begin
                X := A[0].ToInteger;
                for Y := A[1].ToInteger to A[2].ToInteger do
                  AddClay(X, Y);
              end
            else
              begin
                Y := A[0].ToInteger;
                for X := A[1].ToInteger to A[2].ToInteger do
                  AddClay(X, Y);
              end;
          end;
      finally
        Free;
      end;

    Dec(Rect.Top, 1);
    Dec(Rect.Left, 2);
    Inc(Rect.Right, 2);
    Inc(Rect.Bottom, 2);
    FMap := TMap.Create(Rect);
    for I := 0 to Clay.Count - 1 do
      FMap[Clay[I].X - Rect.Left, Clay[I].Y - Rect.Top] := stClay;
    FMap[500 - Rect.Left, 0] := stWaterSource;
  finally
    Clay.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 17, 'Reservoir Research');

finalization
  GTask.Free;

end.
