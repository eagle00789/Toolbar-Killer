object frmBlackList: TfrmBlackList
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Black-List'
  ClientHeight = 392
  ClientWidth = 521
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
    Width = 91
    Height = 13
    Caption = 'Blacklisted toolbars'
  end
  object lstbxBlackListedToolbars: TListBox
    Left = 8
    Top = 27
    Width = 505
    Height = 326
    Style = lbOwnerDrawVariable
    ItemHeight = 16
    Sorted = True
    TabOrder = 0
    OnDrawItem = lstbxBlackListedToolbarsDrawItem
    OnMeasureItem = lstbxBlackListedToolbarsMeasureItem
  end
  object Button1: TButton
    Left = 438
    Top = 359
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 1
  end
  object DKLanguageController1: TDKLanguageController
    Left = 352
    Top = 8
    LangData = {
      0C0066726D426C61636B4C697374010100000001000000070043617074696F6E
      010300000018006C73746278426C61636B4C6973746564546F6F6C6261727300
      0006004C6162656C31010100000002000000070043617074696F6E0007004275
      74746F6E31010100000003000000070043617074696F6E00}
  end
end
