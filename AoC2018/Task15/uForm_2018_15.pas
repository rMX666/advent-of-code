unit uForm_2018_15;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, uTask;

type
  TfForm_2018_15 = class(TForm)
    imgMap: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    procedure DrawMap(const Task: TTask);
  end;

var
  fForm_2018_15: TfForm_2018_15;

implementation

uses
  uTask_2018_15;

{$R *.dfm}

{ TfForm_2018_15 }

procedure TfForm_2018_15.DrawMap(const Task: TTask);

  procedure Draw(const P: TPoint; const Color: TColor; const Dead: Boolean = False);
  const
    DOT_SIZE = 16;
  var
    P1, P2: TPoint;
  begin
    P1 := TPoint.Create(P.X * DOT_SIZE, P.Y * DOT_SIZE);
    P2 := P1 + TPoint.Create(DOT_SIZE, DOT_SIZE);
    with imgMap.Canvas do
      begin
        Brush.Color := Color;
        FillRect(TRect.Create(P1, P2));

        if Dead then
          begin
            Brush.Color := clBlack;
            MoveTo(P1.X, P1.Y);
            LineTo(P2.X, P2.Y);
            MoveTo(P1.X, P2.Y);
            LineTo(P2.X, P1.Y);
          end;
      end;
  end;

  procedure DrawUnit(const U: PUnit);
  begin
    case U.UnitType of
      utElf:    Draw(U.P, clGreen, u.IsDead);
      utGoblin: Draw(U.P, clRed, u.IsDead);
    end;
  end;

var
  I: Integer;
  P: TPoint;
begin
  imgMap.Canvas.Brush.Color := clBlack;
  imgMap.Canvas.FillRect(ClientRect);

  with TTask_AoC(Task) do
    begin
      for P in Map.Keys do
        Draw(P, clWhite);

      for I := 0 to Units.Count - 1 do
        DrawUnit(Units[I]);
    end;

  Application.ProcessMessages;
  Sleep(50);
end;

procedure TfForm_2018_15.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
