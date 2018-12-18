object fMain_2018_17: TfMain_2018_17
  Left = 0
  Top = 0
  Caption = 'Advent of Code 2018 - Day 17'
  ClientHeight = 961
  ClientWidth = 484
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
    Width = 484
    Height = 961
    Align = alClient
    DefaultColWidth = 2
    DefaultRowHeight = 2
    DoubleBuffered = True
    FixedCols = 0
    FixedRows = 0
    GridLineWidth = 0
    ParentDoubleBuffered = False
    TabOrder = 0
    OnDrawCell = sgMapDrawCell
    OnMouseWheelDown = sgMapMouseWheelDown
    OnMouseWheelUp = sgMapMouseWheelUp
    ExplicitWidth = 635
    ExplicitHeight = 299
  end
end
