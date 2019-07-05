unit uMain_2016_24;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  uSolver_2016_24, Vcl.ExtCtrls, Vcl.Samples.Spin;

type
  TfMain_2016_24 = class(TForm)
    Panel1: TPanel;
    btnGo: TButton;
    mmMap: TMemo;
    Splitter1: TSplitter;
    Panel2: TPanel;
    sgMaze: TStringGrid;
    Splitter2: TSplitter;
    sgGraph: TStringGrid;
    edDelay: TSpinEdit;
    Label1: TLabel;
    rgPart: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure sgMazeDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure btnGoClick(Sender: TObject);
    procedure sgMazeMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure sgMazeMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FOps: Integer;
    procedure InitializeMaze;
    procedure SleepSomeTime;
    procedure MazePathSearchStep(const Node: PNode);
    procedure MazePathTraceStep(const EndNode, StepNode: PNode);
    procedure MazeGraphCreated(const Graph: TGraph);
  public
    { Public declarations }
  end;

var
  fMain_2016_24: TfMain_2016_24;

implementation

uses
  System.Math, Vcl.GraphUtil;

{$R *.dfm}

procedure TfMain_2016_24.btnGoClick(Sender: TObject);
begin
  InitializeMaze;
  with TSolver.Create(mmMap.Lines, TSolverPart(rgPart.ItemIndex)) do
    try
      OnPathSearchStep := MazePathSearchStep;
      OnPathTraceStep := MazePathTraceStep;
      OnGraphCreated := MazeGraphCreated;

      Application.MessageBox(PWideChar(Format('Best path: %d', [ Solve ])), nil, MB_ICONINFORMATION or MB_OK);
    finally
      Free;
    end;
end;

procedure TfMain_2016_24.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfMain_2016_24.FormCreate(Sender: TObject);
begin
  InitializeMaze;
  FOps := 0;
end;

procedure TfMain_2016_24.InitializeMaze;
var
  I, J: Integer;
begin
  with mmMap.Lines do
    begin
      sgMaze.RowCount := Count;
      for I := 0 to Count do
        begin
          if Strings[I].Trim.IsEmpty then
            Continue;

          sgMaze.ColCount := Strings[I].Length;
          for J := 0 to Strings[I].Length - 1 do
            sgMaze.Cells[J, I] := Strings[I][J + 1];
        end;
    end;
end;

procedure TfMain_2016_24.MazeGraphCreated(const Graph: TGraph);
var
  I, J: Integer;
begin
  with sgGraph do
    begin
      ColCount := Length(Graph) + 1;
      RowCount := Length(Graph[0]) + 1;

      for I := 0 to Length(Graph) - 1 do
        begin
          Cells[I + 1, 0] := IntToStr(I);
          Cells[0, I + 1] := IntToStr(I);
          for J := 0 to Length(Graph[I]) - 1 do
            Cells[I + 1, J + 1] := IntToStr(Graph[I, J]);
          SleepSomeTime;
        end;
    end;
end;

procedure TfMain_2016_24.MazePathSearchStep(const Node: PNode);
begin
  with Node.P do
    if sgMaze.Cells[X, Y] = '.' then
      sgMaze.Cells[X, Y] := '-';

  SleepSomeTime;
end;

procedure TfMain_2016_24.MazePathTraceStep(const EndNode, StepNode: PNode);
begin
  with StepNode.P do
    if sgMaze.Cells[X, Y] = '-' then
      sgMaze.Cells[X, Y] := Chr(Ord('a') + EndNode.Number);

  SleepSomeTime;
end;

procedure TfMain_2016_24.sgMazeDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if not (gdSelected in State) then
    with TStringGrid(Sender) do
      begin
        case Cells[ACol, ARow][1] of
          '.':      Canvas.Brush.Color := clWindow;
          '#':      Canvas.Brush.Color := clBlack;
          '0':      Canvas.Brush.Color := clRed;
          '1'..'9': Canvas.Brush.Color := clYellow;
          '-':      Canvas.Brush.Color := RGB(240, 240, 255);
          'a'..'j': Canvas.Brush.Color := ColorHLSToRGB((24 * (Ord(Cells[ACol, ARow][1]) - Ord('a')) + 12) mod 240, 160, 100);  //clGreen + (Ord(Cells[ACol, ARow][1]) - Ord('a')) * 128;
        end;

        Dec(Rect.Left, 4);
        Canvas.FillRect(Rect);
      end;
end;

procedure TfMain_2016_24.sgMazeMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
    with TStringGrid(Sender) do
      begin
        DefaultColWidth := DefaultColWidth - 1;
        DefaultRowHeight := DefaultRowHeight - 1;
      end;
end;

procedure TfMain_2016_24.sgMazeMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
    with TStringGrid(Sender) do
      begin
        DefaultColWidth := DefaultColWidth + 1;
        DefaultRowHeight := DefaultRowHeight + 1;
      end;
end;

procedure TfMain_2016_24.SleepSomeTime;
begin
  if edDelay.Value > 0 then
    begin
      Inc(FOps);
      Sleep(edDelay.Value);
      if FOps mod 50 = 0 then
        begin
          Application.ProcessMessages;
          FOps := 0;
        end;
    end;
end;

end.
