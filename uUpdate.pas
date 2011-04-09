unit uUpdate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ShellApi, IniFiles, StrUtils, ExtCtrls, UrlMon,
  DKLang;

type
  TfrmUpdate = class(TForm)
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    Timer2: TTimer;
    DKLanguageController1: TDKLanguageController;
    Button3: TButton;
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmUpdate: TfrmUpdate;
  UrlDat, UrlProgram: String;
  ProgUpdate, DatUpdate: Boolean;

Const
  CrLf = #13#10;

implementation

uses SciZipFile, uMain, uAbout;

{$R *.dfm}

function DownloadFile(Source, Dest: string): Boolean;
  { Function for Downloading the file found on the net }
begin
  try
    Result := UrlDownloadToFile(nil, PChar(Source), PChar(Dest), 0, nil) = 0;
  except
    Result := False;
  end;
end;

procedure TfrmUpdate.Button2Click(Sender: TObject);
var
  IniFile: TIniFile;
  IniFileName: String;
  tmpOnlineProgVer, tmpInstalledProgVer: String;
  splitOnlineProgVer, splitInstalledProgVer: uMain.TSplitArray;
  msgString: String;
begin
  Button2.Enabled := not Button2.Enabled;
  Label1.Caption := DKLangConstW('sUpdateCheckFile');
  if DownloadFile('http://www.decomputeur.nl/remos_downloads/updates.ini', ExtractFilePATH(Application.EXEName) + 'Updates.ini') then begin
    Progressbar1.Position := 33;
    msgString := '';
    IniFileName := ExtractFilePath(Application.ExeName) + 'updates.ini';
    IniFile := TIniFile.Create(IniFileName);
    Label9.Caption := IniFile.ReadString('tbk', 'DatFileVersion', '');{dat}
    Label6.Caption := IniFile.ReadString('tbk', 'ProgramFileVersion', '');{program}
    urlDat := IniFile.ReadString('tbk', 'URLDat', '');
    urlProgram := IniFile.ReadString('tbk', 'URLProgram', '');
    FreeAndNil(IniFile);
    DeleteFile(IniFileName);
    splitOnlineProgVer := uMain.Split(Label6.Caption, '.');
    splitInstalledProgVer := uMain.Split(Label5.Caption, '.');
    tmpOnlineProgVer := splitOnlineProgVer[0] + splitOnlineProgVer[1] + splitOnlineProgVer[2] + splitOnlineProgVer[3];
    tmpInstalledProgVer := splitInstalledProgVer[0] + splitInstalledProgVer[1] + splitInstalledProgVer[2] + splitInstalledProgVer[3];
    if tmpOnlineProgVer <= tmpInstalledProgVer then begin
      msgString := msgString + DKLangConstW('sUpdateProgramUpToDate');
      ProgUpdate := False;
    end else begin
      ProgUpdate := True;
    end;
    if Label9.Caption = Label4.Caption then begin
      if Length(msgString) > 0 then
        msgString := msgString + CrLf + DKLangConstW('sUpdateDatFileUpToDate')
      else
        msgString := msgString + DKLangConstW('sUpdateDatFileUpToDate');
      DatUpdate := False;
    end else begin
      DatUpdate := True;
    end;
    if Length(msgString) > 0 then begin
      MessageDlg(msgString, mtInformation, [mbOK], 0);
    end;
    if DatUpdate or ProgUpdate then begin
      Button3.Visible := True;
      Button2.Visible := False;
    end;
  end;
  Button2.Enabled := not Button2.Enabled;
end;

procedure TfrmUpdate.Button3Click(Sender: TObject);
begin
  if DatUpdate or ProgUpdate then
    Timer1.Enabled := True;
end;

procedure TfrmUpdate.FormCreate(Sender: TObject);
var
  FvI: TFileVersionInfo;
begin
  frmMain.AddToLog('Create Form Update', True);
  FvI := uMain.FileVersionInfo(Application.ExeName);
  Label5.Caption := FvI.FileVersion;
  Label4.Caption := uMain.DatFileVersion;
  AboutBox.Version.Caption := FvI.FileVersion;
  AboutBox.Detection.Caption := uMain.DatFileVersion;
end;

procedure TfrmUpdate.FormShow(Sender: TObject);
begin
  if frmMain.autoupdateonstart AND frmMain.AutoUpdateOnce then begin
    Button2.Click;
    Button3.Click;
    Button1.Click;
  end;
end;

procedure TfrmUpdate.Timer1Timer(Sender: TObject);
var
  UrlDatFileName: String;
begin
  Button2.Enabled := not Button2.Enabled;
  Timer1.Enabled := False;
  if DatUpdate then begin
    UrlDatFileName := StringReplace(urlDat, '/', '\', [rfReplaceAll, rfIgnoreCase]);
    UrlDatFileName := ExtractFileName(UrlDatFileName);
    frmUpdate.Label1.Caption := DKLangConstW('sUpdateDatFile');
    if not directoryexists(ExtractFilePATH(Application.EXEName) + 'updates\') then
      CreateDir(ExtractFilePATH(Application.EXEName) + 'updates\');
    if DownloadFile(urlDat, ExtractFilePATH(Application.EXEName) + 'updates\' + UrlDatFileName) then begin
      Progressbar1.Position := 66;
      MoveFile(PChar(ExtractFilePATH(Application.EXEName) + 'updates\' + UrlDatFileName), PChar(ExtractFilePATH(Application.EXEName) + 'detection.dtz'));
    end;
    frmUpdate.Label1.Caption := DKLangConstW('sUpdateDatFileFinished');
  end;
  if ProgUpdate then
    Timer2.Enabled := True
  else begin
    frmUpdate.Label1.Caption := DKLangConstW('sUpdateDatFileFinished');
    Progressbar1.Position := 100;
  end;
  Button2.Enabled := not Button2.Enabled;
end;

procedure TfrmUpdate.Timer2Timer(Sender: TObject);
var
  UrlProgFileName: String;
begin
  Button2.Enabled := not Button2.Enabled;
  Timer2.Enabled := False;
  if ProgUpdate then begin
    UrlProgFileName := StringReplace(urlProgram, '/', '\', [rfReplaceAll, rfIgnoreCase]);
    UrlProgFileName := ExtractFileName(UrlProgFileName);
    frmUpdate.Label1.Caption := DKLangConstW('sUpdateProgram');
    if DownloadFile(urlProgram, ExtractFilePATH(Application.EXEName) + 'updates\' + ExtractFileName(UrlProgFileName)) then begin
      Progressbar1.Position := 100;
      MessageDlg(DKLangConstW('sUpdateProgramMessage1') + CrLf + DKLangConstW('sUpdateProgramMessage2'), mtInformation, [mbOK], 0);
      ShellExecute(handle, nil, (PChar(ExtractFilePATH(Application.EXEName) + 'updates\' + ExtractFileName(UrlProgFileName))), PChar('/SP- /VERYSILENT /NORESTART'), nil, SW_SHOW);
      Application.Terminate;
    end;
  end;
  Button2.Enabled := not Button2.Enabled;
end;

end.
