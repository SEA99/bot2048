object Form1: TForm1
  Left = 789
  Top = 190
  BorderStyle = bsToolWindow
  Caption = 'Form1'
  ClientHeight = 235
  ClientWidth = 469
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TSpeedButton
    Left = 0
    Top = 64
    Width = 65
    Height = 105
    Caption = #1074#1083#1077#1074#1086
    OnClick = BitBtn1Click
  end
  object BitBtn2: TSpeedButton
    Left = 326
    Top = 64
    Width = 65
    Height = 105
    Caption = #1074#1087#1088#1072#1074#1086
    OnClick = BitBtn2Click
  end
  object BitBtn3: TSpeedButton
    Left = 62
    Top = 0
    Width = 267
    Height = 65
    Caption = #1074#1074#1077#1088#1093
    OnClick = BitBtn3Click
  end
  object BitBtn4: TSpeedButton
    Left = 62
    Top = 168
    Width = 267
    Height = 65
    Caption = #1074#1085#1080#1079
    OnClick = BitBtn4Click
  end
  object BitBtn5: TSpeedButton
    Left = 344
    Top = 35
    Width = 104
    Height = 25
    Caption = 'best action'
    OnClick = BitBtn5Click
  end
  object Button1: TSpeedButton
    Left = 336
    Top = 184
    Width = 129
    Height = 33
    OnClick = Button1Click
  end
  object SpeedButton1: TSpeedButton
    Left = 408
    Top = 67
    Width = 48
    Height = 46
    Caption = 'self'
    OnClick = BitBtn5Click
  end
  object Label1: TLabel
    Left = 336
    Top = 222
    Width = 3
    Height = 13
  end
  object SpeedButton2: TSpeedButton
    Left = 0
    Top = 171
    Width = 25
    Height = 22
    Caption = 'bot1'
    OnClick = SpeedButton2Click
  end
  object SpeedButton3: TSpeedButton
    Left = 0
    Top = 11
    Width = 49
    Height = 38
    Caption = 'add new'
    Enabled = False
    OnClick = SpeedButton3Click
  end
  object SpeedButton4: TSpeedButton
    Left = 0
    Top = 203
    Width = 25
    Height = 22
    Caption = 'bot2'
    OnClick = SpeedButton4Click
  end
  object SpeedButton5: TSpeedButton
    Left = 32
    Top = 171
    Width = 25
    Height = 22
    Caption = 'bot3'
    OnClick = SpeedButton5Click
  end
  object Grid: TDrawGrid
    Left = 64
    Top = 64
    Width = 263
    Height = 103
    TabStop = False
    ColCount = 4
    FixedCols = 0
    RowCount = 4
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnDrawCell = GridDrawCell
    OnMouseDown = GridMouseDown
  end
  object CheckRandom: TCheckBox
    Left = 344
    Top = 8
    Width = 97
    Height = 17
    TabStop = False
    Caption = 'random'
    TabOrder = 1
    OnClick = CheckRandomClick
  end
end
