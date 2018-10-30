unit uForm_2015_18;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uTask_2015_18;

type
  TfMain_2015_18 = class(TForm)
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FLife: TLife;
  public
    property Life: TLife read FLife write FLife;
  end;

var
  fMain_2015_18: TfMain_2015_18;

implementation

{$R *.dfm}

procedure TfMain_2015_18.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfMain_2015_18.FormPaint(Sender: TObject);
var
  I, J: Integer;
begin
  with Canvas do
    begin
      Brush.Color := clBlack;
      FillRect(ClientRect);

      Brush.Color := clGray;
      for I := 0 to Length(FLife) - 1 do
        for J := 0 to Length(FLife[I]) - 1 do
          if FLife[I, J] then
            FillRect(TRect.Create(I * 8, J * 8, I * 8 + 8, J * 8 + 8));
    end;
end;

end.
