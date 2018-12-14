unit uForm_2018_13;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
  uCarts_2018_13;

type
  TfMain_2018_13 = class(TForm)
    sgMap: TDrawGrid;
    procedure sgMapDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FStep: Integer;
    FMap: TMap;
    FCarts: TCarts;
    function GetCart(const P: TPoint): TCart;
  public
    procedure StepCarts(Sender: TObject);
    procedure SetMapSize(const X, Y: Integer);
    property Map: TMap read FMap write FMap;
    property Carts: TCarts read FCarts write FCarts;
    property Cart[const P: TPoint]: TCart read GetCart;
  end;

var
  fMain_2018_13: TfMain_2018_13;

implementation

{$R *.dfm}

{ TfMain_2018_13 }

procedure TfMain_2018_13.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

function TfMain_2018_13.GetCart(const P: TPoint): TCart;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FCarts.Count - 1 do
    if FCarts[I].Pos = P then
      Exit(FCarts[I]);
end;

procedure TfMain_2018_13.SetMapSize(const X, Y: Integer);
begin
  sgMap.ColCount := X;
  sgMap.RowCount := Y;
  FStep := 0;
end;

procedure TfMain_2018_13.sgMapDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  P: TPoint;
  Cart: TCart;
begin
  if not Assigned(FMap) then
    Exit;

  P.X := ACol;
  P.Y := ARow;
  if not FMap.ContainsKey(P) then
    Exit;

  Cart := Self.Cart[P];

  with TDrawGrid(Sender) do
    begin
      if FCarts.Collisions.Contains(P) then
        Canvas.Brush.Color := clBlack
      else if Cart = nil then
        Canvas.Brush.Color := clWebLightBlue
      else
        Canvas.Brush.Color := clRed;

      Canvas.FillRect(Rect);
    end;
end;

procedure TfMain_2018_13.StepCarts(Sender: TObject);
begin
//  if FStep mod 50 = 0 then
    begin
      sgMap.Repaint;
      Application.ProcessMessages;
    end;
  Inc(FStep);
end;

end.
