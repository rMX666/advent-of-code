object fMain_2018_13: TfMain_2018_13
  Left = 0
  Top = 0
  Caption = 'Advent of Code 2018 - Day 13'
  ClientHeight = 620
  ClientWidth = 620
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object sgMap: TDrawGrid
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 614
    Height = 614
    Align = alClient
    DefaultColWidth = 4
    DefaultRowHeight = 4
    DoubleBuffered = True
    FixedCols = 0
    FixedRows = 0
    GridLineWidth = 0
    ParentDoubleBuffered = False
    TabOrder = 0
    OnDrawCell = sgMapDrawCell
  end
end
