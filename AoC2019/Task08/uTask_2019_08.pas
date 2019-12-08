unit uTask_2019_08;

interface

uses
  uTask, System.Generics.Collections;

type
  TLayer = TList<String>;

  TTask_AoC = class (TTask)
  private const
    WIDTH  = 25;
    HEIGHT = 6;
  private
    FLayers: TObjectList<TLayer>;
    procedure LoadImage;
    function LayerChecksum: Integer;
    procedure DrawImage;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math, uForm_2019_08;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadImage;
  try
    OK('Part 1: %d', [ LayerChecksum ]);
    DrawImage;
  finally
    FLayers.Free;
  end;
end;

procedure TTask_AoC.DrawImage;
var
  Layer: TLayer;
  I, J, K: Integer;
  Row: String;
begin
  fForm_2019_08 := TfForm_2019_08.Create(nil);

  Layer := TLayer.Create(FLayers[0]);

  try
    for I := 1 to FLayers.Count - 1 do
      for J := 0 to FLayers[I].Count - 1 do
        begin
          Row := Layer[J];
          for K := 1 to WIDTH do
            if (Layer[J][K] = '2') then
              Row[K] := FLayers[I][J][K];
          Layer[J] := Row;
        end;

    fForm_2019_08.DrawLayer(Layer);
    fForm_2019_08.ShowModal;
  finally
    Layer.Free;
  end;
end;

function TTask_AoC.LayerChecksum: Integer;

  function CountChar(const S: String; const C: Char): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 1 to S.Length do
      if S[I] = C then
        Inc(Result);
  end;

var
  I, J, ZeroCnt, OneCnt, TwoCnt: Integer;
  Layer: TLayer;
begin
  Result := MaxInt;
  Layer := nil;
  for I := 0 to FLayers.Count - 1 do
    begin
      ZeroCnt := 0;
      for J := 0 to FLayers[I].Count - 1 do
        Inc(ZeroCnt, CountChar(FLayers[I][J], '0'));

      if Result > ZeroCnt then
        begin
          Result := ZeroCnt;
          Layer := FLayers[I];
        end;
    end;

  if Layer = nil then
    Exit(-1);

  OneCnt := 0;
  TwoCnt := 0;
  for I := 0 to Layer.Count - 1 do
    begin
      Inc(OneCnt, CountChar(Layer[I], '1'));
      Inc(TwoCnt, CountChar(Layer[I], '2'));
    end;

  Result := OneCnt * TwoCnt;
end;

procedure TTask_AoC.LoadImage;
var
  S: String;
  I: Integer;
  Layer: TLayer;
begin
  with Input do
    try
      S := Text.Trim;
    finally
      Free;
    end;

  FLayers := TObjectList<TLayer>.Create;

  I := 0;
  Layer := TLayer.Create;
  while I < S.Length do
    begin
      Layer.Add(S.Substring(I, WIDTH));
      Inc(I, WIDTH);

      if Layer.Count >= HEIGHT then
        begin
          FLayers.Add(Layer);
          Layer := TLayer.Create;
        end;
    end;
  if Layer.Count = 0 then
    Layer.Free;
end;

initialization
  GTask := TTask_AoC.Create(2019, 8, 'Space Image Format');

finalization
  GTask.Free;

end.
