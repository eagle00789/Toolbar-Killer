unit uAbout;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, JvGIF, DKLang, PNGImage;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OKButton: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Detection: TLabel;
    DKLanguageController1: TDKLanguageController;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

Uses uMain;

{$R *.dfm}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  frmMain.AddToLog('Create Form About', True);
end;

end.

