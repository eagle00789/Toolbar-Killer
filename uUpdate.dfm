object frmUpdate: TfrmUpdate
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Update'
  ClientHeight = 240
  ClientWidth = 345
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
  object Label1: TLabel
    Left = 8
    Top = 5
    Width = 329
    Height = 13
    AutoSize = False
    Caption = 'Idle...'
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 24
    Width = 329
    Height = 17
    Smooth = True
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 47
    Width = 329
    Height = 74
    Caption = 'Installed version'
    TabOrder = 1
    object Label2: TLabel
      Left = 16
      Top = 24
      Width = 69
      Height = 13
      Caption = 'Detection File:'
    end
    object Label3: TLabel
      Left = 16
      Top = 43
      Width = 40
      Height = 13
      Caption = 'Program'
    end
    object Label4: TLabel
      Left = 104
      Top = 24
      Width = 185
      Height = 13
      AutoSize = False
    end
    object Label5: TLabel
      Left = 104
      Top = 43
      Width = 185
      Height = 13
      AutoSize = False
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 127
    Width = 329
    Height = 74
    Caption = 'Online Version'
    TabOrder = 2
    object Label6: TLabel
      Left = 104
      Top = 43
      Width = 185
      Height = 13
      AutoSize = False
    end
    object Label7: TLabel
      Left = 16
      Top = 43
      Width = 40
      Height = 13
      Caption = 'Program'
    end
    object Label8: TLabel
      Left = 16
      Top = 24
      Width = 69
      Height = 13
      Caption = 'Detection File:'
    end
    object Label9: TLabel
      Left = 104
      Top = 24
      Width = 185
      Height = 13
      AutoSize = False
    end
  end
  object Button1: TButton
    Left = 262
    Top = 207
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 3
  end
  object Button2: TButton
    Left = 181
    Top = 207
    Width = 75
    Height = 25
    Caption = '&Check'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 181
    Top = 207
    Width = 75
    Height = 25
    Caption = '&Update'
    TabOrder = 5
    Visible = False
    OnClick = Button3Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 8
    Top = 208
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer2Timer
    Left = 40
    Top = 208
  end
  object DKLanguageController1: TDKLanguageController
    Left = 72
    Top = 208
    LangData = {
      090066726D557064617465010100000001000000070043617074696F6E011100
      000006004C6162656C31010100000002000000070043617074696F6E000C0050
      726F6772657373426172310000090047726F7570426F78310101000000030000
      00070043617074696F6E0006004C6162656C3201010000000400000007004361
      7074696F6E0006004C6162656C33010100000005000000070043617074696F6E
      0006004C6162656C34000006004C6162656C350000090047726F7570426F7832
      010100000006000000070043617074696F6E0006004C6162656C36000006004C
      6162656C37010100000007000000070043617074696F6E0006004C6162656C38
      010100000008000000070043617074696F6E0006004C6162656C390000070042
      7574746F6E31010100000009000000070043617074696F6E000700427574746F
      6E3201010000000A000000070043617074696F6E00060054696D657231000006
      0054696D65723200000700427574746F6E3301010000000B0000000700436170
      74696F6E00}
  end
end
