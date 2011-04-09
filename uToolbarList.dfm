object frmToolbarList: TfrmToolbarList
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Toolbar List'
  ClientHeight = 447
  ClientWidth = 518
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
    Width = 94
    Height = 13
    Caption = 'Detectable toolbars'
  end
  object lstbxToolbars: TListBox
    Left = 8
    Top = 24
    Width = 502
    Height = 384
    Style = lbOwnerDrawVariable
    ItemHeight = 16
    Sorted = True
    TabOrder = 0
    OnDrawItem = lstbxToolbarsDrawItem
    OnMeasureItem = lstbxToolbarsMeasureItem
  end
  object Button1: TButton
    Left = 435
    Top = 414
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 1
  end
end
