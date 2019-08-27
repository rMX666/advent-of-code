unit uForm_2018_20;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.ExtCtrls, System.Types,
  uTask_2018_20;

type
  TfForm_2018_20 = class(TForm)
    imgMap: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
  private
    FMap: TObject;
  public
    procedure DrawMap(const Map: TMap; const CurrentPos: TPoint);
  end;

var
  fForm_2018_20: TfForm_2018_20;

implementation

uses
  System.Math;

{$R *.dfm}

procedure TfForm_2018_20.DrawMap(const Map: TMap; const CurrentPos: TPoint);
const
  DotSize = 4;
var
  Keys: TArray<TPoint>;
  MinX, MinY: Integer;
  I: Integer;
  Key, KeyN, Shift, Value, ValueN: TPoint;

  function Normalize(const P: TPoint; const DoorShift: TPoint): TPoint;
  begin
    Result := P - Shift;
    Result.X := Result.X * 2 + DoorShift.X;
    Result.Y := Result.Y * 2 + DoorShift.Y;
  end;

  procedure DrawNode(const P: TPoint; const Color: TColor);
  begin
    with imgMap.Canvas do
      begin
        Brush.Color := Color;
        FillRect(TRect.Create(P.X * DotSize, P.Y * DotSize, (P.X + 1) * DotSize - 1, (P.Y + 1) * DotSize - 1));
      end;
  end;

begin
  FMap := Map;
  imgMap.Picture.Assign(nil);

  Keys := Map.Keys.ToArray;
  MinX := Keys[0].X;
  MinY := Keys[0].Y;
  for I := 0 to Length(Keys) - 1 do
    begin
      if Keys[I].X < MinX then MinX := Keys[I].X;
      if Keys[I].Y < MinY then MinY := Keys[I].Y;
    end;
  Shift := TPoint.Create(MinX, MinY);

  with imgMap.Canvas do
    begin
      Brush.Color := clBlack;
      FillRect(imgMap.ClientRect);
    end;

  for Key in Map.Keys do
    begin
      KeyN := Normalize(Key, TPoint.Zero);
      if Key = TPoint.Zero then
        DrawNode(KeyN, clRed)
      else
        DrawNode(KeyN, clWhite);
      for Value in Map[Key] do
        begin
          ValueN := Normalize(Key, Value - Key);
          DrawNode(ValueN, clWebLightBlue);
        end;
    end;
  DrawNode(Normalize(CurrentPos, TPoint.Zero), clGreen);
  //Application.ProcessMessages;
  //Sleep(100);
end;

procedure TfForm_2018_20.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfForm_2018_20.FormResize(Sender: TObject);
begin
  DrawMap(TMap(FMap), TPoint.Zero);
end;

end.
