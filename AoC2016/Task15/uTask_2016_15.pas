unit uTask_2016_15;

interface

uses
  System.Generics.Collections, uTask;

type
  TDisk = record
    Number, Count, Start: Integer;
    constructor Create(const S: String); overload;
    constructor Create(const ANumber, ACount, AStart: Integer); overload;
    function IsAtZero(const Time: Integer): Boolean;
  end;

  TDisks = class(TList<TDisk>)
  public
    function IsAtZero(const Time: Integer): Boolean;
  end;

  TTask_AoC = class (TTask)
  private
    FDisks: TDisks;
    procedure LoadDisks;
    function GetSyncTime: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TDisk }

constructor TDisk.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Replace('#', '', [ rfReplaceAll ]).Replace('.', '', [ rfReplaceAll ]).Split([' ']);
  Create(A[1].ToInteger, A[3].ToInteger, A[11].ToInteger);
end;

constructor TDisk.Create(const ANumber, ACount, AStart: Integer);
begin
  Number := ANumber;
  Count := ACount;
  Start := AStart;
end;

function TDisk.IsAtZero(const Time: Integer): Boolean;
begin
  Result := (Time + Number + Start) mod Count = 0;
end;

{ TDisks }

function TDisks.IsAtZero(const Time: Integer): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Count - 1 do
    if not Items[I].IsAtZero(Time) then
      Exit(False);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadDisks;

    OK('Part 1: %d', [ GetSyncTime ]);

    FDisks.Add(TDisk.Create(7, 11, 0));
    OK('Part 2: %d', [ GetSyncTime ]);
  finally
    FDisks.Free;
  end;
end;

function TTask_AoC.GetSyncTime: Integer;
begin
  Result := 0;
  while not FDisks.IsAtZero(Result) do
    Inc(Result);
end;

procedure TTask_AoC.LoadDisks;
var
  I: Integer;
begin
  FDisks := TDisks.Create;

  with Input do
    try
      for I := 0 to Count - 1 do
        FDisks.Add(TDisk.Create(Strings[I]));
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2016, 15, 'Timing is Everything');

finalization
  GTask.Free;

end.
