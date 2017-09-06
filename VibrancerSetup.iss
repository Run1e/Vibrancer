#define MyAppName "Vibrancer"
#define MyAppVersion "1.0.1"
#define MyAppURL "https://github.com/Run1e/Vibrancer"
#define MyAppWiki "https://github.com/Run1e/Vibrancer/wiki"
#define MyAppExeName "Vibrancer.exe"
#define MyAppIcon "D:\Documents\Scripts\Vibrancer\icons\Vibrancer.ico"

[Setup]
AppId={{8017FB27-1E69-41C6-82A4-A8B658F7C7CE}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=Runar Andreas Borge
AppPublisherURL={#MyAppURL}             
AppSupportURL={#MyAppWiki}                  
DefaultDirName={localappdata}\Vibrancer
DisableProgramGroupPage=yes
DisableDirPage=yes
LicenseFile=D:\Documents\Scripts\Vibrancer\LICENSE.txt
OutputBaseFilename=Vibrancer-installer
SetupIconFile={#MyAppIcon}
Compression=lzma
SolidCompression=yes
UninstallDisplayName=Vibrancer
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
 
[InstallDelete]
Type: filesandordirs; Name: "{app}\lib"
Type: filesandordirs; Name: "{app}\plugins\imgurlib"
Type: filesandordirs; Name: "{app}\Vibrancer-Installer.zip"
Type: files; Name: "{app}\PowerPlay.exe"
Type: filesandordirs; Name: "{app}\PowerPlay-installer"
Type: files; Name: "{app}\icons\powerplay.ico"

[Files]
Source: "D:\Documents\Scripts\Vibrancer\Vibrancer\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Dirs]               
Name: "{app}"; Permissions: users-full
                         
[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Parameters: "Vibrancer.ahk /OPEN"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
Filename: "{app}\{#MyAppExeName}"; Parameters: "Vibrancer.ahk /UPDATED"; Flags: nowait skipifnotsilent