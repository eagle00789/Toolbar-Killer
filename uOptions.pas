unit uOptions;

{$INCLUDE TntCompilers.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DKLang;

type
  TfrmOptions = class(TForm)
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    GroupBox2: TGroupBox;
    CheckBox3: TCheckBox;
    GroupBox3: TGroupBox;
    CheckBox4: TCheckBox;
    GroupBox4: TGroupBox;
    CheckBox5: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox6: TCheckBox;
    DKLanguageController1: TDKLanguageController;
    GroupBox5: TGroupBox;
    cmbLanguage: TComboBox;
    GroupBox6: TGroupBox;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure cmbLanguageChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation

uses uUpdate, uMain, uBlackList, uWhiteList, uToolbarList;

{$R *.dfm}
  {emptyupdatefolderonstart}
procedure TfrmOptions.Button2Click(Sender: TObject);
begin
  frmMain.showremovewarning := CheckBox1.Checked;
  frmMain.showbrowserclosewarning := CheckBox2.Checked;
  frmMain.createlog := CheckBox3.Checked;
  frmMain.detailedlog := CheckBox4.Checked;
  frmMain.autoupdateonstart := CheckBox5.Checked;
  frmMain.clearlog := CheckBox6.Checked;
  frmMain.programlanguage := cmbLanguage.ItemIndex;
end;

procedure TfrmOptions.Button3Click(Sender: TObject);
begin
  frmUpdate.ShowModal;
  frmMain.bttnRescan.Click;
end;

procedure TfrmOptions.Button4Click(Sender: TObject);
var
  formWhiteList: TFrmWhiteList;
begin
  formWhiteList := TFrmWhiteList.Create(Application);
  formWhiteList.ShowModal;
  formWhiteList.Destroy;
end;

procedure TfrmOptions.Button5Click(Sender: TObject);
var
  formBlackList: TFrmBlackList;
begin
  formBlackList := TFrmBlackList.Create(Application);
  formBlackList.ShowModal;
  formBlackList.Destroy;
end;

procedure TfrmOptions.Button6Click(Sender: TObject);
var
  formToolbarList: TFrmToolbarList;
begin
  formToolbarList := TFrmToolbarList.Create(Application);
  formToolbarList.ShowModal;
  formToolbarList.Destroy;
end;

procedure TfrmOptions.CheckBox3Click(Sender: TObject);
begin
  Checkbox4.enabled := checkbox3.Checked;
end;

procedure TfrmOptions.cmbLanguageChange(Sender: TObject);
begin
  LangManager.LanguageID := LangManager.LanguageIDs[cmbLanguage.ItemIndex];
  frmMain.Caption := MainCaption + ' - ' + DKLangConstW('sMainCaption', [IntToStr(iToolbars.Count - 1)]);
  frmMain.AddToLog('Change Language to ' + LangManager.LanguageNames[cmbLanguage.ItemIndex], True);
  frmMain.UpdateSysMenu;
end;

procedure TfrmOptions.FormCreate(Sender: TObject);
  procedure CreateLanguageMenu;
  var
    i: Integer;
  begin
    for i := 0 to LangManager.LanguageCount-1 do begin
      cmbLanguage.Items.Add(LangManager.LanguageNames[i]);
      cmbLanguage.ItemIndex := LangManager.LanguageIndex;
    end;
  end;
begin
  // Create available languages menu
  CreateLanguageMenu;
  // Update interface elements
  frmMain.AddToLog('Create Form Options', True);
end;

procedure TfrmOptions.FormShow(Sender: TObject);
begin
  CheckBox1.Checked := frmMain.showremovewarning;
  CheckBox2.Checked := frmMain.showbrowserclosewarning;
  CheckBox3.Checked := frmMain.createlog;
  CheckBox4.Checked := frmMain.detailedlog;
  CheckBox5.Checked := frmMain.autoupdateonstart;
  CheckBox6.Checked := frmMain.clearlog;
end;

end.
