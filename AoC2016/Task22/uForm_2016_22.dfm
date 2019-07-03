object fForm_2016_22: TfForm_2016_22
  Left = 0
  Top = 0
  Caption = 'AoC 22'
  ClientHeight = 552
  ClientWidth = 1725
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    1725
    552)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 385
    Width = 88
    Height = 13
    Caption = 'Update delay (ms)'
  end
  object Label2: TLabel
    Left = 8
    Top = 413
    Width = 32
    Height = 13
    Caption = 'Target'
  end
  object Label3: TLabel
    Left = 90
    Top = 413
    Width = 6
    Height = 13
    Caption = 'X'
  end
  object Label4: TLabel
    Left = 154
    Top = 413
    Width = 6
    Height = 13
    Caption = 'Y'
  end
  object Label5: TLabel
    Left = 8
    Top = 440
    Width = 33
    Height = 13
    Caption = 'Source'
  end
  object Label6: TLabel
    Left = 90
    Top = 440
    Width = 6
    Height = 13
    Caption = 'X'
  end
  object Label7: TLabel
    Left = 154
    Top = 440
    Width = 6
    Height = 13
    Caption = 'Y'
  end
  object mmNodes: TMemo
    Left = 8
    Top = 70
    Width = 273
    Height = 194
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnGo: TButton
    Left = 8
    Top = 8
    Width = 273
    Height = 25
    Caption = 'Go'
    TabOrder = 1
    OnClick = btnGoClick
  end
  object sgNodes: TStringGrid
    Left = 287
    Top = 8
    Width = 1430
    Height = 536
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 34
    DefaultColWidth = 40
    DefaultRowHeight = 16
    RowCount = 31
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial Narrow'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnDrawCell = sgNodesDrawCell
  end
  object rgHeuristics: TRadioGroup
    Left = 8
    Top = 270
    Width = 273
    Height = 106
    Caption = 'Heuristics'
    ItemIndex = 0
    Items.Strings = (
      'None'
      'Manhattan'
      'Euclidian'
      'Chebishev'
      'Octile')
    TabOrder = 3
  end
  object edUpdateDelay: TSpinEdit
    Left = 102
    Top = 382
    Width = 179
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 4
    Value = 20
  end
  object edTargetX: TEdit
    Left = 102
    Top = 410
    Width = 43
    Height = 21
    TabOrder = 5
    Text = '32'
  end
  object edTargetY: TEdit
    Left = 166
    Top = 410
    Width = 43
    Height = 21
    TabOrder = 6
    Text = '0'
  end
  object edSourceX: TEdit
    Left = 102
    Top = 437
    Width = 43
    Height = 21
    TabOrder = 7
    Text = '0'
  end
  object edSourceY: TEdit
    Left = 166
    Top = 437
    Width = 43
    Height = 21
    TabOrder = 8
    Text = '0'
  end
  object btnViableCount: TButton
    Left = 8
    Top = 39
    Width = 273
    Height = 25
    Caption = 'Viable count'
    TabOrder = 9
    OnClick = btnViableCountClick
  end
end
