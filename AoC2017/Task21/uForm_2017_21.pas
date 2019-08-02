unit uForm_2017_21;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.Generics.Collections;

type
  TGrid = class
  public type
    TGridArray = TArray<TArray<Char>>;
  strict private type
    TReplacements = TDictionary<String,TGridArray>;
  private
    FGrid: TGridArray;
    FReplacements: TReplacements;
    function GetItem(const X, Y: Integer): Char;
    function ParseGrid(const S: String): TGridArray;
    function UnparseGrid(const Grid: TGridArray): String;
    function GetSize: Integer;
  public
    constructor Create(const Initial: String);
    destructor Destroy; override;
    procedure AddReplacement(const S: String);
    procedure Step;
    property Items[const X, Y: Integer]: Char read GetItem; default;
    property Size: Integer read GetSize;
    // Enumerate by grid parts
    type
      TEnumerator = class(TEnumerator<TGridArray>)
      private
        FOwner: TGrid;
        FIndex: Integer;
        FDimension: Integer;
        FCurrent: TGridArray;
        function GetCurrent: TGridArray;
      protected
        function DoGetCurrent: TGridArray; override;
        function DoMoveNext: Boolean; override;
      public
        constructor Create(const AOwner: TGrid);
        property Current: TGridArray read GetCurrent;
        function MoveNext: Boolean;
      end;
    function GetEnumerator: TEnumerator;
  end;

type
  TfForm_2017_21 = class(TForm)
    imgGame: TImage;
  private
    { Private declarations }
  public
    procedure DrawGrid(const Grid: TGrid; const DotSize: Integer = 4);
  end;

var
  fForm_2017_21: TfForm_2017_21;

implementation

uses
  System.Math.Vectors;

{$R *.dfm}

{ TGrid }

procedure TGrid.AddReplacement(const S: String);

  function Transpose(const Grid: TGridArray): TGridArray;
  var
    I, J, L: Integer;
  begin
    L := Length(Grid);
    SetLength(Result, L);
    for I := 0 to L - 1 do
      SetLength(Result[I], L);

    for I := 0 to L - 1 do
      for J := 0 to L - 1 do
        Result[J][I] := Grid[I][J];
  end;

  function Reverse(const Grid: TGridArray): TGridArray;
  var
    I, L: Integer;
  begin
    L := Length(Grid);
    SetLength(Result, L);
    for I := 0 to L - 1 do
      Result[L - I - 1] := Grid[I];
  end;

  function Rotate(const Grid: TGridArray): TGridArray;
  var
    L, I: Integer;
  begin
    L := Length(Grid);
    SetLength(Result, L);
    for I := 0 to L - 1 do
      Result[I] := Copy(Grid[I], 0, L);
    case L of
      2:
        begin
          Result[0][0] := Grid[0][1];
          Result[0][1] := Grid[1][1];
          Result[1][1] := Grid[1][0];
          Result[1][0] := Grid[0][0];
        end;
      3:
        begin
          Result[0][0] := Grid[0][2];
          Result[0][1] := Grid[1][2];
          Result[0][2] := Grid[2][2];
          Result[1][2] := Grid[2][1];
          Result[2][2] := Grid[2][0];
          Result[2][1] := Grid[1][0];
          Result[2][0] := Grid[0][0];
          Result[1][0] := Grid[0][1];
        end;
    end;
    //Result := Reverse(Transpose(Grid));
  end;

var
  A: TArray<String>;
  Key, Value: TGridArray;
  I: Integer;
begin
  A := S.Split([' => ']);
  Key := ParseGrid(A[0]);
  Value := ParseGrid(A[1]);

  for I := 0 to 7 do
    begin
      if I = 4 then
        Key := Reverse(Key);
      if not FReplacements.ContainsKey(UnparseGrid(Key)) then
        FReplacements.Add(UnparseGrid(Key), Value);
      Key := Rotate(Key);
    end;
end;

constructor TGrid.Create(const Initial: String);
begin
  FReplacements := TReplacements.Create;
  FGrid := ParseGrid(Initial);
end;

destructor TGrid.Destroy;
begin
  FReplacements.Free;
  inherited;
end;

function TGrid.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

function TGrid.GetItem(const X, Y: Integer): Char;
begin
  Result := FGrid[X][Y];
end;

function TGrid.GetSize: Integer;
begin
  Result := Length(FGrid);
end;

function TGrid.ParseGrid(const S: String): TGridArray;
var
  A: TArray<String>;
  I: Integer;
begin
  A := S.Split(['/']);
  SetLength(Result, Length(A));
  for I := 0 to Length(A) - 1 do
    Result[I] := A[I].ToCharArray;
end;

procedure TGrid.Step;
var
  Part, Replacement, NewGrid: TGridArray;
  X, Y, I, J, NewSize, Dimension: Integer;
begin
  NewSize := Length(FGrid);
  if NewSize mod 2 = 0 then
    begin
      Dimension := 3;
      NewSize := (NewSize div 2) * Dimension;
    end
  else
    begin
      Dimension := 4;
      NewSize := (NewSize div 3) * Dimension;
    end;

  SetLength(NewGrid, NewSize);
  for I := 0 to NewSize - 1 do
    SetLength(NewGrid[I], NewSize);

  X := 0;
  Y := 0;
  for Part in Self do
    begin
      Replacement := FReplacements[UnparseGrid(Part)];
      for I := Y to Y + Dimension - 1 do
        for J := X to X + Dimension - 1 do
          NewGrid[I][J] := Replacement[I mod Dimension][J mod Dimension];

      Inc(X, Dimension);
      if X >= NewSize then
        begin
          X := 0;
          Inc(Y, Dimension);
        end;
    end;

  FGrid := NewGrid;
end;

function TGrid.UnparseGrid(const Grid: TGridArray): String;
var
  I, J: Integer;
begin
  Result := '';
  for I := 0 to Length(Grid) - 1 do
    begin
      Result := Result + '/';
      for J := 0 to Length(Grid[I]) - 1 do
        Result := Result + Grid[I][J];
    end;
  Result := Result.Substring(1);
end;

{ TGrid.TEnumerator }

constructor TGrid.TEnumerator.Create(const AOwner: TGrid);
begin
  FOwner := AOwner;
  FIndex := -1;
  if Length(FOwner.FGrid) mod 2 = 0 then
    FDimension := 2
  else
    FDimension := 3;
end;

function TGrid.TEnumerator.DoGetCurrent: TGridArray;
begin
  if FIndex = -1 then
    DoMoveNext;
  Result := FCurrent;
end;

function TGrid.TEnumerator.DoMoveNext: Boolean;
var
  I, J, X, Y, L: Integer;
begin
  Result := True;
  Inc(FIndex);
  SetLength(FCurrent, 0);

  L := Length(FOwner.FGrid) div FDimension;

  if FIndex >= L * L then
    Exit(False);

  X := FIndex mod L;
  Y := FIndex div L;

  SetLength(FCurrent, FDimension);
  for I := 0 to FDimension - 1 do
    begin
      SetLength(FCurrent[I], FDimension);
      for J := 0 to FDimension - 1 do
        FCurrent[I][J] := FOwner.FGrid[Y * FDimension + I][X * FDimension + J];
    end;
end;

function TGrid.TEnumerator.GetCurrent: TGridArray;
begin
  Result := DoGetCurrent;
end;

function TGrid.TEnumerator.MoveNext: Boolean;
begin
  Result := DoMoveNext;
end;

{ TfForm_2017_21 }

procedure TfForm_2017_21.DrawGrid(const Grid: TGrid; const DotSize: Integer);
var
  I, J: Integer;
begin
  with imgGame.Canvas do
    begin
      Brush.Color := clWhite;
      FillRect(imgGame.ClientRect);
      Brush.Color := clBlack;
      for I := 0 to Grid.Size - 1 do
        for J := 0 to Grid.Size - 1 do
          if Grid[I, J] = '#' then
            FillRect(TRect.Create(J * DotSize, I * DotSize, (J + 1) * DotSize, (I + 1) * DotSize));
    end;

  Application.ProcessMessages;
  Sleep(500);
end;

end.
