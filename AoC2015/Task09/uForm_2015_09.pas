unit uForm_2015_09;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
  uTask_2015_09;

type
  TfForm_2015_09 = class(TForm)
    sgGraph: TStringGrid;
  private
    FTask: TTask_AoC;
  public
    procedure DrawGraph;
    procedure SetTask(const Task: TTask_AoC);
    procedure HighLightPath(const Path: TArray<Integer>; const IsMin: Boolean);
  end;

var
  fForm_2015_09: TfForm_2015_09;

implementation

{$R *.dfm}

{ TfForm_2015_09 }

procedure TfForm_2015_09.DrawGraph;
var
  Key: TPoint;
  I: Integer;
begin
  with FTask.Graph do
    for Key in Keys do
      begin
        if Key.X > sgGraph.ColCount - 2 then
          sgGraph.ColCount := Key.X + 2;
        if Key.Y > sgGraph.RowCount - 2 then
          sgGraph.RowCount := Key.Y + 2;

        sgGraph.Cells[Key.X + 1, Key.Y + 1] := IntToStr(Items[Key].Cost);
        sgGraph.Objects[Key.X + 1, Key.Y + 1].Free;
        sgGraph.Objects[Key.X + 1, Key.Y + 1] := nil;
      end;

  for I := 1 to sgGraph.ColCount - 1 do
    begin
      sgGraph.Cells[I, 0] := FTask.Locations[I - 1];
      sgGraph.Cells[0, I] := FTask.Locations[I - 1];
    end;
end;

procedure TfForm_2015_09.HighLightPath(const Path: TArray<Integer>; const IsMin: Boolean);
var
  I: Integer;
  Mark: Char;
  CellText: String;
begin
  if IsMin then
    Mark := 'v'
  else
    Mark := '^';

  for I := 0 to Length(Path) - 2 do
    begin
      CellText := sgGraph.Cells[Path[I] + 1, Path[I + 1] + 1];
      if not CellText.Contains(Mark) then
        sgGraph.Cells[Path[I] + 1, Path[I + 1] + 1] := CellText + ' ' + Mark;
    end;

  sgGraph.Repaint;
  Application.ProcessMessages;
end;

procedure TfForm_2015_09.SetTask(const Task: TTask_AoC);
begin
  FTask := Task;
end;

end.
