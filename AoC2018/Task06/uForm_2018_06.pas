unit uForm_2018_06;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfMain_2018_06 = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    procedure DrawAreas(Sender: TObject);
  end;

var
  fMain_2018_06: TfMain_2018_06;

implementation

uses
  uTask_2018_06;

{$R *.dfm}

procedure TfMain_2018_06.DrawAreas(Sender: TObject);
var
  I: Integer;
  Key: TPoint;
begin
  Application.ProcessMessages;
  with TAreas(Sender) do
    for I := 0 to Count - 1 do
      begin
        for Key in Items[I].Visited.Keys do
          if Items[I].Infinite then
            Canvas.Pixels[Key.X, Key.Y] := clWhite
          else
            Canvas.Pixels[Key.X, Key.Y] := clRed + I * 31;
      end;
end;

procedure TfMain_2018_06.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
