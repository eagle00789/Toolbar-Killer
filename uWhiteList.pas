unit uWhiteList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DKLang, StdCtrls, IniFiles, strUtils;

type
  TfrmWhiteList = class(TForm)
    DKLanguageController1: TDKLanguageController;
    Label1: TLabel;
    lstbxToolbars: TListBox;
    Button1: TButton;
    Button2: TButton;
    lstbxWhiteListedToolbars: TListBox;
    Label2: TLabel;
    Button3: TButton;
    Button4: TButton;
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure lstbxWhiteListedToolbarsMeasureItem(Control: TWinControl;
      Index: Integer; var Height: Integer);
    procedure lstbxWhiteListedToolbarsDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lstbxToolbarsMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure lstbxToolbarsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmWhiteList: TfrmWhiteList;

implementation

uses uMain;

{$R *.dfm}

procedure TfrmWhiteList.Button1Click(Sender: TObject);
var
  i: Integer;
  j: Array of Integer;
begin
  for i := 1 to lstbxToolbars.Count do begin
    if lstbxToolbars.Selected[i-1] then begin
      lstbxWhiteListedToolbars.Items.Add(lstbxToolbars.Items.Strings[i-1]);
      SetLength(j, Length(j) + 1);
      j[length(j)-1] := i-1;
    end;
  end;
  for i := Length(j) - 1 downto 0 do begin
    lstbxToolbars.Items.Delete(j[i]);
  end;
end;

procedure TfrmWhiteList.Button2Click(Sender: TObject);
var
  i: Integer;
  j: Array of Integer;
begin
  for i := 1 to lstbxWhiteListedToolbars.Count do begin
    if lstbxWhiteListedToolbars.Selected[i-1] then begin
      lstbxToolbars.Items.Add(lstbxWhiteListedToolbars.Items.Strings[i-1]);
      SetLength(j, Length(j) + 1);
      j[length(j)-1] := i-1;
    end;
  end;
  for i := Length(j) - 1 downto 0 do begin
    lstbxWhiteListedToolbars.Items.Delete(j[i]);
  end;
end;

procedure TfrmWhiteList.Button4Click(Sender: TObject);
  function SizeI(I: Integer): String;
  begin
    case I of
      0..9: SizeI := '000' + IntToStr(I);
      10..99: SizeI := '00' + IntToStr(I);
      100..999: SizeI := '0' + IntToStr(I);
      1000..9999: SizeI := '' + IntToStr(I);
    end;
  end;
var
  iniSettings: TIniFile;
  IniSettingsFileName, j: String;
  I: Integer;
begin
  IniSettingsFileName := ExtractFilePath(Application.ExeName) + 'settings.ini';
  IniSettings := TIniFile.Create(IniSettingsFileName);
  IniSettings.EraseSection('Whitelist');
  for I := 1 to lstbxWhiteListedToolbars.Count do begin
    j := SizeI(I);
    IniSettings.WriteString('Whitelist', j, lstbxWhiteListedToolbars.Items.Strings[i-1]);
  end;
  FreeAndNil(IniSettings);
end;

procedure TfrmWhiteList.FormCreate(Sender: TObject);
var
  i, j, BlackListLevel: Integer;
  iniSettings: TIniFile;
  IniSettingsFileName: String;
begin
  IniSettingsFileName := ExtractFilePath(Application.ExeName) + 'settings.ini';
  IniSettings := TIniFile.Create(IniSettingsFileName);
  frmMain.ToolbarWhiteList := TStringList.Create;
  IniSettings.ReadSectionValues('Whitelist', frmMain.ToolbarWhiteList);
  FreeAndNil(IniSettings);
  for j := 1 to frmMain.ToolbarWhiteList.Count do begin
    frmMain.ToolbarWhiteList.Strings[j-1] := RightStr(frmMain.ToolbarWhiteList.Strings[j-1], Length(frmMain.ToolbarWhiteList.Strings[j-1]) - 5);
  end;
  for i := 2 to uMain.iToolbars.Count do begin
    BlackListLevel := frmMain.iniFile.ReadInteger(uMain.iToolbars.Strings[i-1], 'RiskLevel', 3);
    if (AutoBlackList > BlackListLevel) then begin
      if frmMain.ToolbarWhiteList.IndexOf(iToolbars.Strings[i-1]) <> -1 then begin
        lstbxWhiteListedToolbars.Items.Add(uMain.iToolbars.Strings[i-1]);
      end else begin
        lstbxToolbars.Items.Add(uMain.iToolbars.Strings[i-1]);
      end;
    end;
  end;
end;

procedure TfrmWhiteList.lstbxToolbarsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  CenterText : integer;
  TempText : String;
  Application: String;
begin
  frmMain.AddToLog('lstbxToolbarsDrawItem', True);
  lstbxToolbars.Canvas.FillRect (rect);
  TempText := lstbxToolbars.Items.Strings[index];
  Application := frmMain.IniFile.ReadString(TempText, 'Application', '');
  frmMain.ImageList1.Draw(lstbxToolbars.Canvas,rect.Left + 4, rect.Top + 4, GetAppNumber(Application) );
  CenterText := ( rect.Bottom - rect.Top - lstbxToolbars.Canvas.TextHeight(text)) div 2 ;
  lstbxToolbars.Canvas.TextOut (rect.left + frmMain.ImageList1.Width + 8 , rect.Top + CenterText, lstbxToolbars.Items.Strings[index]);
end;

procedure TfrmWhiteList.lstbxToolbarsMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  height := frmMain.ImageList1.Height + 4;
end;

procedure TfrmWhiteList.lstbxWhiteListedToolbarsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  CenterText : integer;
  TempText : String;
  Application: String;
begin
  frmMain.AddToLog('lstbxWhiteListedToolbarsDrawItem', True);
  lstbxWhiteListedToolbars.Canvas.FillRect (rect);
  TempText := lstbxWhiteListedToolbars.Items.Strings[index];
  Application := frmMain.IniFile.ReadString(TempText, 'Application', '');
  frmMain.ImageList1.Draw(lstbxWhiteListedToolbars.Canvas,rect.Left + 4, rect.Top + 4, GetAppNumber(Application) );
  CenterText := ( rect.Bottom - rect.Top - lstbxToolbars.Canvas.TextHeight(text)) div 2 ;
  lstbxWhiteListedToolbars.Canvas.TextOut (rect.left + frmMain.ImageList1.Width + 8 , rect.Top + CenterText, lstbxWhiteListedToolbars.Items.Strings[index]);
end;

procedure TfrmWhiteList.lstbxWhiteListedToolbarsMeasureItem(
  Control: TWinControl; Index: Integer; var Height: Integer);
begin
  height := frmMain.ImageList1.Height + 4;
end;

end.
