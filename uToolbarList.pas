unit uToolbarList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmToolbarList = class(TForm)
    Label1: TLabel;
    lstbxToolbars: TListBox;
    Button1: TButton;
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
  frmToolbarList: TfrmToolbarList;

implementation

uses uMain;

{$R *.dfm}

procedure TfrmToolbarList.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 2 to uMain.iToolbars.Count do begin
    lstbxToolbars.Items.Add(uMain.iToolbars.Strings[i-1]);
  end;
end;

procedure TfrmToolbarList.lstbxToolbarsDrawItem(Control: TWinControl;
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

procedure TfrmToolbarList.lstbxToolbarsMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  height := frmMain.ImageList1.Height + 4;
end;

end.
