object fForm_2019_10: TfForm_2019_10
  Left = 0
  Top = 0
  Caption = 'Advent of Code 2019 - Day 10'
  ClientHeight = 299
  ClientWidth = 635
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
  object sgMap: TDrawGrid
    Left = 0
    Top = 0
    Width = 635
    Height = 299
    Align = alClient
    DefaultColWidth = 24
    DefaultRowHeight = 16
    FixedCols = 0
    FixedRows = 0
    TabOrder = 0
    OnDrawCell = sgMapDrawCell
    OnSelectCell = sgMapSelectCell
  end
end
