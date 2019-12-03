unit uTask_2018_13;

interface

uses
  System.Types, uTask, uCarts_2018_13;

type
  TTask_AoC = class (TTask)
  private
    FMapWidth, FMapHeight: Integer;
    FMap: TMap;
    FCarts: TCarts;
    procedure LoadMap;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uForm_2018_13;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadMap;

  fMain_2018_13 := TfMain_2018_13.Create(nil);

  try
    fMain_2018_13.SetMapSize(FMapWidth, FMapHeight);
    fMain_2018_13.Map := FMap;
    fMain_2018_13.Carts := FCarts;
    FCarts.OnStepCarts := fMain_2018_13.StepCarts;
    fMain_2018_13.Show;

    while FCarts.StepCarts do;
    OK('Part 1: %d,%d, Part 2: %d, %d', [ FCarts.Collision.X, FCarts.Collision.Y, FCarts[0].Pos.X, FCarts[0].Pos.Y ])
  finally
    fMain_2018_13.Map := nil;
    fMain_2018_13.Carts := nil;
    FMap.Free;
    FCarts.Free;
  end;
end;

procedure TTask_AoC.LoadMap;
var
  X, Y: Integer;
begin
  FMap := TMap.Create;
  FCarts := TCarts.Create;

  with Input do
    try
      FMapWidth := Strings[0].Length;
      FMapHeight := Count;
      for Y := 0 to Count - 1 do
        for X := 0 to Strings[Y].Length - 1 do
          case Strings[Y][X + 1] of
            '-':
              FMap.Add(TPoint.Create(X, Y), piHorizontal);
            '|':
              FMap.Add(TPoint.Create(X, Y), piVertical);
            '+':
              FMap.Add(TPoint.Create(X, Y), piIntersection);
            '/':
              if AnsiChar(Strings[Y][X + 2]) in [ '-', '+' ] then
                FMap.Add(TPoint.Create(X, Y), piCornerUL)
              else
                FMap.Add(TPoint.Create(X, Y), piCornerBR);
            '\':
              if AnsiChar(Strings[Y][X + 2]) in [ '-', '+' ] then
                FMap.Add(TPoint.Create(X, Y), piCornerBL)
              else
                FMap.Add(TPoint.Create(X, Y), piCornerUR);
            '>','<':
              begin
                FMap.Add(TPoint.Create(X, Y), piHorizontal);
                if Strings[Y][X + 1] = '>' then
                  FCarts.Add(TCart.Create(FMap, X, Y, cdRight))
                else
                  FCarts.Add(TCart.Create(FMap, X, Y, cdLeft));
              end;
            '^','v':
              begin
                FMap.Add(TPoint.Create(X, Y), piVertical);
                if Strings[Y][X + 1] = '^' then
                  FCarts.Add(TCart.Create(FMap, X, Y, cdUp))
                else
                  FCarts.Add(TCart.Create(FMap, X, Y, cdDown));
              end;
          end;
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 13, 'Mine Cart Madness');

finalization
  GTask.Free;

end.
