object fForm_2019_21: TfForm_2019_21
  Left = 0
  Top = 0
  Caption = 'Advent of Code 2019 - Day 21'
  ClientHeight = 626
  ClientWidth = 683
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object mmProgram: TMemo
    Left = 8
    Top = 8
    Width = 185
    Height = 313
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnRun: TButton
    Left = 8
    Top = 327
    Width = 185
    Height = 25
    Caption = 'Run'
    TabOrder = 1
    OnClick = btnRunClick
  end
  object mmOutput: TMemo
    Left = 199
    Top = 8
    Width = 290
    Height = 610
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object btnPart1: TButton
    Left = 8
    Top = 358
    Width = 185
    Height = 25
    Caption = 'Part 1'
    TabOrder = 3
    OnClick = btnPart1Click
  end
  object btnPart2: TButton
    Left = 8
    Top = 389
    Width = 185
    Height = 25
    Caption = 'Part 2'
    TabOrder = 4
    OnClick = btnPart2Click
  end
end
