unit uForm_2018_19;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  uProgram_2018_19;

type
  TfMain_2018_19 = class(TForm)
    lbProgram: TListBox;
    Panel1: TPanel;
    Splitter1: TSplitter;
    lbRegisters: TListBox;
    btnRun: TButton;
    btnStep: TButton;
    edBreak: TEdit;
    Label1: TLabel;
    procedure btnStepClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure btnRunClick(Sender: TObject);
  private
    FProgram: TProgram;
    function Step: Boolean;
    function DoBreak: Boolean;
    procedure Run;
  public
    procedure SetProgram(const AProgram: TProgram);
  end;

var
  fMain_2018_19: TfMain_2018_19;

implementation

{$R *.dfm}

{ TForm1 }

procedure TfMain_2018_19.btnRunClick(Sender: TObject);
begin
  Run;
end;

procedure TfMain_2018_19.btnStepClick(Sender: TObject);
begin
  Step;
end;

function TfMain_2018_19.DoBreak: Boolean;
begin
  if edBreak.Text = '' then
    Exit(False);

  Result := FProgram.IP >= StrToInt(edBreak.Text);
end;

procedure TfMain_2018_19.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfMain_2018_19.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  case Msg.CharCode of
    VK_F8: Step;
    VK_F9: Run;
  end;
end;

procedure TfMain_2018_19.Run;
begin
  while Step and not DoBreak do;
end;

procedure TfMain_2018_19.SetProgram(const AProgram: TProgram);
var
  I: Integer;
begin
  FProgram := AProgram;
  lbProgram.Clear;
  for I := 0 to FProgram.Count - 1 do
    lbProgram.AddItem(Format('%0.2d %s', [ I, FProgram[I].ToString ]), nil);
  lbProgram.Selected[FProgram.IP] := True;

  lbRegisters.Clear;
  for I := Low(FProgram.State) to High(FProgram.State) do
    lbRegisters.AddItem(FProgram.State[I].ToString, nil);
end;

function TfMain_2018_19.Step: Boolean;
var
  I: Integer;
begin
  Result := True;

  lbProgram.Selected[FProgram.IP] := False;
  if not FProgram.Step then
    begin
      Application.MessageBox('Done', nil, MB_OK or MB_ICONINFORMATION);
      Exit(False);
    end;
  lbProgram.Selected[FProgram.IP] := True;

  lbRegisters.Items.BeginUpdate;
  for I := Low(FProgram.State) to High(FProgram.State) do
    lbRegisters.Items[I] := FProgram.State[I].ToString;
  lbRegisters.Items.EndUpdate;
end;

end.
