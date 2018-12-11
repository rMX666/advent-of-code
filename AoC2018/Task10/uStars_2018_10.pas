unit uStars_2018_10;

interface

uses
  System.Types, System.Generics.Collections;

type
  TStar = class
    Position, V: TPoint;
    constructor Create(const S: String);
  end;

  TStars = class(TObjectList<TStar>)
  private
    FStepsDone: Integer;
  public
    constructor Create;
    procedure Step(const Rect: TRect);
    property StepsDone: Integer read FStepsDone;
  end;

implementation

uses
  System.SysUtils;

{ TStar }

constructor TStar.Create(const S: String);
var
  A: TArray<String>;
begin
  A := S.Replace('position=<', ' ').Replace('> velocity=<', ' ').Replace('>', '').Replace('  ', ' ').Trim.Split([', ', ' ']);
  Position.X := A[0].ToInteger;
  Position.Y := A[1].ToInteger;
  V.X := A[2].ToInteger;
  V.Y := A[3].ToInteger;
end;

{ TStars }

constructor TStars.Create;
begin
  inherited Create;
  FStepsDone := 0;
end;

procedure TStars.Step(const Rect: TRect);
var
  I: Integer;
  Work: Boolean;
begin
  Work := True;
  while Work do
    begin
      for I := 0 to Count - 1 do
        begin
          Items[I].Position := Items[I].Position + Items[I].V;
          if Rect.Contains(Items[I].Position) then
            Work := False;
        end;
      Inc(FStepsDone);
    end;
end;

end.
