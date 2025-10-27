object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'DelphiSourceArt - Code Visualisierung'
  ClientHeight = 700
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblStatus: TLabel
      Left = 16
      Top = 40
      Width = 192
      Height = 13
      Caption = 'Bereit - Bitte eine .pas-Datei ausw'#228'hlen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnAnalyze: TButton
      Left = 16
      Top = 8
      Width = 200
      Height = 25
      Caption = 'Datei analysieren...'
      TabOrder = 0
      OnClick = btnAnalyzeClick
    end
  end
  object PaintBox: TPaintBox
    Left = 0
    Top = 65
    Width = 1000
    Height = 635
    Align = alClient
    Color = clBlack
    ParentColor = False
    OnMouseMove = PaintBoxMouseMove
    OnPaint = PaintBoxPaint
  end
  object OpenDialog: TOpenDialog
    Filter = 'Delphi Units (*.pas)|*.pas|All Files (*.*)|*.*'
    Title = 'Delphi Quelldatei ausw'#228'hlen'
    Left = 248
    Top = 16
  end
  object Timer: TTimer
    Enabled = False
    Interval = 50
    OnTimer = TimerTimer
    Left = 312
    Top = 16
  end
end
