unit uTask_2015_02;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    procedure GetWHL(const S: String; var W, H, L: Integer);
    procedure GetSideAreas(const S: String; var S1, S2, S3: Integer);
    procedure Swap(var A, B: Integer);
    procedure Part1;
    procedure Part2;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Generics.Collections;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  inherited;
  Part1;
  Part2;
end;

procedure TTask_AoC.GetWHL(const S: String; var W, H, L: Integer);
var
  A: TArray<String>;
begin
  A := S.Split(['x']);
  W := StrToInt(A[0]);
  H := StrToInt(A[1]);
  L := StrToInt(A[2]);
end;

procedure TTask_AoC.Swap(var A, B: Integer);
var
  Tmp: Integer;
begin
  Tmp := A;
  A := B;
  B := Tmp;
end;

// First side - smallest
procedure TTask_AoC.GetSideAreas(const S: String; var S1, S2, S3: Integer);
var
  W, H, L: Integer;
begin
  GetWHL(S, W, H, L);

  S1 := W * H;
  S2 := W * L;
  S3 := L * H;

  if S2 < S1 then
    Swap(S1, S2);

  if S3 < S1 then
    Swap(S1, S3);
end;

procedure TTask_AoC.Part1;
var
  I, S1, S2, S3: Integer;
  Area: Integer;
begin
  Area := 0;

  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          GetSideAreas(Strings[I], S1, S2, S3);
          Inc(Area, 2*S1 + 2*S2 + 2*S3 + S1);
        end;
    finally
      Free;
    end;

  OK('Part 1: %d', [ Area ]);
end;

procedure TTask_AoC.Part2;
var
  I, W, H, L: Integer;
  RibbonLength: Integer;
begin
  RibbonLength := 0;

  with Input do
    try
      for I := 0 to Count - 1 do
        begin
          GetWHL(Strings[I], W, H, L);
          if W > H then Swap(W, H);
          if H > L then Swap(H, L);
          if W > L then Swap(W, L);

          Inc(RibbonLength, W + W + H + H + W*H*L);
        end;
    finally
      Free;
    end;

  OK('Part 2: %d', [ RibbonLength ]);
end;

initialization
  GTask := TTask_AoC.Create(2015, 2, 'I Was Told There Would Be No Math');

finalization
  GTask.Free;

end.
