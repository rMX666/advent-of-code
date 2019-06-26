unit uForm_2016_13;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TDrawType = ( dtNone, dtWall, dtStep, dtPath, dtMe );

  TfMain_2016_13 = class(TForm)
    imgMaze: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    procedure Draw(X, Y: Integer; DrawType: TDrawType);
    procedure Reset;
  end;

var
  fMain_2016_13: TfMain_2016_13;

implementation

{$R *.dfm}

{ TfMain_2016_13 }

procedure TfMain_2016_13.Draw(X, Y: Integer; DrawType: TDrawType);
const
  CELL_SIZE = 8;
begin
  X := X * CELL_SIZE;
  Y := Y * CELL_SIZE;
  with imgMaze.Canvas do
    begin
      case DrawType of
        dtNone: Brush.Color := clWhite;
        dtWall: Brush.Color := clBlack;
        dtStep: Brush.Color := clWebLightYellow;
        dtPath: Brush.Color := clWebLightBlue;
        dtMe:   Brush.Color := clRed;
      end;

      FillRect(TRect.Create(X, Y, X + CELL_SIZE, Y + CELL_SIZE));
    end;

  Application.ProcessMessages;
  Sleep(5);
end;

procedure TfMain_2016_13.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfMain_2016_13.Reset;
begin
  imgMaze.Canvas.Brush.Color := clWhite;
  imgMaze.Canvas.FillRect(TRect.Create(0, 0, imgMaze.Width, imgMaze.Height));
end;

end.
