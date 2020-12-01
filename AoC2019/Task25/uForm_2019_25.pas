unit uForm_2019_25;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  IntCode;

type
  TfForm_2019_25 = class(TForm)
    Panel1: TPanel;
    edCommand: TEdit;
    btnSend: TButton;
    btnReset: TButton;
    btnBruteWeight: TButton;
    Panel2: TPanel;
    mmOutput: TMemo;
    Panel3: TPanel;
    lbFloor: TListBox;
    lbInventory: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbDoors: TListBox;
    procedure btnSendClick(Sender: TObject);
    procedure edCommandKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnBruteWeightClick(Sender: TObject);
    procedure lbFloorInventoryDblClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    FHalt: Boolean;
    FInitialInstance: TIntCode;
    FRobot: TIntCode;
    procedure Reset;
    procedure SendCommand; overload;
    procedure SendCommand(const S: String); overload;
    procedure ParseOutput;
    procedure DropItem(const Name: String);
    procedure TakeItem(const Name: String);
  public
    procedure SetRobot(const Robot: TIntCode);
  end;

var
  fForm_2019_25: TfForm_2019_25;

implementation

uses
  uUtil;

{$R *.dfm}

{ TfForm_2019_25 }

procedure TfForm_2019_25.btnBruteWeightClick(Sender: TObject);
var
  Items, Sub: TArray<String>;
  Seq: TSubSequences<String>;
begin
  Seq := TSubSequences<String>.Create(Items);
  try
    for Sub in Seq do
      begin

      end;
  finally
    Seq.Free;
  end;
end;

procedure TfForm_2019_25.btnResetClick(Sender: TObject);
begin
  Reset;
end;

procedure TfForm_2019_25.btnSendClick(Sender: TObject);
begin
  SendCommand;
  edCommand.SetFocus;
end;

procedure TfForm_2019_25.edCommandKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    SendCommand;
end;

procedure TfForm_2019_25.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  FRobot.Free;
  FInitialInstance.Free;
end;

procedure TfForm_2019_25.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
var
  I: Integer;
begin
  case Msg.CharCode of
    VK_UP:
      SendCommand('north');
    VK_DOWN:
      SendCommand('south');
    VK_LEFT:
      SendCommand('west');
    VK_RIGHT:
      SendCommand('east');
    Ord('C'):
      for I := 0 to lbFloor.Count - 1 do
        TakeItem(lbFloor.Items[I]);
    else
      Exit;
  end;
  SendCommand('inv');
end;

procedure TfForm_2019_25.FormShow(Sender: TObject);
begin
  edCommand.SetFocus;
end;

procedure TfForm_2019_25.lbFloorInventoryDblClick(Sender: TObject);
var
  I: Integer;
begin
  with TListBox(Sender) do
    for I := 0 to Count - 1 do
      if Selected[I] then
        begin
          case Tag of
            0: DropItem(Items[I]);
            1: TakeItem(Items[I]);
          end;
          DeleteSelected;
          SendCommand('inv');
          Break;
        end;
end;

procedure TfForm_2019_25.Reset;
begin
  if Assigned(FRobot) then
    FreeAndNil(FRobot);
  FRobot := TIntCode.Create(FInitialInstance);
  FHalt := False;
  mmOutput.Clear;
  edCommand.Text := '';
  SendCommand;
end;

procedure TfForm_2019_25.DropItem(const Name: String);
begin
  SendCommand('drop ' + Name);
end;

procedure TfForm_2019_25.TakeItem(const Name: String);
begin
  SendCommand('take ' + Name);
end;

procedure TfForm_2019_25.SendCommand;
begin
  try
    SendCommand(Trim(edCommand.Text));
  finally
    edCommand.Text := '';
  end;
end;

procedure TfForm_2019_25.SendCommand(const S: String);
begin
  if FHalt then
    Exit;

  with FRobot do
    begin
      if S.Length > 0 then
        begin
          mmOutput.Lines.Add('$ ' + S);
          AddInput(S + #10);
        end;
      FHalt := Execute = erHalt;
      mmOutput.Lines.Add(OutputToString.Replace(#10, #13#10, [rfReplaceAll]));
      ParseOutput;
      Output.Clear;
    end;
end;

procedure TfForm_2019_25.ParseOutput;
var
  I: Integer;
  L: TListBox;
begin
  L := nil;
  with TStringList.Create do
    try
      Text := FRobot.OutputToString.Replace(#10, #13#10, [rfReplaceAll]);
      for I := 0 to Count - 1 do
        begin
          if Strings[I].StartsWith('Items in your inventory') then
            begin
              L := lbInventory;
              lbInventory.Clear;
            end;
          if Strings[I].StartsWith('Items here') then
            begin
              L := lbFloor;
              lbFloor.Clear;
            end;
          if Strings[I].StartsWith('Doors here lead') then
            begin
              L := lbDoors;
              lbDoors.Clear;
            end;
          if Strings[I] = '' then
            L := nil;

          if Assigned(L) and Strings[I].StartsWith('-') then
            L.Items.Add(Strings[I].Replace('- ', ''));
        end;
    finally
      Free;
    end;
end;

procedure TfForm_2019_25.SetRobot(const Robot: TIntCode);
begin
  FInitialInstance := Robot;
  Reset;
end;

end.
