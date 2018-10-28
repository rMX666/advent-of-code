unit uTask_2015_12;

interface

uses
  uTask, uJSON_2015_12;

type
  TTask_AoC = class (TTask)
  private
    FNumberSum: Integer;
    FPart: Integer;
    procedure JSONTraverse(const Item: TJSONItem; var AllowGoDeeper: Boolean);
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, Vcl.Forms, uForm_2015_12;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
var
  JSON: TJSONItem;
  Result1, Result2: Integer;
begin
  with Input do
    try
      JSON := TJSONParser.Parse(Text.Trim);
      JSON.OnJSONTraverse := JSONTraverse;

      FNumberSum := 0;
      FPart := 1;
      JSON.Traverse;
      Result1 := FNumberSum;

      FNumberSum := 0;
      FPart := 2;
      JSON.Traverse;
      Result2 := FNumberSum;

      with TfMain_2015_12.Create(Application) do
        try
          ShowJSON(JSON);
          SetResult(Format('Part 1: %d, Part 2: %d', [ Result1, Result2 ]));
          ShowModal;
        finally
          Free;
        end;
    finally
      JSON.Free;
      Free;
    end;
end;

procedure TTask_AoC.JSONTraverse(const Item: TJSONItem; var AllowGoDeeper: Boolean);
var
  Child: TJSONItem;
begin
  if FPart = 2 then
    if Item.ObjectType = jsonObject then
      for Child in Item.AsObject.Values do
        if Child.ObjectType = jsonString then
          if Child.AsString = 'red' then
            begin
              AllowGoDeeper := False;
              Exit;
            end;

  if Item.ObjectType = jsonNumber then
    Inc(FNumberSum, Item.AsNumber);
end;

initialization
  GTask := TTask_AoC.Create(2015, 12, 'JSAbacusFramework.io');

finalization
  GTask.Free;

end.
