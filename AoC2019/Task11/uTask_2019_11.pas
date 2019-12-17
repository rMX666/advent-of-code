unit uTask_2019_11;

interface

uses
  uTask, System.Types, System.Generics.Collections, IntCode;

type
  TPaintPanel = record
  private
    FColor, FPaintCount: Integer;
  public
    constructor Create(const AColor: Integer);
    function Paint(const AColor: Integer): TPaintPanel;
    property Color: Integer read FColor;
    property PaintCount: Integer read FPaintCount;
  end;

  TRobotDirection = ( rdUp
                    , rdLeft
                    , rdDown
                    , rdRight
                    );

  TMap = TDictionary<TPoint,TPaintPanel>;

  TRobot = class
  private
    FMap: TMap;
    FFreeBrain: Boolean;
    FBrain: TIntCode;
    FPosition: TPoint;
    FDirection: TRobotDirection;
    function GetColor: Integer;
    procedure SetColor(const Value: Integer);
    procedure DoMove(const Direction: Integer);
    function GetCountPainted: Integer;
  public
    constructor Create(const Brain: TIntCode; const FreeBrain: Boolean = True);
    destructor Destroy; override;
    function Move: Boolean;
    property Color: Integer read GetColor write SetColor;
    property CountPainted: Integer read GetCountPainted;
    property Map: TMap read FMap;
  end;

  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function GetPaintedCount: Integer;
    procedure DrawIdentifier;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uForm_2019_11;

var
  GTask: TTask_AoC;

{ TPaintPanel }

constructor TPaintPanel.Create(const AColor: Integer);
begin
  FColor := AColor;
  FPaintCount := 0;
end;

function TPaintPanel.Paint(const AColor: Integer): TPaintPanel;
begin
  Result := TPaintPanel.Create(AColor);
  Result.FPaintCount := FPaintCount + 1;
end;

{ TRobot }

constructor TRobot.Create(const Brain: TIntCode; const FreeBrain: Boolean = True);
begin
  FFreeBrain := FreeBrain;
  FBrain := Brain;
  FPosition := TPoint.Zero;
  FDirection := rdUp;
  FMap := TMap.Create;
end;

destructor TRobot.Destroy;
begin
  if FFreeBrain then
    FreeAndNil(FBrain);
  FreeAndNil(FMap);
  inherited;
end;

procedure TRobot.DoMove(const Direction: Integer);
begin
  case Direction of
    0: // Turn left
      FDirection := TRobotDirection((Integer(FDirection) + 1) mod 4);
    1: // Turn right
      FDirection := TRobotDirection((Integer(FDirection) + 3) mod 4);
  end;

  case FDirection of
    rdUp:    Dec(FPosition.Y);
    rdLeft:  Dec(FPosition.X);
    rdDown:  Inc(FPosition.Y);
    rdRight: Inc(FPosition.X);
  end;
end;

function TRobot.Move: Boolean;
var
  E: TExecuteResult;
begin
  with FBrain do
    begin
      AddInput(Color);
      E := Execute;
      Color := Output[0];
      DoMove(Output[1]);
      Output.Clear;
    end;

  Result := E <> erHalt;
end;

function TRobot.GetColor: Integer;
begin
  if not FMap.ContainsKey(FPosition) then
    FMap.Add(FPosition, TPaintPanel.Create(0));

  Result := FMap[FPosition].Color;
end;

procedure TRobot.SetColor(const Value: Integer);
begin
  if not FMap.ContainsKey(FPosition) then
    FMap.Add(FPosition, TPaintPanel.Create(0));

  FMap[FPosition] := FMap[FPosition].Paint(Value);
end;

function TRobot.GetCountPainted: Integer;
var
  Value: TPaintPanel;
begin
  Result := 0;
  for Value in FMap.Values do
    if Value.PaintCount > 0 then
      Inc(Result);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadProgram;
  try
    OK('Part 1: %d', [ GetPaintedCount ]);
    DrawIdentifier;
  finally
    FInitialState.Free;
  end;
end;

procedure TTask_AoC.DrawIdentifier;
begin
  with TRobot.Create(TIntCode.Create(FInitialState)) do
    try
      Color := 1;
      while Move do;
      fForm_2019_11 := TfForm_2019_11.Create(nil);
      fForm_2019_11.DrawMap(Map);
      fForm_2019_11.ShowModal;
    finally
      Free;
    end;
end;

function TTask_AoC.GetPaintedCount: Integer;
begin
  with TRobot.Create(TIntCode.Create(FInitialState)) do
    try
      while Move do;
      Result := CountPainted;
    finally
      Free;
    end;
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TIntCode.Create(Text);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 11, 'Space Police');

finalization
  GTask.Free;

end.
