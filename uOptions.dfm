object frmOptions: TfrmOptions
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 231
  ClientWidth = 696
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 337
    Height = 81
    Caption = 'Message Options'
    TabOrder = 0
    object CheckBox1: TCheckBox
      Left = 16
      Top = 24
      Width = 297
      Height = 17
      Caption = 'Show warning before &removing toolbars'
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 16
      Top = 47
      Width = 297
      Height = 17
      Caption = 'Show warning before &closing browsers'
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 95
    Width = 337
    Height = 132
    Caption = 'Log Options'
    TabOrder = 1
    object CheckBox3: TCheckBox
      Left = 16
      Top = 24
      Width = 297
      Height = 17
      Caption = 'Create &log-file'
      TabOrder = 0
      OnClick = CheckBox3Click
    end
    object GroupBox3: TGroupBox
      Left = 16
      Top = 47
      Width = 307
      Height = 74
      Caption = 'Logging Options'
      TabOrder = 1
      object CheckBox4: TCheckBox
        Left = 23
        Top = 24
        Width = 274
        Height = 17
        Caption = '&Detailed Log Files'
        Enabled = False
        TabOrder = 0
      end
      object CheckBox6: TCheckBox
        Left = 24
        Top = 48
        Width = 273
        Height = 17
        Caption = 'Clear old logfile at program start'
        TabOrder = 1
      end
    end
  end
  object GroupBox4: TGroupBox
    Left = 351
    Top = 71
    Width = 337
    Height = 55
    Caption = 'Updates'
    TabOrder = 2
    object CheckBox5: TCheckBox
      Left = 16
      Top = 24
      Width = 297
      Height = 17
      Caption = 'Check for &updates on program start'
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 613
    Top = 198
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object Button2: TButton
    Left = 532
    Top = 198
    Width = 75
    Height = 25
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 351
    Top = 198
    Width = 75
    Height = 25
    Caption = 'U&pdate'
    TabOrder = 5
    OnClick = Button3Click
  end
  object GroupBox5: TGroupBox
    Left = 351
    Top = 132
    Width = 337
    Height = 60
    Caption = 'Language'
    TabOrder = 6
    object cmbLanguage: TComboBox
      Left = 16
      Top = 26
      Width = 307
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnChange = cmbLanguageChange
    end
  end
  object GroupBox6: TGroupBox
    Left = 351
    Top = 8
    Width = 337
    Height = 57
    Caption = 'Lists'
    TabOrder = 7
    object Button4: TButton
      Left = 16
      Top = 20
      Width = 97
      Height = 25
      Caption = 'White-list'
      TabOrder = 0
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 119
      Top = 20
      Width = 97
      Height = 25
      Caption = 'Black-list'
      TabOrder = 1
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 222
      Top = 20
      Width = 97
      Height = 25
      Caption = 'All Toolbars'
      TabOrder = 2
      OnClick = Button6Click
    end
  end
  object DKLanguageController1: TDKLanguageController
    IgnoreList.Strings = (
      'cmbLanguage.Caption'
      'cmbLanguage.Items')
    Left = 312
    Top = 8
    LangData = {
      0A0066726D4F7074696F6E73010100000001000000070043617074696F6E0113
      000000090047726F7570426F7831010100000002000000070043617074696F6E
      000900436865636B426F7831010100000003000000070043617074696F6E0009
      00436865636B426F7832010100000004000000070043617074696F6E00090047
      726F7570426F7832010100000005000000070043617074696F6E000900436865
      636B426F7833010100000006000000070043617074696F6E00090047726F7570
      426F7833010100000007000000070043617074696F6E000900436865636B426F
      7834010100000008000000070043617074696F6E000900436865636B426F7836
      010100000009000000070043617074696F6E00090047726F7570426F78340101
      0000000A000000070043617074696F6E000900436865636B426F783501010000
      000B000000070043617074696F6E000700427574746F6E3101010000000C0000
      00070043617074696F6E000700427574746F6E3201010000000D000000070043
      617074696F6E000700427574746F6E3301010000000E00000007004361707469
      6F6E00090047726F7570426F783501010000000F000000070043617074696F6E
      000B00636D624C616E67756167650000090047726F7570426F78360101000000
      10000000070043617074696F6E000700427574746F6E34010100000011000000
      070043617074696F6E000700427574746F6E3501010000001200000007004361
      7074696F6E000700427574746F6E36010100000013000000070043617074696F
      6E00}
  end
end
