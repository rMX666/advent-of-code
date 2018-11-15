unit uForm_2016_05;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfMain_2016_05 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    procedure PasswordChanged(const IsHardMode: Boolean; const S: String);
  end;

var
  fMain_2016_05: TfMain_2016_05;

implementation

{$R *.dfm}

{ TfMain_2016_05 }

procedure TfMain_2016_05.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfMain_2016_05.PasswordChanged(const IsHardMode: Boolean; const S: String);
begin
  if IsHardMode then
    Edit2.Text := S
  else
    Edit1.Text := S;

  Application.ProcessMessages;
end;

end.
