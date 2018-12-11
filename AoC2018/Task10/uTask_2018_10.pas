unit uTask_2018_10;

interface

uses
  uTask, uStars_2018_10;

type
  TTask_AoC = class (TTask)
  private
    FStars: TStars;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, uForm_2018_10;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  I: Integer;
begin
  FStars := TStars.Create;

  try
    with Input do
      try
        for I := 0 to Count - 1 do
          FStars.Add(TStar.Create(Strings[I]));
      finally
        Free;
      end;

    fMain_2018_10 := TfMain_2018_10.Create(nil);
    fMain_2018_10.Stars := FStars;
    fMain_2018_10.ShowModal;
  finally
    FStars.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 10, 'The Stars Align');

finalization
  GTask.Free;

end.
