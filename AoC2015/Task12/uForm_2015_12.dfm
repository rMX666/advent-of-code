object fMain_2015_12: TfMain_2015_12
  Left = 0
  Top = 0
  Caption = 'Advent of Code 2015 - Day 12'
  ClientHeight = 575
  ClientWidth = 755
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object vstJSON: TVirtualStringTree
    AlignWithMargins = True
    Left = 3
    Top = 44
    Width = 749
    Height = 528
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = -1
    TabOrder = 0
    OnDrawText = vstJSONDrawText
    OnFreeNode = vstJSONFreeNode
    OnGetText = vstJSONGetText
    OnGetNodeDataSize = vstJSONGetNodeDataSize
    Columns = <>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 755
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblResult: TLabel
      Left = 176
      Top = 14
      Width = 40
      Height = 13
      Caption = 'lblResult'
    end
    object btnExpandAll: TButton
      Left = 3
      Top = 9
      Width = 126
      Height = 25
      Caption = 'Expand all'
      TabOrder = 0
      OnClick = btnExpandAllClick
    end
  end
end
