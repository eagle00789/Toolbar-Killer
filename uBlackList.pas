unit uBlackList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DKLang, StdCtrls;

type
  TfrmBlackList = class(TForm)
    DKLanguageController1: TDKLanguageController;
    lstbxBlackListedToolbars: TListBox;
    Label1: TLabel;
    Button1: TButton;
    procedure lstbxBlackListedToolbarsMeasureItem(Control: TWinControl;
      Index: Integer; var Height: Integer);
    procedure lstbxBlackListedToolbarsDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBlackList: TfrmBlackList;

implementation

uses uMain;

{$R *.dfm}

procedure TfrmBlackList.FormCreate(Sender: TObject);
var
  i, BlackListLevel: Integer;
begin
  for i := 2 to uMain.iToolbars.Count do begin
    BlackListLevel := frmMain.iniFile.ReadInteger(uMain.iToolbars.Strings[i-1], 'RiskLevel', 3);
    if (AutoBlackList <= BlackListLevel) then begin
      lstbxBlackListedToolbars.Items.Add(uMain.iToolbars.Strings[i-1]);
    end;
  end;
end;

procedure TfrmBlackList.lstbxBlackListedToolbarsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  CenterText : integer;
  TempText : String;
  Application: String;
begin
  frmMain.AddToLog('lstbxBlackListedToolbarsDrawItem', True);
  lstbxBlackListedToolbars.Canvas.FillRect (rect);
  TempText := lstbxBlackListedToolbars.Items.Strings[index];
  Application := frmMain.IniFile.ReadString(TempText, 'Application', '');
  frmMain.ImageList1.Draw(lstbxBlackListedToolbars.Canvas,rect.Left + 4, rect.Top + 4, GetAppNumber(Application) );
  CenterText := ( rect.Bottom - rect.Top - lstbxBlackListedToolbars.Canvas.TextHeight(text)) div 2 ;
  lstbxBlackListedToolbars.Canvas.TextOut (rect.left + frmMain.ImageList1.Width + 8 , rect.Top + CenterText, lstbxBlackListedToolbars.Items.Strings[index]);
end;

procedure TfrmBlackList.lstbxBlackListedToolbarsMeasureItem(
  Control: TWinControl; Index: Integer; var Height: Integer);
begin
  height := frmMain.ImageList1.Height + 4;
end;

end.
