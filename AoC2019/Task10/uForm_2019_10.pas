unit uForm_2019_10;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
  uTask_2019_10;

type
  TfForm_2019_10 = class(TForm)
    sgMap: TDrawGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgMapSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure sgMapDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
  private
    FMap: TMap;
    FLaserPosition: TPoint;
    FSightCache: TSightCache;
  public
    procedure DrawMap(const Map: TMap; const LaserPosition: TPoint);
  end;

var
  fForm_2019_10: TfForm_2019_10;

implementation

{$R *.dfm}

{ TfForm_2019_10 }

procedure TfForm_2019_10.DrawMap(const Map: TMap; const LaserPosition: TPoint);
begin
  FMap := Map;
  FLaserPosition := LaserPosition;

  sgMap.ColCount := FMap.Width;
  sgMap.RowCount := FMap.Height;
  ClientWidth  := FMap.Width  * sgMap.DefaultColWidth  + FMap.Width  * 2;
  ClientHeight := FMap.Height * sgMap.DefaultRowHeight + FMap.Height * 2;
end;

procedure TfForm_2019_10.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfForm_2019_10.sgMapDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  BgColor: TColor;
  P: TPoint;
begin
  if not FMap.IsAsteroid[ACol, ARow] then
    Exit;

  BgColor := clWhite;
  P := TPoint.Create(ACol, ARow);
  if FSightCache <> nil then
    if FSightCache.ContainsKey(P) and FSightCache[P] then
      BgColor := clWebLightBlue;

  if FMap.IsEvaporated[ACol, ARow] then
    BgColor := clWebLightYellow;

  if P = FLaserPosition then
    BgColor := clRed;

  with sgMap.Canvas do
    begin
      Brush.Color := BgColor;
      FillRect(Rect);

      TextOut(Rect.Left + 2, Rect.Top + 2, FMap.InSight[ACol, ARow].ToString);
    end;
end;

procedure TfForm_2019_10.sgMapSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := True;
  FSightCache := nil;

  if not FMap.IsAsteroid[ACol, ARow] then
    Exit;

  FSightCache := FMap.SightCache[ACol, ARow];
  sgMap.Invalidate;
end;

end.
