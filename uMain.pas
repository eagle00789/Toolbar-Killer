unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, IniFiles, StrUtils, ShlObj, ShellApi, SHDocVw,
  tlhelp32, ImgList, psapi, DKLang, Registry, AppEvnts, HH, HH_Funcs;

const
  MainCaption = 'Toolbar Uninstaller';
  CrLf = #13#10;
  SC_MyMenuItem1 = WM_USER + 1;
  WM_INSTANCE = WM_USER + $1112;
  AutoBlackList = 4;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    bttnMoveSelectedRight: TButton;
    bttnMoveAllRight: TButton;
    bttnMoveAllLeft: TButton;
    bttnMoveSelectedLeft: TButton;
    bttnRemove: TButton;
    bttnOptions: TButton;
    bttnRescan: TButton;
    ImageList1: TImageList;
    lstbxInstalledToolbars: TListBox;
    lstbxUninstallableToolbars: TListBox;
    DKLanguageController1: TDKLanguageController;
    procedure FormShow(Sender: TObject);
    procedure lstbxUninstallableToolbarsDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lstbxUninstallableToolbarsMeasureItem(Control: TWinControl;
      Index: Integer; var Height: Integer);
    procedure lstbxInstalledToolbarsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstbxInstalledToolbarsMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure bttnRescanClick(Sender: TObject);
    procedure bttnOptionsClick(Sender: TObject);
    procedure bttnRemoveClick(Sender: TObject);
    procedure bttnMoveAllRightClick(Sender: TObject);
    procedure bttnMoveAllLeftClick(Sender: TObject);
    procedure bttnMoveSelectedLeftClick(Sender: TObject);
    procedure bttnMoveSelectedRightClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AddToLog(str: String; adv: Boolean);
    procedure UpdateSysMenu;
  private
    FIsUnicodeFile: Boolean;
    procedure WMSysCommand(var Msg: TWMSysCommand);
           message WM_SYSCOMMAND;
  protected
    procedure WMInstance(var Msg: TMessage); message WM_INSTANCE;
  public
    programlanguage: Integer;
    autoupdateonstart, AutoUpdateOnce, showremovewarning, showbrowserclosewarning, createlog, detailedlog, clearlog: boolean;
    ToolbarWhiteList: TStringList;
    IniFile: TMemIniFile;
  end;

type
  TSplitArray = array of String;

type
  TFileVersionInfo = record
    FileType,
    CompanyName,
    FileDescription,
    FileVersion,
    InternalName,
    LegalCopyRight,
    LegalTradeMarks,
    OriginalFileName,
    ProductName,
    ProductVersion,
    Comments,
    SpecialBuildStr,
    PrivateBuildStr,
    FileFunction: string;
    DebugBuild,
    PreRelease,
    SpecialBuild,
    PrivateBuild,
    Patched,
    InfoInferred: Boolean;
  end;

function Split(const Source, Delimiter: String): TSplitArray;
function DetectInstalledToolbar(DetectLocation: String): Boolean;
function getSpecialFolder(n:integer):string;
procedure CheckUninstallBox;
function GetActionCode(Action: String): Integer;
function DelDir(dir: string): Boolean;
function GetEditFileActionCode(Action: String): Integer;
procedure CreateWin9xProcessList(List: TstringList);
procedure CreateWinNTProcessList(List: TstringList);
procedure GetProcessList(var List: TstringList);
function EXE_Running(FileName: string; bFullpath: Boolean): Boolean;
function KillTask(ExeFileName: string): Integer;
function ExecuteAndWait(const strCommandLine : String; intVisibility: Integer = SW_SHOW) : Cardinal;
Function GetAppNumber(App: String):Integer;
Function GetRegRootKey(strIn: String): Cardinal;
function FileVersionInfo(const sAppNamePath: TFileName): TFileVersionInfo;

var
  frmMain: TfrmMain;
  iToolbars: TStringList;
  ProgramDir, LocalAppDataDir, ProgramFilesDir, FFProfileDir, OPProfileDir: String;
  DatFileVersion, ProgramFileVersion, ErrorMessage: String;
  NeedReboot: Boolean;

implementation

uses SciZipFile, uUpdate, uAbout, uWait, uOptions;

{$R *.dfm}
{$D+}

function FileVersionInfo(const sAppNamePath: TFileName): TFileVersionInfo;
var
  rSHFI: TSHFileInfo;
  iRet: Integer;
  VerSize: Integer;
  VerBuf: PChar;
  VerBufValue: Pointer;
  VerHandle: Cardinal;
  VerBufLen: Cardinal;
  VerKey: string;
  FixedFileInfo: PVSFixedFileInfo;

  // dwFileType, dwFileSubtype
  function GetFileSubType(FixedFileInfo: PVSFixedFileInfo): string;
  begin
    case FixedFileInfo.dwFileType of

      VFT_UNKNOWN: Result    := 'Unknown';
      VFT_APP: Result        := 'Application';
      VFT_DLL: Result        := 'DLL';
      VFT_STATIC_LIB: Result := 'Static-link Library';

      VFT_DRV:
        case
          FixedFileInfo.dwFileSubtype of
          VFT2_UNKNOWN: Result         := 'Unknown Driver';
          VFT2_DRV_COMM: Result        := 'Communications Driver';
          VFT2_DRV_PRINTER: Result     := 'Printer Driver';
          VFT2_DRV_KEYBOARD: Result    := 'Keyboard Driver';
          VFT2_DRV_LANGUAGE: Result    := 'Language Driver';
          VFT2_DRV_DISPLAY: Result     := 'Display Driver';
          VFT2_DRV_MOUSE: Result       := 'Mouse Driver';
          VFT2_DRV_NETWORK: Result     := 'Network Driver';
          VFT2_DRV_SYSTEM: Result      := 'System Driver';
          VFT2_DRV_INSTALLABLE: Result := 'InstallableDriver';
          VFT2_DRV_SOUND: Result       := 'Sound Driver';
        end;
      VFT_FONT:
        case FixedFileInfo.dwFileSubtype of
          VFT2_UNKNOWN: Result       := 'Unknown Font';
          VFT2_FONT_RASTER: Result   := 'Raster Font';
          VFT2_FONT_VECTOR: Result   := 'Vector Font';
          VFT2_FONT_TRUETYPE: Result := 'Truetype Font';
          else;
        end;
      VFT_VXD: Result := 'Virtual Defice Identifier = ' +
          IntToHex(FixedFileInfo.dwFileSubtype, 8);
    end;
  end;


  function HasdwFileFlags(FixedFileInfo: PVSFixedFileInfo; Flag: Word): Boolean;
  begin
    Result := (FixedFileInfo.dwFileFlagsMask and
      FixedFileInfo.dwFileFlags and
      Flag) = Flag;
  end;

  function GetFixedFileInfo: PVSFixedFileInfo;
  begin
    if not VerQueryValue(VerBuf, '', Pointer(Result), VerBufLen) then
      Result := nil
  end;

  function GetInfo(const aKey: string): string;
  begin
    Result := '';
    VerKey := Format('\StringFileInfo\%.4x%.4x\%s',
      [LoWord(Integer(VerBufValue^)),
      HiWord(Integer(VerBufValue^)), aKey]);
    if VerQueryValue(VerBuf, PChar(VerKey), VerBufValue, VerBufLen) then
      Result := StrPas(VerBufValue);
  end;

  function QueryValue(const aValue: string): string;
  begin
    Result := '';
    // obtain version information about the specified file
    if GetFileVersionInfo(PChar(sAppNamePath), VerHandle, VerSize, VerBuf) and
      // return selected version information
      VerQueryValue(VerBuf, '\VarFileInfo\Translation', VerBufValue, VerBufLen) then
      Result := GetInfo(aValue);
  end;
begin
  // Initialize the Result
  with Result do
  begin
    FileType         := '';
    CompanyName      := '';
    FileDescription  := '';
    FileVersion      := '';
    InternalName     := '';
    LegalCopyRight   := '';
    LegalTradeMarks  := '';
    OriginalFileName := '';
    ProductName      := '';
    ProductVersion   := '';
    Comments         := '';
    SpecialBuildStr  := '';
    PrivateBuildStr  := '';
    FileFunction     := '';
    DebugBuild       := False;
    Patched          := False;
    PreRelease       := False;
    SpecialBuild     := False;
    PrivateBuild     := False;
    InfoInferred     := False;
  end;

  // Get the file type
  if SHGetFileInfo(PChar(sAppNamePath), 0, rSHFI, SizeOf(rSHFI),
    SHGFI_TYPENAME) <> 0 then
  begin
    Result.FileType := rSHFI.szTypeName;
  end;

  iRet := SHGetFileInfo(PChar(sAppNamePath), 0, rSHFI, SizeOf(rSHFI), SHGFI_EXETYPE);
  if iRet <> 0 then
  begin
    // determine whether the OS can obtain version information
    VerSize := GetFileVersionInfoSize(PChar(sAppNamePath), VerHandle);
    if VerSize > 0 then
    begin
      VerBuf := AllocMem(VerSize);
      try
        with Result do
        begin
          CompanyName      := QueryValue('CompanyName');
          FileDescription  := QueryValue('FileDescription');
          FileVersion      := QueryValue('FileVersion');
          InternalName     := QueryValue('InternalName');
          LegalCopyRight   := QueryValue('LegalCopyRight');
          LegalTradeMarks  := QueryValue('LegalTradeMarks');
          OriginalFileName := QueryValue('OriginalFileName');
          ProductName      := QueryValue('ProductName');
          ProductVersion   := QueryValue('ProductVersion');
          Comments         := QueryValue('Comments');
          SpecialBuildStr  := QueryValue('SpecialBuild');
          PrivateBuildStr  := QueryValue('PrivateBuild');
          // Fill the VS_FIXEDFILEINFO structure
          FixedFileInfo := GetFixedFileInfo;
          DebugBuild    := HasdwFileFlags(FixedFileInfo, VS_FF_DEBUG);
          PreRelease    := HasdwFileFlags(FixedFileInfo, VS_FF_PRERELEASE);
          PrivateBuild  := HasdwFileFlags(FixedFileInfo, VS_FF_PRIVATEBUILD);
          SpecialBuild  := HasdwFileFlags(FixedFileInfo, VS_FF_SPECIALBUILD);
          Patched       := HasdwFileFlags(FixedFileInfo, VS_FF_PATCHED);
          InfoInferred  := HasdwFileFlags(FixedFileInfo, VS_FF_INFOINFERRED);
          FileFunction  := GetFileSubType(FixedFileInfo);
        end;
      finally
        FreeMem(VerBuf, VerSize);
      end
    end;
  end
end;

procedure TfrmMain.WMSysCommand(var Msg:TWMSysCommand);
begin
  AddToLog('WMSysCommand', True);
  if Msg.CmdType = SC_MyMenuItem1 then begin
  {some code to handle my menu item:}
    AboutBox.ShowModal;
  end else
    inherited;
end;

function Split(const Source, Delimiter: String): TSplitArray;
var
  iCount:     Integer;
  iPos:       Integer;
  iLength:    Integer;
  sTemp:      String;
  aSplit:     TSplitArray;
begin
  frmMain.AddToLog('Split', True);
  sTemp   := Source;
  iCount  := 0;
  iLength := Length(Delimiter) - 1;
  repeat
    iPos := Pos(Delimiter, sTemp);
     if iPos = 0 then
      break
    else begin
      Inc(iCount);
      SetLength(aSplit, iCount);
      aSplit[iCount - 1] := Copy(sTemp, 1, iPos - 1);
      Delete(sTemp, 1, iPos + iLength);
    end;
  until False;
  if Length(sTemp) > 0 then begin
    Inc(iCount);
    SetLength(aSplit, iCount);
    aSplit[iCount - 1] := sTemp;
  end;
  Result := aSplit;
end;

function getSpecialFolder(n:integer):string;
var
  PIDL       : PItemIDList;
  Buffer     : array[0..MAX_PATH] of Char;
begin
  frmMain.AddToLog('getSpecialFolder', True);
  SHGetSpecialFolderLocation(0, n, PIDL);
  SHGetPathFromIDList       (PIDL, Buffer);
  result:= string(Buffer);
end;

Function GetRegRootKey(strIn: String): Cardinal;
begin
  frmMain.AddToLog('GetRegRootKey', True);
  GetRegRootKey := HKEY_LOCAL_MACHINE;
  if lowercase(strIn) = 'hkdd' then
    GetRegRootKey := HKEY_DYN_DATA;
  if lowercase(strIn) = 'hkcc' then
    GetRegRootKey := HKEY_CURRENT_CONFIG;
  if lowercase(strIn) = 'hku' then
    GetRegRootKey := HKEY_USERS;
  if lowercase(strIn) = 'hklm' then
    GetRegRootKey := HKEY_LOCAL_MACHINE;
  if lowercase(strIn) = 'hkcu' then
    GetRegRootKey := HKEY_CURRENT_USER;
  if lowercase(strIn) = 'hkcr' then
    GetRegRootKey := HKEY_CLASSES_ROOT;
end;

function DetectInstalledToolbar(DetectLocation: String): Boolean;
var
  i: Integer;
  FFIniFileName, Default, test: String;
  FFIniFile: TIniFile;
  FFSections: TStringList;
  RegString: TSplitArray;
  Registry: TRegistry;
begin
  frmMain.AddToLog('DetectInstalledToolbar', True);
  if LowerCase(LeftStr(DetectLocation, 11)) = '%ffprofile%' then begin
    if FFProfileDir = '' then begin
      FFSections := TStringList.Create;
      //SHGetSpecialFolderPath(Form1.Handle, PChar(LocalAppDataDir), CSIDL_APPDATA, False);
      FFIniFileName := LocalAppDataDir + '\Mozilla\Firefox\profiles.ini';
      FFIniFile := TIniFile.Create(FFIniFileName);
      FFIniFile.ReadSections(FFSections);
      for i := 0 to FFSections.Count - 1 do begin
        test := FFSections.Strings[i];
        Default := FFIniFile.ReadString(FFSections.Strings[i], 'Name', '');
        if LowerCase(Default) = 'default' then begin
          FFProfileDir := FFIniFile.ReadString(FFSections.Strings[i], 'Path', '');
          FFProfileDir := LocalAppDataDir + '\Mozilla\Firefox\' + FFProfileDir;
          FFProfileDir := StringReplace(FFProfileDir, '/', '\', [rfReplaceAll, rfIgnoreCase]);
        end;
      end;
      FreeAndNil(FFIniFile);
      FreeAndNil(FFSections);
    end;
    DetectLocation := StringReplace(DetectLocation, '%ffprofile%', FFProfileDir, [rfReplaceAll, rfIgnoreCase]);
  end;
  if LowerCase(LeftStr(DetectLocation, 11)) = '%opprofile%' then begin
    if OPProfileDir = '' then begin
      OPProfileDir := LocalAppDataDir + '\Opera\Opera\profile';
    end;
    DetectLocation := StringReplace(DetectLocation, '%opprofile%', OPProfileDir, [rfReplaceAll, rfIgnoreCase]);
  end;
  if LowerCase(LeftStr(DetectLocation, 14)) = '%programfiles%' then begin
    DetectLocation := StringReplace(DetectLocation, '%programfiles%', ProgramFilesDir, [rfReplaceAll, rfIgnoreCase]);
  end;
  if (FileExists(DetectLocation)) and (LowerCase(LeftStr(DetectLocation, 2)) <> 'hk') then
    DetectInstalledToolbar := True
  else
    DetectInstalledToolbar := False;
  if LowerCase(LeftStr(DetectLocation, 2))= 'hk' then begin
    RegString := Split(DetectLocation, '|');
    Registry := TRegistry.Create(KEY_READ);
    try
      Registry.RootKey := GetRegRootKey(LowerCase(LeftStr(RegString[0], 4)));
      if Registry.KeyExists(RightStr(RegString[0], length(RegString[0])-4)) then
        DetectInstalledToolbar := True
      else
        DetectInstalledToolbar := False;
    finally
      Registry.Free;
    end;
  end;
end;

procedure CheckUninstallBox;
begin
  frmMain.AddToLog('CheckUninstallBox', True);
  if frmMain.lstbxUninstallableToolbars.Count > 0 then
    frmMain.bttnRemove.Enabled := True
  else
    frmMain.bttnRemove.Enabled := False;
end;

function GetActionCode(Action: String): Integer;
begin
  frmMain.AddToLog('GetActionCode', True);
  GetActionCode := 0;
  if LowerCase(Action)='deletefolder' then
    GetActionCode := 1;
  if LowerCase(Action)='editfile' then
    GetActionCode := 2;
  if LowerCase(Action)='deletefile' then
    GetActionCode := 3;
  if LowerCase(Action)='applicatio' then
    GetActionCode := 4;
  if LowerCase(Action)='toolbarnam' then
    GetActionCode := 5;
  if LowerCase(Action)='execute' then
    GetActionCode := 6;
  if LowerCase(Action)='click' then
    GetActionCode := 7;
  if LowerCase(Action)='findwindo' then
    GetActionCode := 8;
  if LowerCase(Action)='needreboo' then
    GetActionCode := 9;
  if LowerCase(Action)='riskleve' then
    GetActionCode := 10;
end;

function GetEditFileActionCode(Action: String): Integer;
begin
  frmMain.AddToLog('GetEditFileActionCode', True);
  GetEditFileActionCode := 0;
  if Action='DeleteLine' then
    GetEditFileActionCode := 1;
  if Action='DeleteSection' then
    GetEditFileActionCode := 2;
end;

function DelDir(dir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  frmMain.AddToLog('DelDir', True);
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom  := PChar(dir + #0);
  end;
  Result := (0 = ShFileOperation(fos));
end;

procedure CreateWin9xProcessList(List: TstringList);
var
  hSnapShot: THandle;
  ProcInfo: TProcessEntry32;
begin
  frmMain.AddToLog('CreateWin9xProcessList', True);
  if List = nil then Exit;
  hSnapShot := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (hSnapShot <> THandle(-1)) then
  begin
    ProcInfo.dwSize := SizeOf(ProcInfo);
    if (Process32First(hSnapshot, ProcInfo)) then
    begin
      List.Add(ProcInfo.szExeFile);
      while (Process32Next(hSnapShot, ProcInfo)) do
        List.Add(ProcInfo.szExeFile);
    end;
    CloseHandle(hSnapShot);
  end;
end;

procedure CreateWinNTProcessList(List: TstringList);
var
  PIDArray: array [0..1023] of DWORD;
  cb: DWORD;
  I: Integer;
  ProcCount: Integer;
  hMod: HMODULE;
  hProcess: THandle;
  ModuleName: array [0..300] of Char;
begin
  frmMain.AddToLog('CreateWinNTProcessList', True);
  if List = nil then Exit;
  EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
  ProcCount := cb div SizeOf(DWORD);
  for I := 0 to ProcCount - 1 do
  begin
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or
      PROCESS_VM_READ,
      False,
      PIDArray[I]);
    if (hProcess <> 0) then
    begin
      EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);
      GetModuleFilenameEx(hProcess, hMod, ModuleName, SizeOf(ModuleName));
      List.Add(ModuleName);
      CloseHandle(hProcess);
    end;
  end;
end;

procedure GetProcessList(var List: TstringList);
var
  ovi: TOSVersionInfo;
begin
  frmMain.AddToLog('GetProcessList', True);
  if List = nil then Exit;
  ovi.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(ovi);
  case ovi.dwPlatformId of
    VER_PLATFORM_WIN32_WINDOWS: CreateWin9xProcessList(List);
    VER_PLATFORM_WIN32_NT: CreateWinNTProcessList(List);
  end
end;

function EXE_Running(FileName: string; bFullpath: Boolean): Boolean;
var
  i: Integer;
  MyProcList: TstringList;
begin
  frmMain.AddToLog('EXE_Running', True);
  MyProcList := TStringList.Create;
  try
    GetProcessList(MyProcList);
    Result := False;
    if MyProcList = nil then Exit;
    for i := 0 to MyProcList.Count - 1 do
    begin
      if not bFullpath then
      begin
        if CompareText(ExtractFileName(MyProcList.Strings[i]), FileName) = 0 then
          Result := True
      end
      else if CompareText(MyProcList.strings[i], FileName) = 0 then Result := True;
      if Result then Break;
    end;
  finally
    MyProcList.Free;
  end;
end;

function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  frmMain.AddToLog('KillTask', True);
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function ExecuteAndWait(const strCommandLine : String; intVisibility: Integer = SW_SHOW) : Cardinal;
var
  StartupInfo : TStartupInfo;
  ProcessInformation : TProcessInformation;
  intWaitState : DWORD;
begin
  frmMain.AddToLog('ExecuteAndWait', True);
  Result := 0;
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.wShowWindow := intVisibility;

  if (CreateProcess(nil, PChar(strCommandLine), nil, nil, False, 0, nil, nil, StartupInfo, ProcessInformation)) then
  begin
    intWaitState := WaitForSingleObject(ProcessInformation.hProcess, INFINITE);

    if (intWaitState = WAIT_OBJECT_0) then
      if (GetExitCodeProcess(ProcessInformation.hProcess, intWaitState)) then
        Result := intWaitState;

    CloseHandle(ProcessInformation.hProcess);
    CloseHandle(ProcessInformation.hThread);
  end;
end;

function EnumChildProc(Wnd: hWnd; SL: TStrings): BOOL; stdcall;
var
  szFull: array[0..MAX_PATH] of Char; //Buffer for window caption
begin
  frmMain.AddToLog('EnumChildProc', True);
  Result := Wnd <> 0;
  if Result then 
  begin
    GetWindowText(Wnd, szFull, SizeOf(szFull)); // put window text in buffer
    if (Pos(SL[0], StrPas(szFull)) > 0) // Test for text
      and (SL.IndexOfObject(TObject(Wnd)) < 0) // Test for duplicate handles
      then SL.AddObject(StrPas(szFull), TObject(Wnd)); // Add item to list
    EnumChildWindows(Wnd, @EnumChildProc, Longint(SL)); //Recurse into child windows
  end;
end;

function HWndGet(partialTitle: string): hWnd;
var
  hWndTemp: hWnd;
  iLenText: Integer;
  cTitletemp: array[0..254] of Char;
  sTitleTemp: string;
begin
  frmMain.AddToLog('HwndGet', True);
  hWndTemp := FindWindow(nil, nil);
  {Find first window and loop through all subsequent windows in the master window list}
  while hWndTemp <> 0 do
  begin
    {Retrieve caption text from current window}
    iLenText := GetWindowText(hWndTemp, cTitletemp, 255);
    sTitleTemp := cTitletemp;
    sTitleTemp := UpperCase(copy(sTitleTemp, 1, iLenText));
    {Clean up the return string, preparing for case insensitive comparison.
                Use appropriate method to determine if the current window's caption either
          starts with or contains passed string}
    partialTitle := UpperCase(partialTitle);
    if pos(partialTitle, sTitleTemp) <> 0 then
      break;
    {Get next window in master window list and continue}
    hWndTemp := GetWindow(hWndTemp, GW_HWNDNEXT);
  end;
  result := hWndTemp;
end;

Function GetAppNumber(App: String):Integer;
begin
  frmMain.AddToLog('GetAppNumber', True);
  GetAppNumber := -1;
  if lowercase(App) = 'ff' then
    GetAppNumber := 0;
  if lowercase(App) = 'ie' then
    GetAppNumber := 1;
  if lowercase(App) = 'op' then
    GetAppNumber := 2;
  if lowercase(App) = 'ns' then
    GetAppNumber := 3;
  if lowercase(App) = 'mx' then
    GetAppNumber := 4;
end;

procedure TfrmMain.UpdateSysMenu;
var
  SysMenu : HMenu;
begin
  AddToLog('UpdateSysMenu', True);
  SysMenu := GetSystemMenu(Handle, FALSE);
  DeleteMenu(SysMenu, 8, MF_BYPOSITION);
  AppendMenu(SysMenu, MF_STRING, SC_MyMenuItem1, PChar(String(DKLangConstW('sMyMenuCaption1'))));
end;

procedure TfrmMain.AddToLog(str: String; adv: Boolean);
var
  F: TextFile;
  Bestand: String;
begin
  if createlog and not adv then begin
    Bestand := ExtractFilePath(Application.ExeName) + 'logfile.txt';
    AssignFile(F, Bestand);
    If not FileExists(Bestand) then begin {Als niet bestaat}
      Rewrite(F);
    end else begin
      Append(F);
    end;
    WriteLn(F, '[' + FormatDateTime('dd-mm-yyyy hh:nn:ss:zzz', Now()) + ']: ' + str);
    CloseFile(F);
  end;
  if createlog and detailedlog and adv then begin
    Bestand := ExtractFilePath(Application.ExeName) + 'logfile.txt';
    AssignFile(F, Bestand);
    If not FileExists(Bestand) then begin {Als niet bestaat}
      Rewrite(F);
    end else begin
      Append(F);
    end;
    WriteLn(F, '[' + FormatDateTime('dd-mm-yyyy hh:nn:ss:zzz', Now()) + ']: ' + str);
    CloseFile(F);
  end;
end;

procedure TfrmMain.WMInstance;
begin
  AddToLog('WMInstance', True);
  // Hier kan je elke code uitvoeren die je wilt, in dit geval halen we
  // de applicatie naar de voorgrond...
  Application.Restore();      {Deze 2 regels is om ervoor te zorgen dat er maar 1 exemplaar kan draaien}
  Application.BringToFront();
end;

procedure TfrmMain.bttnMoveSelectedRightClick(Sender: TObject);
var
  i: Integer;
  j: Array of Integer;
begin
  AddToLog('bttnMoveSelectedRightClick', True);
  for i := 1 to lstbxInstalledToolbars.SelCount do begin
    if lstbxInstalledToolbars.Selected[i-1] then begin
      lstbxUninstallableToolbars.Items.Add(lstbxInstalledToolbars.Items.Strings[i-1]);
      SetLength(j, Length(j) + 1);
      j[length(j)-1] := i-1;
    end;
  end;
  for i := Length(j) - 1 downto 0 do begin
    lstbxInstalledToolbars.Items.Delete(j[i]);
  end;
  CheckUninstallBox;
end;

procedure TfrmMain.bttnRemoveClick(Sender: TObject);
var
  F: TextFile;
  i, j, k, RiskLevel: Integer;
  iToolbarData, MemoryFile: TStringList;
  iToolbarDataStr, tmpFileLine, FileName, FolderDelete, FileEditLine, FileLine,
  tmpStr, SearchWindow, FileDelete, Applic, ToolbarName, ExecuteLine: String;
  FileEditLineSplitted, ExecuteLineSplitted: TSplitArray;
  buttonSelected, buttonSelected1, buttonSelected2: Integer;
  Click: Array of String;
  MouseLocation: TSplitArray;
  formWait: TfrmWait;
begin
  if showremovewarning then begin
    buttonSelected2 := MessageDlg(DKLangConstW('sRemoveToolbar1') + CrLf + DKLangConstW('sRemoveToolbar2'), mtWarning, [mbYes,mbNo], 0);
    if buttonSelected2 = mrNo then
      exit;
  end;
  if showbrowserclosewarning then begin
    if (Exe_Running('firefox.exe', false)) or (Exe_Running('iexplore.exe', false)) then begin
      buttonSelected := MessageDlg(DKLangConstW('sCloseBrowser1') + CrLf + DKLangConstW('sCloseBrowser2'), mtWarning, [mbOK,mbCancel], 0);
      if buttonSelected = mrOK then begin
        if Exe_Running('firefox.exe', false) then begin
          KillTask('firefox.exe');
          AddToLog('Kill Browser: FireFox', True);
        end;
        if Exe_Running('iexplore.exe', false) then begin
          KillTask('iexplore.exe');
          AddToLog('Kill Browser: Internet Explorer', True);
        end;
        sleep(250);
        if (Exe_Running('firefox.exe', false)) or (Exe_Running('iexplore.exe', false)) then begin
          MessageDlg(DKLangConstW('sCloseBrowserFailed'), mtError, [mbOK], 0);
          AddToLog('Kill Browser Failed', True);
        end;
      end;
      if buttonSelected = mrCancel then begin
        exit;
      end;
    end;
  end else begin
    if Exe_Running('firefox.exe', false) then begin
      KillTask('firefox.exe');
      AddToLog('Kill Browser: FireFox', True);
    end;
    if Exe_Running('iexplore.exe', false) then begin
      KillTask('iexplore.exe');
      AddToLog('Kill Browser: Internet Explorer', True);
    end;
    sleep(250);
    if (Exe_Running('firefox.exe', false)) or (Exe_Running('iexplore.exe', false)) then begin
      MessageDlg(DKLangConstW('sCloseBrowserFailed'), mtError, [mbOK], 0);
      AddToLog('Kill Browser Failed', True);
    end;
  end;
  iToolbarData := TStringList.Create;
  formWait := TfrmWait.Create(Application);
  formWait.Caption := DKLangConstW('sRemovingWait');
  formWait.Label1.Caption := DKLangConstW('sRemovingCaption');
  formWait.ProgressBar1.Max := lstbxUninstallableToolbars.Count;
  formWait.ProgressBar1.Position := 0;
  formWait.Show;
  AddToLog('Start Removing Toolbars', True);
  for i := lstbxUninstallableToolbars.Count downto 1 do begin
    AddToLog('Removing Toolbar: ' + lstbxUninstallableToolbars.Items.Strings[i-1], False);
    IniFile.ReadSection(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData);
    formWait.lblProgramName.Caption := lstbxUninstallableToolbars.Items.Strings[i-1];
    formWait.Update;
    formWait.ProgressBar1.StepIt;
    for j := 1 to iToolbarData.Count do begin
      iToolbarDataStr := LeftStr(iToolbarData.Strings[j-1], Length(iToolbarData.Strings[j-1]) - 1);
      case GetActionCode(iToolbarDataStr) of
        1:  {DeleteFolder}
          begin
            AddToLog('Remove: DeleteFolder', True);
            FolderDelete := IniFile.ReadString(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], '');
            FolderDelete := StringReplace(FolderDelete, '%ffprofile%', FFProfileDir, [rfReplaceAll, rfIgnoreCase]);
            FolderDelete := StringReplace(FolderDelete, '%programfiles%', ProgramFIlesDir, [rfReplaceAll, rfIgnoreCase]);
            DelDir(FolderDelete);
          end;
        2:  {EditFile}
          begin
            AddToLog('Remove: EditFile', True);
            FileEditLine := IniFile.ReadString(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], '');
            FileEditLineSplitted := Split(FileEditLine, '|');
            case GetEditFileActionCode(FileEditLineSplitted[3]) of
              1: {DeleteLine}
                begin
                  AddToLog('Remove: EditFile: DeleteLine', True);
                  FileName := StringReplace(FileEditLineSplitted[0], '%ffprofile%', FFProfileDir, [rfReplaceAll, rfIgnoreCase]);
                  AssignFile(F, FileName);
                  try
                    Reset(F);
                    MemoryFile := TStringList.Create;
                    while not eof(F) do begin
                      ReadLn(F, FileLine);
                      if not (FileEditLineSplitted[1] = LeftStr(FileLine, Length(FileEditLineSplitted[1]))) then
                        MemoryFile.Add(FileLine)
                    end;
                    CloseFile(F);
                    DeleteFile(FileName);
                    MemoryFile.SaveToFile(FileName);
                  except
                    CloseFile(F);
                  end;
                end;
            end;
          end;
        3:  {DeleteFile}
          begin
            AddToLog('Remove: DeleteFile', True);
            FileDelete := IniFile.ReadString(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], '');
            DeleteFile(FileDelete);
          end;
        4:  {Application}
          begin
            AddToLog('Rempove: Application', True);
            Applic := IniFile.ReadString(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], '');
            if (length(Applic) > 0) and (length(toolbarname) > 0) then begin
              if LowerCase(Applic) = 'ff' then begin
                FileName := FFProfileDir + '\extensions.cache';
                AssignFile(F, FileName);
                try
                  Reset(F);
                  MemoryFile := TStringList.Create;
                  while not eof(F) do begin
                    ReadLn(F, FileLine);
                    tmpFileLine := RightStr(LeftStr(FileLine, Length(ToolbarName) + 12), Length(ToolbarName));
                    if (ToolbarName = tmpFileLine) then
                      MemoryFile.Add(FileLine + 'needs-uninstall')
                    else
                      MemoryFile.Add(FileLine)
                  end;
                  CloseFile(F);
                  DeleteFile(FileName);
                  MemoryFile.SaveToFile(FileName);
                except
                  CloseFile(F);
                end;
              end else begin
                if LowerCase(Applic) = 'ie' then begin
                  {IE-Code}
                end;
              end;
            end;
          end;
        5:  {ToolbarName}
          begin
            AddToLog('Remove: ToolbarName', True);
            ToolbarName := IniFile.ReadString(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], '');
            if (length(Applic) > 0) and (length(toolbarname) > 0) then begin
              if LowerCase(Applic) = 'ff' then begin
                FileName := FFProfileDir + '\extensions.cache';
                AssignFile(F, FileName);
                try
                  Reset(F);
                  MemoryFile := TStringList.Create;
                  while not eof(F) do begin
                    ReadLn(F, FileLine);
                    tmpFileLine := RightStr(LeftStr(FileLine, Length(ToolbarName) + 12), Length(ToolbarName));
                    if (ToolbarName = tmpFileLine) then
                      MemoryFile.Add(FileLine + 'needs-uninstall')
                    else
                      MemoryFile.Add(FileLine)
                  end;
                  CloseFile(F);
                  DeleteFile(FileName);
                  MemoryFile.SaveToFile(FileName);
                except
                  CloseFile(F);
                end;
              end else begin
                if LowerCase(Applic) = 'ie' then begin
                  {IE-Code}
                end;
              end;
            end;
          end;
        6:  {Execute}
          begin
            AddToLog('Remove: Execute', True);
            ExecuteLine := IniFile.ReadString(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], '');
            ExecuteLine := StringReplace(ExecuteLine, '%programfiles%', ProgramFilesDir, [rfReplaceAll, rfIgnoreCase]);
            ExecuteLineSplitted := Split(ExecuteLine, '|');
            if length(Click) > 0 then begin
              ShellExecute(handle, nil, (PChar(ExecuteLineSplitted[0])), PChar(ExecuteLineSplitted[1]), nil, SW_SHOW);
              for k := 0 to Length(Click) - 1 do begin
                MouseLocation := split(Click[k], ',');
                tmpStr := ProgramDir + 'helper.exe "' + SearchWindow + '" ' + MouseLocation[0] + ' ' + MouseLocation[1];
                ExecuteAndWait(tmpStr, SW_SHOW );
              end;
            end else
              ExecuteAndWait(ExecuteLineSplitted[0] + ' ' + ExecuteLineSplitted[1], SW_SHOW );
          end;
        7: {Click}
          begin
            AddToLog('Remove: Click', True);
            SetLength(Click, Length(Click)+1);
            Click[Length(Click)-1] := IniFile.ReadString(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], '');
          end;
        8: {FindWindow}
          begin
            AddToLog('Remove: FindWindow', True);
            SearchWindow := IniFile.ReadString(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], '');
          end;
        9: {NeedReboot}
          Begin
            AddToLog('Remove: NeedReboot', True);
            NeedReboot := IniFile.ReadBool(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], False);
          end;
        10: {RiskLevel}
          begin
            {TODO: Add RiskLevel Code}
            AddToLog('Remove: RiskLevel', True);
            RiskLevel := IniFile.ReadInteger(lstbxUninstallableToolbars.Items.Strings[i-1], iToolbarData.Strings[j-1], 3);
            case RiskLevel of
              1:
                begin
                  AddToLog('Remove: RiskLevel: 1', True);
                end;
              2:
                begin
                  AddToLog('Remove: RiskLevel: 2', True);
                end;
              3:
                begin
                  AddToLog('Remove: RiskLevel: 3', True);
                end;
              4:
                begin
                  AddToLog('Remove: RiskLevel: 4 - SECURITY RISK FOUND', True);
                end;
              5:
                begin
                  AddToLog('Remove: RiskLevel: 5 - HIGH SECURITY RISK FOUND', True);
                end;
            end;
          end;
      end;
    end;
    ToolbarName := '';
    Applic := '';
    lstbxUninstallableToolbars.Items.Delete(i-1);
  end;
  AddToLog('Finish Removing Toolbars', True);
  formWait.Destroy;
  CheckUninstallBox;
  if NeedReboot then begin
    AddToLog('Needs Reboot', True);
    buttonSelected1 := MessageDlg(DKLangConstW('sReboot1') + CrLf + DKLangConstW('sReboot2'), mtWarning, [mbYes,mbNo], 0);
    if ButtonSelected1 = mrYes then begin
      ShellExecute(handle, nil, PChar('rundll32.exe'), PChar('shell32,SHExitWindowsEx 2'), nil, SW_SHOW);
    end;
  end;
end;

procedure TfrmMain.bttnRescanClick(Sender: TObject);
var
  i, BlackListLevel: Integer;
  Detect, IniFileName: String;
  Installed: Boolean;
  formWait: TfrmWait;
  ZipFileMem : TZipFile;
  StrStream: TStringStream;
  MemStream: TMemoryStream;
begin
  AddToLog('bttnRescanClick', True);
  lstbxInstalledToolbars.Clear;
  lstbxUninstallableToolbars.Clear;
  iniFile.Free;
  LocalAppDataDir := GetSpecialFolder($001a);
  ProgramFilesDir := GetSpecialFolder($0026);
  ZipFileMem := TZipFile.Create;
  ZipFileMem.LoadFromFile(ExtractFilePATH(Application.EXEName) + 'detection.dtz');
  StrStream := TStringStream.Create(ZipFileMem.Data[0]);
  MemStream := TMemoryStream.Create;
  MemStream.LoadFromStream(StrStream);
  MemStream.SaveToFile(ExtractFilePATH(Application.EXEName) + 'detection.dat');
  ZipFileMem.Free;
  StrStream.Free;
  MemStream.Free;
  IniFileName := ExtractFilePath(Application.ExeName) + 'detection.dat';
  IniFile := TMemIniFile.Create(IniFileName);
  DeleteFile(ExtractFilePath(Application.ExeName) + 'detection.dat');
  iToolbars := TStringList.Create;
  DatFileVersion := IniFile.ReadString('Version', 'fileversion', '');
  IniFile.ReadSections(iToolbars);
  frmMain.Caption := MainCaption + ' - ' + DKLangConstW('sMainCaption', [IntToStr(iToolbars.Count - 1)]);
  formWait := TfrmWait.Create(Application);
  formWait.Caption := DKLangConstW('sScanningWait');
  formWait.Label1.Caption := DKLangConstW('sScanningCaption');
  formWait.ProgressBar1.Max := iToolbars.Count;
  formWait.ProgressBar1.Position := 0;
  formWait.Show;
  for i := 1 to iToolbars.Count do begin
    formWait.lblProgramName.Caption := iToolbars.Strings[i-1];
    formWait.Update;
    formWait.ProgressBar1.StepIt;
    Detect := iniFile.ReadString(iToolbars.Strings[i-1], 'Detect', 'NA');
    Installed := DetectInstalledToolbar(Detect);
    BlackListLevel := iniFile.ReadInteger(iToolbars.Strings[i-1], 'RiskLevel', 3);
    if (AutoBlackList <= BlackListLevel) and Installed then begin
      lstbxUninstallableToolbars.Items.Add(iToolbars.Strings[i-1]);
      AddToLog('Found High-Risk Toolbar: ' + iToolbars.Strings[i-1], False);
    end else if Installed then begin
      if ToolbarWhiteList.IndexOf(iToolbars.Strings[i-1]) <> -1 then begin
        AddToLog('Found Whitelisted Toolbar: ' + iToolbars.Strings[i-1], False);
      end else begin
        lstbxInstalledToolbars.Items.Add(iToolbars.Strings[i-1]);
        AddToLog('Found Toolbar: ' + iToolbars.Strings[i-1], False);
      end;
    end;
  end;
  formWait.Destroy;
  CheckUninstallBox;
end;

procedure TfrmMain.bttnMoveAllRightClick(Sender: TObject);
var
  i: Integer;
begin
  AddToLog('bttnMoveAllRightClick', True);
  for i := lstbxInstalledToolbars.Count downto 1 do begin
    lstbxUninstallableToolbars.Items.Add(lstbxInstalledToolbars.Items.Strings[i-1]);
    lstbxInstalledToolbars.Items.Delete(i-1);
  end;
  CheckUninstallBox;
end;

procedure TfrmMain.bttnOptionsClick(Sender: TObject);
var
  iniSettings: TIniFile;
  IniSettingsFileName: String;
  formOptions: TfrmOptions;
begin
  AddToLog('bttnOptionsClick', True);
  formOptions := TfrmOptions.Create(Application);
  if formOptions.ShowModal = mrOK then begin
    IniSettingsFileName := ExtractFilePath(Application.ExeName) + 'settings.ini';
    IniSettings := TIniFile.Create(IniSettingsFileName);
    IniSettings.WriteBool('Update', 'autoupdateonstart', autoupdateonstart);
    IniSettings.WriteBool('Message', 'showremovewarning', showremovewarning);
    IniSettings.WriteBool('Message', 'showbrowserclosewarning', showbrowserclosewarning);
    IniSettings.WriteBool('Log', 'createlog', createlog);
    IniSettings.WriteBool('Log', 'detailedlog', detailedlog);
    IniSettings.WriteBool('Log', 'clearlog', clearlog);
    IniSettings.WriteInteger('Lang', 'SelectedLang', programlanguage);
    FreeAndNil(IniSettings);
  end;
  formOptions.Destroy;
end;

procedure TfrmMain.bttnMoveAllLeftClick(Sender: TObject);
var
  i: Integer;
begin
  AddToLog('bttnMoveAllLeftClick', True);
  for i := lstbxUninstallableToolbars.Count downto 1 do begin
    lstbxInstalledToolbars.Items.Add(lstbxUninstallableToolbars.Items.Strings[i-1]);
    lstbxUninstallableToolbars.Items.Delete(i-1);
  end;
  CheckUninstallBox;
end;

procedure TfrmMain.bttnMoveSelectedLeftClick(Sender: TObject);
var
  i: Integer;
  j: Array of Integer;
begin
  AddToLog('bttnMoveSelectedLeftClick', True);
  for i := 1 to lstbxUninstallableToolbars.Count do begin
    if lstbxUninstallableToolbars.Selected[i-1] then begin
      lstbxInstalledToolbars.Items.Add(lstbxUninstallableToolbars.Items.Strings[i-1]);
      SetLength(j, Length(j) + 1);
      j[length(j)-1] := i-1;
    end;
  end;
  for i := Length(j) - 1 downto 0 do begin
    lstbxUninstallableToolbars.Items.Delete(j[i]);
  end;
  CheckUninstallBox;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
  procedure DeleteFiles(Name: string);
  var
    srec: TSearchRec;
  begin
    AddToLog('Emptying updates folder', False);
    if FindFirst(Name+'*.*', faAnyFile, srec) = 0 then
    try
      repeat
        DeleteFile(Name+srec.Name);
      until FindNext(srec) <> 0;
    finally
      FindCLose(srec);
    end;
  end;
var
  FvI: TFileVersionInfo;
  SysMenu : HMenu;
  i, j, buttonSelected1, BlackListLevel: Integer;
  Detect, IniFileName, IniSettingsFileName: String;
  Installed: Boolean;
  formWait: TfrmWait;
  iniSettings: TIniFile;
  ZipFileMem : TZipFile;
  StrStream: TStringStream;
  MemStream: TMemoryStream;
begin
  FvI := uMain.FileVersionInfo(Application.ExeName);
  ProgramFileVersion := FvI.FileVersion;
  AutoUpdateOnce := True;
  // Initially we prefer Unicode files
  FIsUnicodeFile := True;
  // Scan for language files in the app directory and register them in the LangManager object
  LangManager.ScanForLangFiles(ExtractFileDir(ParamStr(0)), '*.lng', False);
  NeedReboot := False;
  ProgramDir := ExtractFilePath(Application.ExeName);
  LocalAppDataDir := GetSpecialFolder($001a);
  ProgramFilesDir := GetSpecialFolder($0026);
  IniSettingsFileName := ExtractFilePath(Application.ExeName) + 'settings.ini';
  IniSettings := TIniFile.Create(IniSettingsFileName);
  autoupdateonstart := IniSettings.ReadBool('Update', 'autoupdateonstart', False);
  showremovewarning := IniSettings.ReadBool('Message', 'showremovewarning', False);
  showbrowserclosewarning := IniSettings.ReadBool('Message', 'showbrowserclosewarning', False);
  createlog := IniSettings.ReadBool('Log', 'createlog', False);
  detailedlog := IniSettings.ReadBool('Log', 'detailedlog', False);
  clearlog := IniSettings.ReadBool('Log', 'clearlog', False);
  programlanguage := IniSettings.ReadInteger('Lang', 'SelectedLang', 1);
  ToolbarWhiteList := TStringList.Create;
  IniSettings.ReadSectionValues('Whitelist', ToolbarWhiteList);
  FreeAndNil(IniSettings);
  for j := 1 to ToolbarWhiteList.Count do begin
    ToolbarWhiteList.Strings[j-1] := RightStr(ToolbarWhiteList.Strings[j-1], Length(ToolbarWhiteList.Strings[j-1]) - 5);
  end;
  LangManager.LanguageID := LangManager.LanguageIDs[programlanguage];
  if ParamStr(1) = '/update' then begin
    frmUpdate.ShowModal;
    AutoUpdateOnce := False;
    Application.Terminate;
  end;
  if ParamStr(1) = '/?' then begin
    buttonSelected1 := MessageDlg(DKLangConstW('sHelpParams1') + CrLf + CrLf + DKLangConstW('sHelpParams2') + CrLf + DKLangConstW('sHelpParams3') + CrLf + DKLangConstW('sHelpParams4'), mtInformation, [mbOK], 0);
    if ButtonSelected1 = mrOK then begin
      Application.Terminate;
      Exit;
    end;
  end;
  SysMenu := GetSystemMenu(Handle, FALSE);
  AppendMenu(SysMenu, MF_SEPARATOR, 0, '');
  AppendMenu(SysMenu, MF_STRING, SC_MyMenuItem1, PChar(String(DKLangConstW('sMyMenuCaption1'))));
  DeleteFiles(ExtractFilePATH(Application.EXEName) + 'updates\');
  if clearlog then
    DeleteFile(ExtractFilePath(Application.ExeName) + 'logfile.txt');
  AddToLog('Create Form Main', True);
  if not FileExists(ExtractFilePATH(Application.EXEName) + 'detection.dtz') then
  begin
    MessageBox(0, PAnsiChar(DKLangConstA('sNoDatText')), PAnsiChar(DKLangConstA('sNoDatTitle')), MB_OK + MB_ICONERROR);
    application.Terminate;
  end;
  ZipFileMem := TZipFile.Create;
  ZipFileMem.LoadFromFile(ExtractFilePATH(Application.EXEName) + 'detection.dtz');
  StrStream := TStringStream.Create(ZipFileMem.Data[0]);
  MemStream := TMemoryStream.Create;
  MemStream.LoadFromStream(StrStream);
  MemStream.SaveToFile(ExtractFilePATH(Application.EXEName) + 'detection.dat');
  ZipFileMem.Free;
  StrStream.Free;
  MemStream.Free;
  IniFileName := ExtractFilePath(Application.ExeName) + 'detection.dat';
  IniFile := TMemIniFile.Create(IniFileName);
  DeleteFile(ExtractFilePath(Application.ExeName) + 'detection.dat');
  iToolbars := TStringList.Create;
  DatFileVersion := IniFile.ReadString('Version', 'fileversion', '');
  IniFile.ReadSections(iToolbars);
  frmMain.Caption := MainCaption + ' - ' + DKLangConstW('sMainCaption', [IntToStr(iToolbars.Count - 1)]);
  AddToLog('Start Scanning for toolbars', False);
  formWait := TfrmWait.Create(Application);
  formWait.Caption := DKLangConstW('sScanningWait');
  formWait.Label1.Caption := DKLangConstW('sScanningCaption');
  formWait.ProgressBar1.Max := iToolbars.Count;
  formWait.ProgressBar1.Position := 0;
  formWait.Show;
  for i := 1 to iToolbars.Count do begin
    formWait.lblProgramName.Caption := iToolbars.Strings[i-1];
    formWait.Update;
    formWait.ProgressBar1.StepIt;
    Detect := iniFile.ReadString(iToolbars.Strings[i-1], 'Detect', 'NA');
    Installed := DetectInstalledToolbar(Detect);
    BlackListLevel := iniFile.ReadInteger(iToolbars.Strings[i-1], 'RiskLevel', 3);
    if (AutoBlackList <= BlackListLevel) and Installed then begin
      lstbxUninstallableToolbars.Items.Add(iToolbars.Strings[i-1]);
      AddToLog('Found High-Risk Toolbar: ' + iToolbars.Strings[i-1], False);
    end else if Installed then begin
      if ToolbarWhiteList.IndexOf(iToolbars.Strings[i-1]) <> -1 then begin
        AddToLog('Found Whitelisted Toolbar: ' + iToolbars.Strings[i-1], False);
      end else begin
        lstbxInstalledToolbars.Items.Add(iToolbars.Strings[i-1]);
        AddToLog('Found Toolbar: ' + iToolbars.Strings[i-1], False);
      end;
    end;
  end;
  formWait.Destroy;
  AddToLog('Finish Scanning for toolbars', False);
  CheckUninstallBox;
//  Needs more work
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  AddToLog('Destroy Form Main', True);
  FreeAndNil(iToolbars);
  FreeAndNil(IniFile);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  AddToLog('Show Form Main', True);
  if autoupdateonstart and AutoUpdateOnce then begin
    AutoUpdateOnce := False;
    frmUpdate.ShowModal;
    bttnRescan.Click;
  end;
end;

procedure TfrmMain.lstbxInstalledToolbarsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  CenterText : integer;
  TempText : String;
  Application: String;
begin
  AddToLog('lstbxInstalledToolbarsDrawItem', True);
  lstbxInstalledToolbars.Canvas.FillRect (rect);
  TempText := lstbxInstalledToolbars.Items.Strings[index];
  Application := IniFile.ReadString(TempText, 'Application', '');
  ImageList1.Draw(lstbxInstalledToolbars.Canvas,rect.Left + 4, rect.Top + 4, GetAppNumber(Application) );
  CenterText := ( rect.Bottom - rect.Top - lstbxInstalledToolbars.Canvas.TextHeight(text)) div 2 ;
  lstbxInstalledToolbars.Canvas.TextOut (rect.left + ImageList1.Width + 8 , rect.Top + CenterText, lstbxInstalledToolbars.Items.Strings[index]);
end;

procedure TfrmMain.lstbxInstalledToolbarsMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  height := ImageList1.Height + 4;
end;

procedure TfrmMain.lstbxUninstallableToolbarsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  CenterText : integer;
  TempText : String;
  Application: String;
begin
  AddToLog('lstbxUninstallableToolbarsDrawItem', True);
  lstbxUninstallableToolbars.Canvas.FillRect (rect);
  TempText := lstbxUninstallableToolbars.Items.Strings[index];
  Application := IniFile.ReadString(TempText, 'Application', '');
  ImageList1.Draw(lstbxUninstallableToolbars.Canvas,rect.Left + 4, rect.Top + 4, GetAppNumber(Application) );
  CenterText := ( rect.Bottom - rect.Top - lstbxUninstallableToolbars.Canvas.TextHeight(text)) div 2 ;
  lstbxUninstallableToolbars.Canvas.TextOut (rect.left + ImageList1.Width + 8 , rect.Top + CenterText, lstbxUninstallableToolbars.Items.Strings[index]);
end;

procedure TfrmMain.lstbxUninstallableToolbarsMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  height := ImageList1.Height + 4;
end;

end.
