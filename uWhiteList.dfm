object frmWhiteList: TfrmWhiteList
  Left = 420
  Top = 316
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'White-List'
  ClientHeight = 480
  ClientWidth = 617
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 41
    Height = 13
    Caption = 'Toolbars'
  end
  object Label2: TLabel
    Left = 328
    Top = 8
    Width = 41
    Height = 13
    Caption = 'Whitelist'
  end
  object lstbxToolbars: TListBox
    Left = 8
    Top = 27
    Width = 281
    Height = 414
    Style = lbOwnerDrawVariable
    ItemHeight = 16
    MultiSelect = True
    Sorted = True
    TabOrder = 0
    OnDrawItem = lstbxToolbarsDrawItem
    OnMeasureItem = lstbxToolbarsMeasureItem
  end
  object Button1: TButton
    Left = 295
    Top = 184
    Width = 27
    Height = 25
    Caption = '>'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 295
    Top = 215
    Width = 27
    Height = 25
    Caption = '<'
    TabOrder = 2
    OnClick = Button2Click
  end
  object lstbxWhiteListedToolbars: TListBox
    Left = 328
    Top = 27
    Width = 281
    Height = 414
    Style = lbOwnerDrawVariable
    ItemHeight = 13
    MultiSelect = True
    Sorted = True
    TabOrder = 3
    OnDrawItem = lstbxWhiteListedToolbarsDrawItem
    OnMeasureItem = lstbxWhiteListedToolbarsMeasureItem
  end
  object Button3: TButton
    Left = 534
    Top = 447
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object Button4: TButton
    Left = 453
    Top = 447
    Width = 75
    Height = 25
    Caption = '&Ok'
    ModalResult = 1
    TabOrder = 5
    OnClick = Button4Click
  end
  object DKLanguageController1: TDKLanguageController
    Left = 296
    Top = 152
    LangData = {
      0C0066726D57686974654C697374010100000001000000070043617074696F6E
      010800000006004C6162656C31010100000002000000070043617074696F6E00
      0D006C73746278546F6F6C6261727300000700427574746F6E31000007004275
      74746F6E32000018006C7374627857686974654C6973746564546F6F6C626172
      73000006004C6162656C32010100000003000000070043617074696F6E000700
      427574746F6E33010100000004000000070043617074696F6E00070042757474
      6F6E34010100000005000000070043617074696F6E00}
  end
end
