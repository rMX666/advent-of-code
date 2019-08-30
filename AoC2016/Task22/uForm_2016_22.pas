unit uForm_2016_22;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Types, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  uSolver_2016_22, Vcl.ExtCtrls, Vcl.Samples.Spin;

type
  TfForm_2016_22 = class(TForm)
    mmNodes: TMemo;
    btnGo: TButton;
    sgNodes: TStringGrid;
    rgHeuristics: TRadioGroup;
    edUpdateDelay: TSpinEdit;
    Label1: TLabel;
    edTargetX: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edTargetY: TEdit;
    edSourceX: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edSourceY: TEdit;
    btnViableCount: TButton;
    procedure btnGoClick(Sender: TObject);
    procedure sgNodesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnViableCountClick(Sender: TObject);
  private
    procedure SetGridSelection(X, Y: Integer);
    procedure EnumerateGrid;
    procedure DrawGrid(const Solver: TSolver);
    procedure SolverStep(const Node: TNode);
    procedure SolverPathTrace(const Node: TNode);
    procedure SolverTraceFinish(const Solver: TSolver);
  public
    { Public declarations }
  end;

var
  fForm_2016_22: TfForm_2016_22;

implementation

uses
  uHeuristics;

{$R *.dfm}

{ TfForm_2016_22 }

procedure TfForm_2016_22.btnGoClick(Sender: TObject);
var
  Solver: TSolver;
  Source, Target: TPoint;
begin
  Source := TPoint.Create(StrToInt(edSourceX.Text), StrToInt(edSourceY.Text));
  Target := TPoint.Create(StrToInt(edTargetX.Text), StrToInt(edTargetY.Text));
  Solver := TSolver.Create(mmNodes.Lines, Source, Target);
  with Solver do
    try
      // Initialize solver
      OnPathStep := SolverStep;
      OnPathTrace := SolverPathTrace;
      OnTraceFinish := SolverTraceFinish;
      PathHeuristics := THeuristicsType(rgHeuristics.ItemIndex);

      // Fill grid
      sgNodes.ColCount := Nodes.Count + 1;
      sgNodes.RowCount := Nodes[0].Count + 1;
      DrawGrid(Solver);

      // Solve
      Application.MessageBox(PChar(Format('Number of steps: %d', [ Solve ])), nil, MB_ICONINFORMATION or MB_OK);
    finally
      Free;
    end;
end;

procedure TfForm_2016_22.btnViableCountClick(Sender: TObject);
var
  Source, Target: TPoint;
begin
  Source := TPoint.Create(StrToInt(edSourceX.Text), StrToInt(edSourceY.Text));
  Target := TPoint.Create(StrToInt(edTargetX.Text), StrToInt(edTargetY.Text));
  with TSolver.Create(mmNodes.Lines, Source, Target) do
    try
      Application.MessageBox(PChar(Format('Viable count: %d', [ ViableCount ])), nil, MB_ICONINFORMATION or MB_OK);
    finally
      Free;
    end;
end;

procedure TfForm_2016_22.DrawGrid(const Solver: TSolver);
var
  I, J: Integer;
begin
  EnumerateGrid;
  with Solver do
    for I := 0 to Nodes.Count - 1 do
      for J := 0 to Nodes[I].Count - 1 do
        begin
          sgNodes.Objects[I + 1, J + 1] := TObject(Nodes[I][J]);
          sgNodes.Cells[I + 1, J + 1] := IntToStr(Nodes[I][J].Used) + '/' + IntToStr(Nodes[I][J].Size);
        end;
  sgNodes.Repaint;
end;

procedure TfForm_2016_22.EnumerateGrid;
var
  I: Integer;
begin
  for I := 1 to sgNodes.ColCount - 1 do
    sgNodes.Cells[I, 0] := IntToStr(I - 1);

  for I := 1 to sgNodes.RowCount - 1 do
    sgNodes.Cells[0, I] := IntToStr(I - 1);
end;

procedure TfForm_2016_22.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfForm_2016_22.FormCreate(Sender: TObject);
begin
  EnumerateGrid;
end;

procedure TfForm_2016_22.sgNodesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Node: TNode;
begin
  with TStringGrid(Sender) do
    begin
      if gdSelected in State then
        begin
          Canvas.Brush.Color := clSkyBlue;
        end
      else
        begin
          if Objects[ACol, ARow] = nil then
            Exit;

          Node := (PNode(Objects[ACol, ARow]))^;

          if Node.Used = 0 then
            Canvas.Brush.Color := clRed
          else if Node.Size > 150 then
            Canvas.Brush.Color := clWebBrown
          else if Node.Target then
            Canvas.Brush.Color := clWebOrange
          else if (Node.P.X = 0) and (Node.P.Y = 0) then
            Canvas.Brush.Color := clWebLightGreen
          else if Node.Visited = vsVisited then
            Canvas.Brush.Color := clYellow
          else if Node.Visited = vsRealPath then
            Canvas.Brush.Color := clWebOlive
          else
            Canvas.Brush.Color := clWindow;
        end;

      Dec(Rect.Left, 4);
      Canvas.FillRect(Rect);
      Canvas.TextOut(Rect.Left + 4, Rect.Top, Cells[ACol, ARow]);
    end;
end;

procedure TfForm_2016_22.SetGridSelection(X, Y: Integer);
var
  Rect: TGridRect;
begin
  Rect.Left   := X + 1;
  Rect.Top    := Y + 1;
  Rect.Right  := X + 1;
  Rect.Bottom := Y + 1;
  sgNodes.Selection := Rect;
end;

procedure TfForm_2016_22.SolverPathTrace(const Node: TNode);
begin
  with Node.P do
    begin
      PNode(sgNodes.Objects[X + 1, Y + 1]).Visited := vsRealPath;
      SetGridSelection(X, Y);
    end;

  Application.ProcessMessages;
  Sleep(edUpdateDelay.Value);
end;

procedure TfForm_2016_22.SolverStep(const Node: TNode);
begin
  with Node.P do
    begin
      PNode(sgNodes.Objects[X + 1, Y + 1]).Visited := vsVisited;
      SetGridSelection(X, Y);
    end;

  Application.ProcessMessages;
  Sleep(edUpdateDelay.Value);
end;

procedure TfForm_2016_22.SolverTraceFinish(const Solver: TSolver);
begin
  DrawGrid(Solver);
end;

end.
