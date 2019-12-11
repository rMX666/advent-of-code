unit uForm_2019_11;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uTask_2019_11;

type
  TfForm_2019_11 = class(TForm)
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FMap: TMap;
    FTopLeft: TPoint;
    FPixelSize: Integer;
  public
    procedure DrawMap(const Map: TMap);
  end;

var
  fForm_2019_11: TfForm_2019_11;

implementation

{$R *.dfm}

procedure TfForm_2019_11.DrawMap(const Map: TMap);
var
  Key: TPoint;
begin
  FMap := Map;

  FPixelSize := 8;
  FTopLeft := TPoint.Create(1000000, 1000000);
  for Key in FMap.Keys do
    begin
      if FTopLeft.X > Key.X then FTopLeft.X := Key.X;
      if FTopLeft.Y > Key.Y then FTopLeft.Y := Key.Y;
    end;

  Invalidate;
end;

procedure TfForm_2019_11.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfForm_2019_11.FormPaint(Sender: TObject);
var
  Key, P: TPoint;
begin
  if FMap = nil then
    Exit;

  for Key in FMap.Keys do
    begin
      case FMap[Key].Color of
        0: Canvas.Brush.Color := clBlack;
        1: Canvas.Brush.Color := clWhite;
      end;
      P := Key - FTopLeft;
      Canvas.FillRect(TRect.Create(P.X * FPixelSize, P.Y * FPixelSize, (P.X + 1) * FPixelSize, (P.Y + 1) * FPixelSize));
    end;
end;

end.
