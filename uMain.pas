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
        Parent := fMain;
        Caption := 'Year ' + IntToStr(Year);
        Align := alLeft;
        AlignWithMargins := True;
        Width := 256;
      end;
  end;

  procedure CreateTaskButton(const Task: TTask; const Box: TGroupBox; const TaskIndex: Integer);
  var
    Button: TButton;
  begin
    Button := TButton.Create(Application);
    with Button do
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
  I, Year: Integer;
  YearBox: TGroupBox;
begin
  Year := -1;
  with TTaskHost.Tasks do
    for I := 0 to Count - 1 do
      begin
        if Year <> Items[I].Year then
          begin
            Year := Items[I].Year;
            YearBox := CreateYearBox(Year);
          end;

        CreateTaskButton(Items[I], YearBox, I);
      end;
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
