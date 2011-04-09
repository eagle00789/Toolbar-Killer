#pragma verboselevel 10
#pragma option -v+
#define MyAppName "Toolbar Uninstaller"
#define MyAppVer GetStringFileInfo("tbk.exe", FILE_VERSION);
#define MyAppVerName MyAppName+" "+MyAppVer
#define MyAppPublisher "Decomputeur.nl"
#define MyAppURL "http://toolbar.decomputeur.nl/"
;#define runner Exec("compile.bat", , , 1, 1)
;#define debug
#ifdef debug
  #define dname "tbk.exe"
  #undef MyAppName
  #define MyAppName "Toolbar Uninstaller Debug"
  #undef MyAppVerName
  #define MyAppVerName MyAppName+" "+MyAppVer
#endif
#ifndef debug
  #define dname "tbu.exe"
#endif
#define MyAppExeName dname
#pragma message " " + MyAppName + " " + MyAppVer + " " + MyAppVerName + " " + MyAppPublisher + " " + MyAppURL + " " + MyAppExeName

[Setup]
AppName={#MyAppName}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=D:\Programmeren\ToolbarKiller\license.txt
InfoBeforeFile=D:\Programmeren\ToolbarKiller\changelog.txt
OutputBaseFilename={#MyAppName} {#MyAppVer}
Compression=lzma/ultra64
SolidCompression=yes
VersionInfoVersion={#MyAppVer}
;SignedUninstaller=yes
;SignedUninstallerDir=D:\Programmeren\ToolbarKiller\SignedUninstaller

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "D:\Programmeren\ToolbarKiller\helper.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Programmeren\ToolbarKiller\tbk.exe"; DestDir: "{app}"; DestName: "{#dname}"; Flags: ignoreversion
Source: "D:\Programmeren\ToolbarKiller\detection.dtz"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Programmeren\ToolbarKiller\Help\TbU.chm"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Programmeren\ToolbarKiller\dutch.lng"; DestDir: "{app}"; Flags: ignoreversion

[INI]
Filename: "{app}\settings.ini"; Section: "Update"; Flags: uninsdeletesection
Filename: "{app}\settings.ini"; Section: "Update"; Key: "autoupdateonstart"; String: "0"; Flags: createkeyifdoesntexist
Filename: "{app}\settings.ini"; Section: "Message"; Flags: uninsdeletesection
Filename: "{app}\settings.ini"; Section: "Message"; Key: "showremovewarning"; String: "0"; Flags: createkeyifdoesntexist
Filename: "{app}\settings.ini"; Section: "Message"; Key: "showbrowserclosewarning"; String: "1"; Flags: createkeyifdoesntexist
Filename: "{app}\settings.ini"; Section: "Log"; Flags: uninsdeletesection
Filename: "{app}\settings.ini"; Section: "Log"; Key: "createlog"; String: "1"; Flags: createkeyifdoesntexist
Filename: "{app}\settings.ini"; Section: "Log"; Key: "detailedlog"; String: "0"; Flags: createkeyifdoesntexist
Filename: "{app}\settings.ini"; Section: "Log"; Key: "clearlog"; String: "0"; Flags: createkeyifdoesntexist
Filename: "{app}\settings.ini"; Section: "Lang"; Flags: uninsdeletesection
Filename: "{app}\settings.ini"; Section: "Lang"; Key: "SelectedLang"; String: "0"; Flags: createkeyifdoesntexist

[Dirs]
Name: "{app}\updates"

[UninstallDelete]
Type: files; Name: "{app}\settings.ini"
Type: filesandordirs ; Name: "{app}\updates"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"; WorkingDir: "{app}"
Name: "{group}\{#MyAppName} Help"; Filename: "{app}\TbU.chm"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; WorkingDir: "{app}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; WorkingDir: "{app}"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon; WorkingDir: "{app}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall

