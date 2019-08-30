unit uForm_2017_22;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.Generics.Collections, System.Types;

type
  TNodeState = ( nsNone, nsClean, nsInfected, nsWeakened, nsFlagged );
  TCarrierDirection = ( cdNone, cdUp, cdDown, cdLeft, cdRight );

  TMap = class
  private
    FMap: TArray<TArray<TNodeState>>;
    function GetItem(const X, Y: Integer): TNodeState;
    procedure SetItem(const X, Y: Integer; const Value: TNodeState);
    function GetSize: Integer;
    procedure SetSize(const Value: Integer);
    procedure Grow; overload;
  public
    procedure Grow(var Position: TPoint); overload;
    property Items[const X, Y: Integer]: TNodeState read GetItem write SetItem; default;
    property Size: Integer read GetSize write SetSize;
  end;

  TCarrier = class
  strict private type
    // TransitionType -> Part -> (From -> To)
    // TransitionType: 0 - Infect, 1 - Redirect
    TTransisions = TObjectDictionary<Integer,TObjectDictionary<Integer,TDictionary<Integer,Integer>>>;
    TMapDict = TDictionary<TPoint,TNodeState>;
  private
    FPart: Integer;
    //
    FMap: TMapDict;
    FShift: Integer;
    FPosition: TPoint;
    FDirection: TCarrierDirection;
    FInfected: Integer;
    //
    FTransisions: TTransisions;
    function StateAndDir(const Direction: TCarrierDirection; const State: TNodeState): Integer;
    function GetInfectTransition(const Src: TNodeState; const Index: Integer): TNodeState;
    function GetRedirectTransition(const Src: TCarrierDirection; const Index: Integer): TCarrierDirection;
    function GetShift: Integer;
    function GetState(const P: TPoint): TNodeState;
    procedure SetState(const P: TPoint; const Value: TNodeState);
    property InfectTransition[const Src: TNodeState]: TNodeState index 0 read GetInfectTransition;
    property RedirectTransition[const Src: TCarrierDirection]: TCarrierDirection index 1 read GetRedirectTransition;
  public
    constructor Create(const Part: Integer);
    destructor Destroy; override;
    procedure Step;
    property Map: TMapDict read FMap write FMap;
    property State[const P: TPoint]: TNodeState read GetState write SetState;
    property Shift: Integer read GetShift;
    property Position: TPoint read FPosition write FPosition;
    property Direction: TCarrierDirection read FDirection;
    property Infected: Integer read FInfected;
  end;

type
  TfForm_2017_22 = class(TForm)
    imgMap: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    FLastShift: Integer;
  public
    procedure DrawMap(const Carrier: TCarrier; const ProcessMessages: Boolean);
  end;

var
  fForm_2017_22: TfForm_2017_22;

implementation

{$R *.dfm}

{ TMap }

function TMap.GetItem(const X, Y: Integer): TNodeState;
begin
  Result := FMap[Y][X];
end;

procedure TMap.SetItem(const X, Y: Integer; const Value: TNodeState);
begin
  FMap[Y][X] := Value;
end;

function TMap.GetSize: Integer;
begin
  Result := Length(FMap);
end;

procedure TMap.SetSize(const Value: Integer);
var
  I: Integer;
begin
  SetLength(FMap, Value);
  for I := 0 to Size - 1 do
    SetLength(FMap[I], Value);
end;

procedure TMap.Grow;
var
  First, Last: TArray<TNodeState>;
  I, L: Integer;
begin
  L := Size;
  SetLength(First, L);
  for I := 0 to L - 1 do
    First[I] := nsClean;
  Last := Copy(First, 0, L);
  Insert(Last, FMap, L);
  Insert(First, FMap, 0);
  for I := 0 to L + 1 do
    begin
      Insert(nsClean, FMap[I], L);
      Insert(nsClean, FMap[I], 0);
    end;
end;

procedure TMap.Grow(var Position: TPoint);
begin
  with Position do
    if (X < 0) or (Y < 0) or (X >= Size) or (Y >= Size) then
      begin
        Grow;
        Inc(X);
        Inc(Y);
      end;
end;

{ TCarrier }

constructor TCarrier.Create(const Part: Integer);
begin
  FPart := Part;
  //
  FMap := TMapDict.Create;
  FShift := 0;
  FDirection := cdUp;
  FPosition := TPoint.Zero;
  FInfected := 0;

  // It's ugly, and I know it
  FTransisions := TTransisions.Create([doOwnsValues]);
  // Infect
  FTransisions.Add(0, TObjectDictionary<Integer,TDictionary<Integer,Integer>>.Create([doOwnsValues]));
    // Part 1
    FTransisions[0].Add(1, TDictionary<Integer,Integer>.Create);
      FTransisions[0][1].Add(Integer(nsClean),    Integer(nsInfected));
      FTransisions[0][1].Add(Integer(nsInfected), Integer(nsClean));
    // Part 2
    FTransisions[0].Add(2, TDictionary<Integer,Integer>.Create);
      FTransisions[0][2].Add(Integer(nsClean),    Integer(nsWeakened));
      FTransisions[0][2].Add(Integer(nsWeakened), Integer(nsInfected));
      FTransisions[0][2].Add(Integer(nsInfected), Integer(nsFlagged));
      FTransisions[0][2].Add(Integer(nsFlagged),  Integer(nsClean));
  // Redirect
  FTransisions.Add(1, TObjectDictionary<Integer,TDictionary<Integer,Integer>>.Create([doOwnsValues]));
    // Part 1
    FTransisions[1].Add(1, TDictionary<Integer,Integer>.Create);
      //
      FTransisions[1][1].Add(StateAndDir(cdUp,    nsClean),    Integer(cdLeft));
      FTransisions[1][1].Add(StateAndDir(cdUp,    nsInfected), Integer(cdRight));
      //
      FTransisions[1][1].Add(StateAndDir(cdDown,  nsClean),    Integer(cdRight));
      FTransisions[1][1].Add(StateAndDir(cdDown,  nsInfected), Integer(cdLeft));
      //
      FTransisions[1][1].Add(StateAndDir(cdLeft,  nsClean),    Integer(cdDown));
      FTransisions[1][1].Add(StateAndDir(cdLeft,  nsInfected), Integer(cdUp));
      //
      FTransisions[1][1].Add(StateAndDir(cdRight, nsClean),    Integer(cdUp));
      FTransisions[1][1].Add(StateAndDir(cdRight, nsInfected), Integer(cdDown));
    // Part 2
    FTransisions[1].Add(2, TDictionary<Integer,Integer>.Create);
      //
      FTransisions[1][2].Add(StateAndDir(cdUp,    nsClean),    Integer(cdLeft));
      FTransisions[1][2].Add(StateAndDir(cdUp,    nsInfected), Integer(cdRight));
      FTransisions[1][2].Add(StateAndDir(cdUp,    nsWeakened), Integer(cdUp));
      FTransisions[1][2].Add(StateAndDir(cdUp,    nsFlagged),  Integer(cdDown));
      //
      FTransisions[1][2].Add(StateAndDir(cdDown,  nsClean),    Integer(cdRight));
      FTransisions[1][2].Add(StateAndDir(cdDown,  nsInfected), Integer(cdLeft));
      FTransisions[1][2].Add(StateAndDir(cdDown,  nsWeakened), Integer(cdDown));
      FTransisions[1][2].Add(StateAndDir(cdDown,  nsFlagged),  Integer(cdUp));
      //
      FTransisions[1][2].Add(StateAndDir(cdLeft,  nsClean),    Integer(cdDown));
      FTransisions[1][2].Add(StateAndDir(cdLeft,  nsInfected), Integer(cdUp));
      FTransisions[1][2].Add(StateAndDir(cdLeft,  nsWeakened), Integer(cdLeft));
      FTransisions[1][2].Add(StateAndDir(cdLeft,  nsFlagged),  Integer(cdRight));
      //
      FTransisions[1][2].Add(StateAndDir(cdRight, nsClean),    Integer(cdUp));
      FTransisions[1][2].Add(StateAndDir(cdRight, nsInfected), Integer(cdDown));
      FTransisions[1][2].Add(StateAndDir(cdRight, nsWeakened), Integer(cdRight));
      FTransisions[1][2].Add(StateAndDir(cdRight, nsFlagged),  Integer(cdLeft));
end;

destructor TCarrier.Destroy;
begin
  FMap.Free;
  FTransisions.Free;
  inherited;
end;

function TCarrier.GetInfectTransition(const Src: TNodeState; const Index: Integer): TNodeState;
begin
  Result := TNodeState(FTransisions[Index][FPart][Integer(Src)]);
end;

function TCarrier.GetRedirectTransition(const Src: TCarrierDirection; const Index: Integer): TCarrierDirection;
begin
  Result := TCarrierDirection(FTransisions[Index][FPart][StateAndDir(Src, State[FPosition])]);
end;

function TCarrier.GetShift: Integer;
begin
  Result := Abs(FShift);
end;

function TCarrier.GetState(const P: TPoint): TNodeState;
begin
  if not FMap.TryGetValue(P, Result) then
    Result := nsClean;
end;

procedure TCarrier.SetState(const P: TPoint; const Value: TNodeState);
begin
  if Value = nsClean then
    FMap.Remove(P)
  else
    FMap.AddOrSetValue(P, Value);
end;

function TCarrier.StateAndDir(const Direction: TCarrierDirection; const State: TNodeState): Integer;
begin
  Result := Integer(Direction) * 16 + Integer(State);
end;

procedure TCarrier.Step;
var
  NodeState: TNodeState;
begin
  FDirection := RedirectTransition[FDirection];

  NodeState := InfectTransition[State[FPosition]];
  State[FPosition] := NodeState;

  if NodeState = nsInfected then
    Inc(FInfected);

  case FDirection of
    cdNone:  raise Exception.Create('Unknown direction');
    cdUp:    Dec(FPosition.Y);
    cdDown:  Inc(FPosition.Y);
    cdLeft:  Dec(FPosition.X);
    cdRight: Inc(FPosition.X);
  end;

  if FShift > FPosition.X then FShift := FPosition.X;
  if FShift > FPosition.Y then FShift := FPosition.Y;
end;

procedure TfForm_2017_22.DrawMap(const Carrier: TCarrier; const ProcessMessages: Boolean);
const
  DotSize = 3;

  procedure DrawNode(const P: TPoint; const Color: TColor);
  begin
    imgMap.Canvas.Brush.Color := Color;
    imgMap.Canvas.FillRect(TRect.Create((P.X + Carrier.Shift) * DotSize, (P.Y + Carrier.Shift) * DotSize, (P.X + Carrier.Shift + 1) * DotSize - 1, (P.Y + Carrier.Shift + 1) * DotSize - 1));
  end;

  procedure DrawNodeEx(const P: TPoint; const State: TNodeState);
  begin
    case State of
      nsClean:    DrawNode(P, clWhite);
      nsInfected: DrawNode(P, clBlack);
      nsWeakened: DrawNode(P, clGreen);
      nsFlagged:  DrawNode(P, clYellow);
    end;
  end;

var
  Pair: TPair<TPoint,TNodeState>;
  PrevPosition: TPoint;
begin
  // Full redraw
  if FLastShift <> Carrier.FShift then
    begin
      FLastShift := Carrier.FShift;

      imgMap.Canvas.Brush.Color := clWhite;
      imgMap.Canvas.FillRect(imgMap.ClientRect);

      for Pair in Carrier.Map do
        DrawNodeEx(Pair.Key, Pair.Value);
    end
  else
    begin
      PrevPosition := TPoint.Create(Carrier.Position);
      case Carrier.Direction of
        cdUp:    Inc(PrevPosition.Y);
        cdDown:  Dec(PrevPosition.Y);
        cdLeft:  Inc(PrevPosition.X);
        cdRight: Dec(PrevPosition.X);
      end;

      DrawNodeEx(PrevPosition, Carrier.State[PrevPosition]);
    end;

  DrawNode(Carrier.Position, clRed);

  if ProcessMessages then
    Application.ProcessMessages;
end;

procedure TfForm_2017_22.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfForm_2017_22.FormShow(Sender: TObject);
begin
  FLastShift := Low(Integer);
end;

end.
