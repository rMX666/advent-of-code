unit uForm_2015_12;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, System.Generics.Collections,
  uJSON_2015_12, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfMain_2015_12 = class(TForm)
    vstJSON: TVirtualStringTree;
    Panel1: TPanel;
    btnExpandAll: TButton;
    lblResult: TLabel;
    procedure vstJSONGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure vstJSONFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstJSONGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure vstJSONDrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);
    procedure btnExpandAllClick(Sender: TObject);
  public
    procedure ShowJSON(const Item: TJSONItem; const ParentNode: PVirtualNode = nil; const Key: String = '');
    procedure SetResult(const S: String);
  end;

var
  fMain_2015_12: TfMain_2015_12;

implementation

type
  PJSONNodeData = ^TJSONNodeData;
  TJSONNodeData = record
    Text: String;
    Item: TJSONItem;
  end;

{$R *.dfm}

{ TfMain_2015_12 }

procedure TfMain_2015_12.btnExpandAllClick(Sender: TObject);
begin
  vstJSON.FullExpand;
end;

procedure TfMain_2015_12.SetResult(const S: String);
begin
  lblResult.Caption := S;
end;

procedure TfMain_2015_12.ShowJSON(const Item: TJSONItem; const ParentNode: PVirtualNode; const Key: String);
var
  Data: PJSONNodeData;
  Child: TJSONItem;
  ChildPair: TPair<String, TJSONItem>;
  Node: PVirtualNode;
begin
  Node := vstJSON.AddChild(ParentNode);
  Data := vstJSON.GetNodeData(Node);
  if Key <> '' then
    Data.Text := Key + ': ' + Item.ToString
  else
    Data.Text := Item.ToString;
  Data.Item := Item;

  case Item.ObjectType of
    jsonObject:
      for ChildPair in Item.AsObject do
        ShowJSON(ChildPair.Value, Node, ChildPair.Key);
    jsonArray:
      for Child in Item.AsList do
        ShowJSON(Child, Node);
  end;
end;

procedure TfMain_2015_12.vstJSONDrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);

var
  Data: PJSONNodeData;

  function GetFixedRect: TRect;
  begin
    Result := CellRect;
    Dec(Result.Left, 4);
    Result.Right := Result.Left + TargetCanvas.TextWidth(Data.Text) + 8;
  end;

var
  Item: TJSONItem;
begin
  Data := Sender.GetNodeData(Node);

  case Data.Item.ObjectType of
    jsonNumber:
      begin
        TargetCanvas.Brush.Color := clWebLightGreen;
        TargetCanvas.FillRect(GetFixedRect);
      end;
    jsonObject:
      for Item in Data.Item.AsObject.Values do
        if Item.ObjectType = jsonString then
          if Item.AsString = 'red' then
            begin
              TargetCanvas.Brush.Color := clWebLightCoral;
              TargetCanvas.FillRect(GetFixedRect);
            end;
  end;
end;

procedure TfMain_2015_12.vstJSONFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PJSONNodeData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^);
end;

procedure TfMain_2015_12.vstJSONGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TJSONNodeData);
end;

procedure TfMain_2015_12.vstJSONGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
var
  Data: PJSONNodeData;
begin
  Data := Sender.GetNodeData(Node);
  CellText := Data.Text;
end;

end.
