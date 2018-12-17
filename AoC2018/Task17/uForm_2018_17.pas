unit uForm_2018_17;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uWater_2018_17, Vcl.Grids;

type
  TfMain_2018_17 = class(TForm)
    sgMap: TDrawGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgMapDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure sgMapMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure sgMapMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
  private
    FMap: TMap;
  public
    procedure SetMap(const AMap: TMap);
    procedure DoOnSimulationStep(Sender: TObject);
  end;

var
  fMain_2018_17: TfMain_2018_17;

implementation

{$R *.dfm}

procedure TfMain_2018_17.DoOnSimulationStep(Sender: TObject);
begin
  sgMap.Invalidate;
  Application.ProcessMessages;
end;

procedure TfMain_2018_17.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FMap) then
    FreeAndNil(FMap);
  Action := caFree;
end;

procedure TfMain_2018_17.SetMap(const AMap: TMap);
begin
  FMap := AMap;
  sgMap.ColCount := FMap.Bounds.Width;
  sgMap.RowCount := FMap.Bounds.Height;
end;

procedure TfMain_2018_17.sgMapDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if not Assigned(FMap) then
    Exit;

  if not FMap.Exists(ACol, ARow) then
    Exit;

  with TDrawGrid(Sender) do
    begin
      case FMap[ACol, ARow] of
        stSand:
          Canvas.Brush.Color := clWebLightYellow;
        stClay:
          Canvas.Brush.Color := clWebBrown;
        stWaterSource:
          Canvas.Brush.Color := clBlack;
        stWater:
          Canvas.Brush.Color := clBlue;
        stWetSand:
          Canvas.Brush.Color := clWebLightSkyBlue;
      end;
      Canvas.FillRect(Rect);
    end;
end;

procedure TfMain_2018_17.sgMapMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
begin
  if ssCtrl in Shift then
    with TDrawGrid(Sender) do
      begin
        DefaultColWidth := DefaultColWidth - 1;
        DefaultRowHeight := DefaultRowHeight - 1;
        Handled := True;
      end;
end;

procedure TfMain_2018_17.sgMapMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
    with TDrawGrid(Sender) do
      begin
        DefaultColWidth := DefaultColWidth + 1;
        DefaultRowHeight := DefaultRowHeight + 1;
        Handled := True;
      end;
end;

end.
