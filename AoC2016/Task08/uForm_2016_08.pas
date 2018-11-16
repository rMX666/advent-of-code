unit uForm_2016_08;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTask_2016_08;

type
  TfMain_2016_08 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
    procedure DrawDisplay(const Display: TDisplay);
  end;

var
  fMain_2016_08: TfMain_2016_08;

implementation

{$R *.dfm}

procedure TfMain_2016_08.DrawDisplay(const Display: TDisplay);
var
  I, J: Integer;
begin
  Canvas.Brush.Color := clBlack;
  Canvas.FillRect(ClientRect);

  Canvas.Brush.Color := clWhite;
  for I := 1 to DISPLAY_WIDTH do
    for J := 1 to DISPLAY_HEIGHT do
      if Display[I, J] then
        Canvas.FillRect(TRect.Create((I - 1) * 16, (J - 1) * 16, I * 16, J * 16));

  Application.ProcessMessages;
  Sleep(10);
end;

procedure TfMain_2016_08.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfMain_2016_08.FormCreate(Sender: TObject);
begin
  ClientWidth := DISPLAY_WIDTH * 16;
  ClientHeight := DISPLAY_HEIGHT * 16;
end;

end.
