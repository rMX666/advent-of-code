unit uTask_2018_03;

interface

uses
  System.Types, System.Generics.Collections, uTask;

type
  TClaim = record
    Rect: TRect;
    ID: Integer;
    constructor Create(const S: String);
  end;

  TTask_AoC = class (TTask)
  private
    FClaims: TList<TClaim>;
    procedure LoadClaims;
    function GetIntersectCount: Integer;
    function NoIntersections: Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TClaim }

constructor TClaim.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Replace('#', '').Replace('@ ', '').Replace(',', ' ').Replace('x', ' ').Replace(':', '').Split([' ']);

  ID          := A[0].ToInteger;
  Rect.Left   := A[1].ToInteger;
  Rect.Top    := A[2].ToInteger;
  Rect.Width  := A[3].ToInteger;
  Rect.Height := A[4].ToInteger;
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadClaims;

    OK(Format('Part 1: %d, Part 2: %d', [ GetIntersectCount, NoIntersections ]));
  finally
    FClaims.Free;
  end;
end;

function TTask_AoC.GetIntersectCount: Integer;
var
  I, J: Integer;
  Fabric: array [0..1000, 0..1000] of Byte;

  procedure EnableRect(const Rect: TRect);
  var
    I, J: Integer;
  begin
    for I := Rect.Left to Rect.Right - 1 do
      for J := Rect.Top to Rect.Bottom - 1 do
        Inc(Fabric[I, J]);
  end;

begin
  FillChar(Fabric, SizeOf(Fabric), 0);

  for I := 0 to FClaims.Count - 1 do
    EnableRect(FClaims[I].Rect);

  Result := 0;
  for I := 0 to 1000 do
    for J := 0 to 1000 do
      if Fabric[I, J] > 1 then
        Inc(Result);
end;

procedure TTask_AoC.LoadClaims;
var
  I: Integer;
begin
  with Input do
    try
      FClaims := TList<TClaim>.Create;
      for I := 0 to Count - 1 do
        FClaims.Add(TClaim.Create(Strings[I]));
    finally
      Free;
    end;
end;

function TTask_AoC.NoIntersections: Integer;
var
  I, J: Integer;
  Intersects: Boolean;
begin
  Result := -1;
  for I := 0 to FClaims.Count - 1 do
    begin
      Intersects := False;

      for J := 0 to FClaims.Count - 1 do
        if (I <> J) and FClaims[I].Rect.IntersectsWith(FClaims[J].Rect) then
          begin
            Intersects := True;
            Break;
          end;

      if not Intersects then
        Exit(FClaims[I].ID);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 3, 'No Matter How You Slice It');

finalization
  GTask.Free;

end.
