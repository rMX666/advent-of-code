unit uForm_2019_21;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IntCode;

type
  TfForm_2019_21 = class(TForm)
    mmProgram: TMemo;
    btnRun: TButton;
    mmOutput: TMemo;
    btnPart1: TButton;
    btnPart2: TButton;
    procedure btnRunClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnPart1Click(Sender: TObject);
    procedure btnPart2Click(Sender: TObject);
  private
    FRobot: TIntCode;
  public
    procedure SetRobot(const Robot: TIntCode);
  end;

var
  fForm_2019_21: TfForm_2019_21;

implementation

{$R *.dfm}

{ TfForm_2019_21 }

procedure TfForm_2019_21.btnPart1Click(Sender: TObject);
begin
  mmProgram.Text := 'NOT C J'#13#10 +
                    'AND D J'#13#10 +
                    'NOT A T'#13#10 +
                    'OR T J'#13#10 +
                    'WALK';
end;

procedure TfForm_2019_21.btnPart2Click(Sender: TObject);
begin
  mmProgram.Text := 'NOT A J'#13#10 +
                    'NOT B T'#13#10 +
                    'OR T J'#13#10 +
                    'NOT C T'#13#10 +
                    'OR T J'#13#10 +
                    'AND D J'#13#10 +
                    'NOT E T'#13#10 +
                    'NOT T T'#13#10 +
                    'OR H T'#13#10 +
                    'AND T J'#13#10 +
                    'RUN';
end;

procedure TfForm_2019_21.btnRunClick(Sender: TObject);
var
  I: Integer;
begin
  with TIntCode.Create(FRobot) do
    try
      for I := 0 to mmProgram.Lines.Count - 1 do
        AddInput(mmProgram.Lines[I] + #10);
      mmOutput.Text := Format('%d'#13#10'%s', [ Integer(Execute), OutputToString.Replace(#10, #13#10, [rfReplaceAll]) ]);
      if Output.Last > 255 then
        mmOutput.Lines.Add(Output.Last.ToString);
    finally
      Free;
    end;
end;

procedure TfForm_2019_21.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfForm_2019_21.SetRobot(const Robot: TIntCode);
begin
  FRobot := Robot;
end;

end.
