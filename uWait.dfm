object frmWait: TfrmWait
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Please wait while scanning'
  ClientHeight = 58
  ClientWidth = 361
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 111
    Height = 13
    Caption = 'Currently scanning for:'
  end
  object lblProgramName: TLabel
    Left = 125
    Top = 8
    Width = 228
    Height = 13
    AutoSize = False
    Caption = 'lblProgramName'
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 27
    Width = 345
    Height = 23
    Step = 1
    TabOrder = 0
  end
  object DKLanguageController1: TDKLanguageController
    IgnoreList.Strings = (
      'lblProgramName.Caption')
    Left = 328
    LangData = {
      070066726D57616974010100000001000000070043617074696F6E0103000000
      06004C6162656C31010100000002000000070043617074696F6E000E006C626C
      50726F6772616D4E616D6500000C0050726F6772657373426172310000}
  end
end
