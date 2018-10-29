unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfMain = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    procedure DrawTaskList;
    procedure TaskLaunchButtonClick(Sender: TObject);
  public
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses
  uTask;

procedure TfMain.DrawTaskList;

  function CreateYearBox(const Year: Integer): TGroupBox;
  begin
    Result := TGroupBox.Create(Application);
    with Result do
      begin
        Left := 800;
        Parent := fMain;
        Caption := 'Year ' + IntToStr(Year);
        Align := alLeft;
        AlignWithMargins := True;
        Width := 300;
      end;
  end;

  function CreateTaskButton(const Task: TTask; const Box: TGroupBox; const TaskIndex: Integer): TButton;
  begin
    Result := TButton.Create(Application);
    with Result do
      begin
        Parent := Box;
        Left := 8;
        Top := 16 + Height * (Task.Number - 1);
        Caption := Format('Task %0.2d (%s)', [ Task.Number, Task.Name ]);
        OnClick := TaskLaunchButtonClick;
        Width := Box.Width - 16;
        Tag := TaskIndex;
      end;
  end;

var
  I, Year, FormWidth, FormHeight: Integer;
  YearBox: TGroupBox;
begin
  FormWidth := 16;
  FormHeight := 0;

  Year := -1;
  with TTaskHost.Tasks do
    for I := 0 to Count - 1 do
      begin
        if Year <> Items[I].Year then
          begin
            Year := Items[I].Year;
            YearBox := CreateYearBox(Year);
            Inc(FormWidth, YearBox.Width + 6);
          end;

        with CreateTaskButton(Items[I], YearBox, I) do
          if FormHeight < 68 + Top + Height then
            FormHeight := 68 + Top + 8;
      end;

  fMain.Width := FormWidth;
  fMain.Height := FormHeight;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  DrawTaskList;
end;

procedure TfMain.TaskLaunchButtonClick(Sender: TObject);
begin
  with TButton(Sender) do
    TTaskHost.Tasks[Tag].Run;
end;

end.
