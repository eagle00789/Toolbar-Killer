// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program tbk;

uses
  ExceptionLog,
  Forms,
  Windows,
  uMain in 'uMain.pas' {frmMain},
  uUpdate in 'uUpdate.pas' {frmUpdate},
  uAbout in 'uAbout.pas' {AboutBox},
  uWait in 'uWait.pas' {frmWait},
  uOptions in 'uOptions.pas' {frmOptions},
  uWhiteList in 'uWhiteList.pas' {frmWhiteList},
  uBlackList in 'uBlackList.pas' {frmBlackList},
  uToolbarList in 'uToolbarList.pas' {frmToolbarList};

{$R *.res}
{$R *.dkl_const.res}
{$R manifestfile.RES}

const
  CFileMapping  = '{D132CEB2-KXC6-42D7-8981-036103680646}';

var
  hMapping:     THandle;
  wMap:         ^THandle;
  hMutex: Cardinal;

begin
  hMapping  := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, SizeOf(THandle), CFileMapping);
  if GetLastError() = ERROR_ALREADY_EXISTS then begin
    wMap  := MapViewOfFile(hMapping, FILE_MAP_READ, 0, 0, 0);
    if wMap^ <> 0 then
      PostMessage(wMap^, WM_INSTANCE, 0, 0);
    UnmapViewOfFile(wMap);
    CloseHandle(hMapping);
    exit;
  end else
    wMap  := MapViewOfFile(hMapping, FILE_MAP_WRITE, 0, 0, 0);
  Application.Initialize;
  hMutex := CreateMutex(nil, False, 'Toolbar_Uninstaller');
  Application.Title := 'Toolbar Uninstaller';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TfrmUpdate, frmUpdate);
  wMap^ := frmMain.Handle;
  Application.Run;
  UnmapViewOfFile(wMap);
  CloseHandle(hMapping);
  ReleaseMutex(hMutex);
end.
