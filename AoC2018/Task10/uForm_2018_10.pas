unit uForm_2018_10;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uStars_2018_10;

type
  TfMain_2018_10 = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormPaint(Sender: TObject);
  private
    FStars: TStars;
  public
    property Stars: TStars read FStars write FStars;
  end;

var
  fMain_2018_10: TfMain_2018_10;

implementation

{$R *.dfm}

procedure TfMain_2018_10.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfMain_2018_10.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ' ' then
    begin
      FStars.Step(ClientRect);
      Repaint;
    end
  else if Key = #27 then
    Application.MessageBox(PWideChar(FStars.StepsDone.ToString), nil, MB_OK or MB_ICONINFORMATION)
end;

procedure TfMain_2018_10.FormPaint(Sender: TObject);
var
  I: Integer;
begin
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(ClientRect);
  for I := 0 to FStars.Count - 1 do
    with FStars[I].Position do
      Canvas.Pixels[X, Y] := clBlack;
end;

end.
