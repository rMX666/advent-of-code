object fMain_2018_19: TfMain_2018_19
  Left = 0
  Top = 0
  Caption = 'Advent of Code 2018 - Day 19'
  ClientHeight = 688
  ClientWidth = 288
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnShortCut = FormShortCut
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 561
    Width = 288
    Height = 8
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 275
    ExplicitWidth = 384
  end
  object lbProgram: TListBox
    Left = 0
    Top = 35
    Width = 288
    Height = 526
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ItemHeight = 15
    ParentFont = False
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 288
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 95
      Top = 10
      Width = 55
      Height = 13
      Caption = 'Break After'
    end
    object Label2: TLabel
      Left = 232
      Top = 12
      Width = 10
      Height = 13
      Caption = 'r0'
    end
    object btnRun: TButton
      AlignWithMargins = True
      Left = 47
      Top = 3
      Width = 42
      Height = 29
      Align = alLeft
      Caption = 'Run'
      TabOrder = 0
      OnClick = btnRunClick
    end
    object btnStep: TButton
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 38
      Height = 29
      Align = alLeft
      Caption = 'Step'
      TabOrder = 1
      OnClick = btnStepClick
    end
    object edBreak: TEdit
      Left = 160
      Top = 8
      Width = 33
      Height = 21
      TabOrder = 2
    end
    object edR0: TEdit
      Left = 248
      Top = 8
      Width = 33
      Height = 21
      TabOrder = 3
      OnKeyPress = edR0KeyPress
    end
  end
  object lbRegisters: TListBox
    Left = 0
    Top = 569
    Width = 288
    Height = 119
    Align = alBottom
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ItemHeight = 15
    ParentFont = False
    TabOrder = 2
  end
end
