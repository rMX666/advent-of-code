unit uForm_2019_08;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uTask_2019_08;

type
  TfForm_2019_08 = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
  private
    FLayer: TLayer;
  public
    procedure DrawLayer(const Layer: TLayer);
  end;

var
  fForm_2019_08: TfForm_2019_08;

implementation

{$R *.dfm}

procedure TfForm_2019_08.DrawLayer(const Layer: TLayer);
begin
  FLayer := Layer;
end;

procedure TfForm_2019_08.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfForm_2019_08.FormPaint(Sender: TObject);
var
  I, J: Integer;
begin
  for I := 0 to FLayer.Count - 1 do
    for J := 1 to FLayer[I].Length do
      with Canvas do
        begin
          case FLayer[I][J] of
            '0': Brush.Color := clBlack;
            '1': Brush.Color := clWhite;
            '2': Brush.Color := clRed;
          end;
          FillRect(TRect.Create((J - 1) * 10, I * 10, J * 10, (I + 1) * 10));
        end;
end;

end.
