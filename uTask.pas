unit uTask;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults, System.Classes;

type
  EInputNotFound = Exception;
  
  TTask = class
  private
    FYear, FNumber: Integer;
    FName: String;
    function GetInput: TStrings;
  protected
    procedure DoRun; virtual; abstract;
    procedure OK(const Msg: String); overload;
    procedure OK(const Msg: String; const Args: array of const); overload;
    procedure Error(const Msg: String); overload;
    procedure Error(const Msg: String; const Args: array of const); overload;
  public
    constructor Create; overload; virtual;
    constructor Create(const AYear, ANumber: Integer; const AName: String); overload;
    destructor Destroy; override;
    procedure Run;
    property Year: Integer read FYear;
    property Number: Integer read FNumber;
    property Name: String read FName;
    property Input: TStrings read GetInput;
  end;

  TTaskList = TList<TTask>;

  TTaskHost = class
  private
    class var FTasks: TTaskList;
    class var FComparer: IComparer<TTask>;
  public
    class constructor CreateClass;
    class destructor DestroyClass;
    class property Tasks: TTaskList read FTasks;
    class procedure AddTask(const Task: TTask);
  end;

implementation

uses
  VCL.Forms, Winapi.Windows;

const
  INPUT_DIR = 'Input';
  INPUT_FILE = '%s\%d\Task%0.2d\input.txt';
  E_INPUT_DIR_NOT_FOUND = '%s - Task %d (%s): Failed to find Input directory';

{ TTaskHost }

class procedure TTaskHost.AddTask(const Task: TTask);
begin
  FTasks.Add(Task);
  FTasks.Sort(FComparer);
end;

class constructor TTaskHost.CreateClass;
begin
  FTasks := TTaskList.Create;
  FComparer := TComparer<TTask>.Construct(function (const Left, Right: TTask): Integer
    begin
      Result := Left.FYear - Right.FYear;
      if Result = 0 then
        Result := Left.FNumber - Right.FNumber;
    end);
end;

class destructor TTaskHost.DestroyClass;
begin
  FComparer := nil;
  FTasks.Free;
end;

{ TTask }

constructor TTask.Create(const AYear, ANumber: Integer; const AName: String);
begin
  FYear := AYear;
  FNumber := ANumber;
  FName := AName;

  Create;
end;

constructor TTask.Create;
begin
  TTaskHost.AddTask(Self);
end;

destructor TTask.Destroy;
begin
  TTaskHost.Tasks.Remove(Self);
  inherited;
end;

function TTask.GetInput: TStrings;

  function FindInputDirectory: String;
  const
    MaxIterations = 10;
  var
    I: Integer;
  begin
    Result := INPUT_DIR;
    I := 0;
    while not DirectoryExists(Result) do
      begin
        if I >= MaxIterations then
          raise EInputNotFound.Create(Format(E_INPUT_DIR_NOT_FOUND, [ Year, Number, Name ]));

        Result := '..\' + Result;
        Inc(I);
      end;
  end;

begin
  Result := TStringList.Create;
  Result.LoadFromFile(Format(INPUT_FILE, [ FindInputDirectory, Year, Number ]));
end;

procedure TTask.OK(const Msg: String);
begin
  Application.MessageBox(PWideChar(Msg), nil, MB_OK or MB_ICONINFORMATION);
end;

procedure TTask.OK(const Msg: String; const Args: array of const);
begin
  OK(Format(Msg, Args));
end;

procedure TTask.Error(const Msg: String);
begin
  Application.MessageBox(PWideChar(Msg), nil, MB_OK or MB_ICONERROR);
end;

procedure TTask.Error(const Msg: String; const Args: array of const);
begin
  Error(Format(Msg, Args));
end;

procedure TTask.Run;
begin
  try
    DoRun;
  except
    on E: EInputNotFound do
      Error(E.Message);
    on E: Exception do
      Error(E.Message);
  end;
end;

end.
