unit uForm_2019_18;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uTask_2019_18;

type
  TfForm_2019_18 = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
  private const
    PIXEL_SIZE = 12;
  private
    FMaze: TMaze;
  public
    procedure DrawMaze(const Maze: TMaze);
  end;

var
  fForm_2019_18: TfForm_2019_18;

implementation

{$R *.dfm}

procedure TfForm_2019_18.DrawMaze(const Maze: TMaze);
var
  W, H: Integer;
  Key: TPoint;
begin
  FMaze := Maze;

  W := 0;
  H := 0;
  for Key in FMaze.Keys do
    begin
      if Key.X > W then W := Key.X;
      if Key.Y > H then H := Key.Y;
    end;

  ClientWidth  := (W + 2) * PIXEL_SIZE;
  ClientHeight := (H + 2) * PIXEL_SIZE;

  Invalidate;
end;

procedure TfForm_2019_18.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfForm_2019_18.FormPaint(Sender: TObject);
var
  Key: TPoint;
begin
  with Canvas do
    begin
      Brush.Color := clGray;
      FillRect(ClientRect);
      for Key in FMaze.Keys do
        begin
          case FMaze[Key] of
            '*':      Brush.Color := clWebLightYellow;
            '.':      Brush.Color := clWhite;
            '@':      Brush.Color := clRed;
            'a'..'z': Brush.Color := clWebLightGreen;
            'A'..'Z': Brush.Color := clWebLightCoral;
          end;
          with Key do
            FillRect(TRect.Create(X * PIXEL_SIZE, Y * PIXEL_SIZE, (X + 1) * PIXEL_SIZE, (Y + 1) * PIXEL_SIZE));
          if not CharInSet(FMaze[Key], [ '.', '@' ]) then
            TextOut(Key.X * PIXEL_SIZE, Key.Y * PIXEL_SIZE, FMaze[Key]);
        end;
    end;
end;

end.
