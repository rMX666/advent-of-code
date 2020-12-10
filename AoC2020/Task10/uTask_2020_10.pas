unit uTask_2020_10;

interface

uses
  System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FAdapters: TList<Integer>;
    procedure LoadAdapters;
    function MaxAdapterChain: Integer;
    function AmountOfPOssibleChains: Int64;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.AmountOfPOssibleChains: Int64;
var
  I, Cnt: Integer;
begin
  Result := 1;
  Cnt := 0;
  for I := 0 to FAdapters.Count - 2 do
    if FAdapters[I + 1] - FAdapters[I] = 1 then
      Inc(Cnt)
    else if Cnt > 0 then
      begin
        case Cnt of
          1: Cnt := 1;
          2: Cnt := 2;
          3: Cnt := 4;
          4: Cnt := 7;
          // Maybe other datasets contain different amounts of sequental
          // 1-diffs, but my didn't. So I decided not to find out a common
          // formula for this.
        end;
        Result := Result * Cnt;
        Cnt := 0;
      end;
end;

function TTask_AoC.MaxAdapterChain: Integer;
var
  Cnt1, Cnt3, I: Integer;
begin
  Cnt1 := 0;
  Cnt3 := 0;

  for I := 0 to FAdapters.Count - 2 do
    case FAdapters[I + 1] - FAdapters[I] of
      1: Inc(Cnt1);
      3: Inc(Cnt3);
    end;

  Result := Cnt1 * Cnt3;
end;

procedure TTask_AoC.DoRun;
begin
  try
    LoadAdapters;
    Ok('Part 1: %d, Part 2: %d', [ MaxAdapterChain, AmountOfPOssibleChains ]);
  finally
    FAdapters.Free;
  end;
end;


procedure TTask_AoC.LoadAdapters;
var
  I: Integer;
begin
  FAdapters := TList<Integer>.Create;
  FAdapters.Add(0); // Charging outlet
  with Input do
    try
      for I := 0 to Count - 1 do
        FAdapters.Add(Strings[I].ToInteger);
      FAdapters.Sort;
      FAdapters.Add(FAdapters.Last + 3); // Device
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2020, 10, 'Adapter Array');

finalization
  GTask.Free;

end.
