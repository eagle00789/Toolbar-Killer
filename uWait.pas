unit uWait;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, DKLang;

type
  TfrmWait = class(TForm)
    Label1: TLabel;
    lblProgramName: TLabel;
    ProgressBar1: TProgressBar;
    DKLanguageController1: TDKLanguageController;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmWait: TfrmWait;

implementation

uses uMain;

{$R *.dfm}

procedure TfrmWait.FormCreate(Sender: TObject);
begin
  frmMain.AddToLog('Create Form Wait', True);
end;

end.
