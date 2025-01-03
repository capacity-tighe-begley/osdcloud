# Define Unattended Windows Installation Variables & Functions
# Check if the marker file exists to determine if we are in the specialize phase
$markerFilePath = "C:\specialize_marker.txt"
$isSpecializePhase = Test-Path $markerFilePath
# Function to Pause scripts only when not in Specialize Phase
function Wait-IfNotSpecialize {
    if (-not $isSpecializePhase) {
        Pause
    }
}

# START OF COMMAND & OPERATION FUNCTIONS
# Start of Software & Apps Functions

# Remove Bloatware Apps Functions
# Define Packages
$appxPackages = @(
    'Microsoft.Microsoft3DViewer', 'Microsoft.BingSearch', 'Microsoft.WindowsCamera', 'Clipchamp.Clipchamp',
    'Microsoft.WindowsAlarms', 'Microsoft.549981C3F5F10', 'Microsoft.Windows.DevHome',
    'MicrosoftCorporationII.MicrosoftFamily', 'Microsoft.WindowsFeedbackHub', 'Microsoft.GetHelp',
    'microsoft.windowscommunicationsapps', 'Microsoft.WindowsMaps', 'Microsoft.ZuneVideo',
    'Microsoft.BingNews', 'Microsoft.MicrosoftOfficeHub', 'Microsoft.Office.OneNote',
    'Microsoft.OutlookForWindows', 'Microsoft.People', 'Microsoft.Windows.Photos',
    'Microsoft.PowerAutomateDesktop', 'MicrosoftCorporationII.QuickAssist', 'Microsoft.SkypeApp',
    'Microsoft.MicrosoftSolitaireCollection', 'Microsoft.MicrosoftStickyNotes', 'MSTeams',
    'Microsoft.Getstarted', 'Microsoft.Todos', 'Microsoft.WindowsSoundRecorder', 'Microsoft.BingWeather',
    'Microsoft.ZuneMusic', 'Microsoft.WindowsTerminal', 'Microsoft.Xbox.TCUI', 'Microsoft.XboxApp',
    'Microsoft.XboxGameOverlay', 'Microsoft.XboxGamingOverlay', 'Microsoft.XboxIdentityProvider',
    'Microsoft.XboxSpeechToTextOverlay', 'Microsoft.GamingApp', 'Microsoft.YourPhone', 'Microsoft.OneDrive',
    'Microsoft.549981C3F5F10', 'Microsoft.MixedReality.Portal', 'Microsoft.ScreenSketch'
    'Microsoft.Windows.Ai.Copilot.Provider', 'Microsoft.Copilot', 'Microsoft.Copilot_8wekyb3d8bbwe',
    'Microsoft.WindowsMeetNow', 'Microsoft.WindowsStore', 'Microsoft.Paint', 'Microsoft.MSPaint'
)

# Define Windows Capabilities
$capabilities = @(
    'Browser.InternetExplorer', 'MathRecognizer', 'OpenSSH.Client',
    'Microsoft.Windows.PowerShell.ISE', 'App.Support.QuickAssist', 'App.StepsRecorder',
    'Media.WindowsMediaPlayer', 'Microsoft.Windows.WordPad', 'Microsoft.Windows.MSPaint'
)

# Apply registry mods to prevent reinstallation and disable features
function Set-AppsRegistry {
    $MultilineComment = @"
Windows Registry Editor Version 5.00

; --Application and Feature Restrictions--

; Disable Windows Copilot system-wide
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

; Prevents Dev Home Installation
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate]

; Prevents New Outlook for Windows Installation
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate]

; Prevents Chat Auto Installation
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications]
"ConfigureChatAutoInstall"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Chat]
"ChatIcon"=dword:00000003

; Disables Cortana
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Search]
"AllowCortana"=dword:00000000

; Disables OneDrive Automatic Backups of Important Folders (Documents, Pictures etc.)
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\OneDrive]
"KFMBlockOptIn"=dword:00000001
"@
    Set-Content -Path "$env:TEMP\Windows_Apps.reg" -Value $MultilineComment -Force -ErrorAction SilentlyContinue
    Regedit.exe /S "$env:TEMP\Windows_Apps.reg" -Force -ErrorAction SilentlyContinue
}

# Removes OneDrive during Windows Installation
function Remove-OneDrive {
    Remove-Item "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -ErrorAction SilentlyContinue
    Remove-Item "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.exe" -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\System32\OneDriveSetup.exe" -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\SysWOW64\OneDriveSetup.exe" -ErrorAction SilentlyContinue
}

# Uninstalls OneDrive in existing Windows Installation
function Uninstall-OneDrive {
    # stop onedrive running
    Stop-Process -Force -Name OneDrive -ErrorAction SilentlyContinue | Out-Null
    # uninstall onedrive w10
    cmd /c "C:\Windows\SysWOW64\OneDriveSetup.exe -uninstall >nul 2>&1"
    # clean onedrive w10 
    Get-ScheduledTask | Where-Object { $_.Taskname -match 'OneDrive' } | Unregister-ScheduledTask -Confirm:$false
    # uninstall onedrive w11
    cmd /c "C:\Windows\System32\OneDriveSetup.exe -uninstall >nul 2>&1"
}

# Disables Recall
function Disable-Recall {
    Dism /Online /Disable-Feature /Featurename:Recall /NoRestart | Out-Null
}

# Remove All Bloatware (UWP) Apps from Windows.
function Remove-Apps {
        # Bloatware Apps
        Get-AppxPackage -AllUsers |
        Where-Object { $appxPackages -contains $_.Name } |
        Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Out-Null
        # Legacy Windows Features & Apps
        Get-WindowsCapability -Online |
        Where-Object { $capabilities -contains ($_.Name -split '~')[0] } |
        Remove-WindowsCapability -Online -ErrorAction SilentlyContinue | Out-Null
        # Calls specified functions
        Set-AppsRegistry
        Uninstall-OneDrive
        Disable-Recall
}
# End of Software & Apps Functions

# Start of Privacy & Security Functions

# Function to Apply the Recommended Privacy Settings
function Set-RecommendedPrivacySettings {
    
    $MultilineComment = @"
Windows Registry Editor Version 5.00

; --Privacy and Security Settings--

; Disables Activity History
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
"EnableActivityFeed"=dword:00000000
"PublishUserActivities"=dword:00000000
"UploadUserActivities"=dword:00000000

; Disables Location Tracking
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
"Value"="Deny"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}]
"SensorPermissionState"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration]
"Status"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\Maps]
"AutoUpdateEnabled"=dword:00000000

; Disables Telemetry
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
"AllowTelemetry"=dword:00000000

; Disables Telemetry and Feedback Notifications
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection]
"AllowTelemetry"=dword:00000000
"DoNotShowFeedbackNotifications"=dword:00000001

; Disables Windows Ink Workspace
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace]
"AllowWindowsInkWorkspace"=dword:00000000

; Disables the Advertising ID for All Users
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo]
"DisabledByGroupPolicy"=dword:00000001

; Disable Account Info
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation]
"Value"="Deny"
"@
    # Write the registry changes to a file and silently import it using regedit
    Set-Content -Path "$env:TEMP\Recommended_Privacy_Settings.reg" -Value $MultilineComment -Force
    Start-Process -FilePath "regedit.exe" -ArgumentList "/S `"$env:TEMP\Recommended_Privacy_Settings.reg`"" -NoNewWindow -Wait

}

# End of Privacy and Security Functions

# Start of Registry Optimizations

function Set-RecommendedHKLMRegistry {
    # Create Registry Keys
    $MultilineComment = @"
Windows Registry Editor Version 5.00

; Adds "Take Ownership" to the Right Click Context Menu for All Users
                
[-HKEY_CLASSES_ROOT\*\shell\TakeOwnership]
[-HKEY_CLASSES_ROOT\*\shell\runas]
          
[HKEY_CLASSES_ROOT\*\shell\TakeOwnership]
@="Take Ownership"
"Extended"=-
"HasLUAShield"=""
"NoWorkingDirectory"=""
"NeverDefault"=""
          
[HKEY_CLASSES_ROOT\*\shell\TakeOwnership\command]
@="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l & pause' -Verb runAs\""
"IsolatedCommand"= "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l & pause' -Verb runAs\""
               
[HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership]
@="Take Ownership"
"AppliesTo"="NOT (System.ItemPathDisplay:=\"C:\\Users\" OR System.ItemPathDisplay:=\"C:\\ProgramData\" OR System.ItemPathDisplay:=\"C:\\Windows\" OR System.ItemPathDisplay:=\"C:\\Windows\\System32\" OR System.ItemPathDisplay:=\"C:\\Program Files\" OR System.ItemPathDisplay:=\"C:\\Program Files (x86)\")"
"Extended"=-
"HasLUAShield"=""
"NoWorkingDirectory"=""
"Position"="middle"
          
[HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership\command]
@="powershell -windowstyle hidden -command \"$Y = ($null | choice).Substring(1,1); Start-Process cmd -ArgumentList ('/c takeown /f \\\"%1\\\" /r /d ' + $Y + ' && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l /q & pause') -Verb runAs\""
"IsolatedCommand"="powershell -windowstyle hidden -command \"$Y = ($null | choice).Substring(1,1); Start-Process cmd -ArgumentList ('/c takeown /f \\\"%1\\\" /r /d ' + $Y + ' && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l /q & pause') -Verb runAs\""
                
[HKEY_CLASSES_ROOT\Drive\shell\runas]
@="Take Ownership"
"Extended"=-
"HasLUAShield"=""
"NoWorkingDirectory"=""
"Position"="middle"
"AppliesTo"="NOT (System.ItemPathDisplay:=\"C:\\\")"
          
[HKEY_CLASSES_ROOT\Drive\shell\runas\command]
@="cmd.exe /c takeown /f \"%1\\\" /r /d y && icacls \"%1\\\" /grant *S-1-3-4:F /t /c & Pause"
"IsolatedCommand"="cmd.exe /c takeown /f \"%1\\\" /r /d y && icacls \"%1\\\" /grant *S-1-3-4:F /t /c & Pause"

; --Application and Feature Restrictions--

; Disable Windows Copilot system-wide
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

; Prevents Dev Home Installation
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate]

; Prevents New Outlook for Windows Installation
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate]

; Prevents Chat Auto Installation and Removes Chat Icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications]
"ConfigureChatAutoInstall"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Chat]
"ChatIcon"=dword:00000003

; Disables Bitlocker Auto Encryption on Windows 11 24H2 and Onwards
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\BitLocker]
"PreventDeviceEncryption"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices]
"TCGSecurityActivationDisabled"=dword:00000001

; Disables Cortana
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Search]
"AllowCortana"=dword:00000000

; Set Registry Keys to Disable Wifi-Sense
[HKEY_LOCAL_MACHINE\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting]
"Value"=dword:00000000

[HKEY_LOCAL_MACHINE\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots]
"Value"=dword:00000000

; Disable Tablet Mode
; Always go to desktop mode on sign-in
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell]
"TabletMode"=dword:00000000
"SignInMode"=dword:00000001

; Disable Xbox GameDVR
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR]
"AllowGameDVR"=dword:00000000

; Disables OneDrive Automatic Backups of Important Folders (Documents, Pictures etc.)
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\OneDrive]
"KFMBlockOptIn"=dword:00000001

; Disables the "Push To Install" feature in Windows
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PushToInstall]
"DisablePushToInstall"=dword:00000001

; Disables Windows Consumer Features Like App Promotions etc.
; Disables Consumer Account State Content
; Disables Cloud Optimized Content
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CloudContent]
"DisableWindowsConsumerFeatures"=dword:00000000
"DisableConsumerAccountStateContent"=dword:00000001
"DisableCloudOptimizedContent"=dword:00000001

; Blocks the "Allow my organization to manage my device" and "No, sign in to this app only" pop-up message
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin]
"BlockAADWorkplaceJoin"=dword:00000001

; --Start Menu Customization--
; Removes All Pinned Apps from the Start Menu to Clean it Up
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start]
"ConfigureStartPins"="{ \"pinnedList\": [] }"
"ConfigureStartPins_ProviderSet"=dword:00000001
"ConfigureStartPins_WinningProvider"="B5292708-1619-419B-9923-E5D9F3925E71"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start]
"ConfigureStartPins"="{ \"pinnedList\": [] }"
"ConfigureStartPins_LastWrite"=dword:00000001

; --File System Settings--
; Enable Long File Paths with Up to 32,767 Characters
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
"LongPathsEnabled"=dword:00000001

; --Multimedia and Gaming Performance--
; Gives Multimedia Applications like Games and Video Editing a Higher Priority
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile]
"SystemResponsiveness"=dword:00000000
"NetworkThrottlingIndex"=dword:0000000a

; Gives Graphics Cards a Higher Priority for Gaming
; Gives the CPU a Higher Priority for Gaming
; Gives Games a higher priority in the system's scheduling
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games]
"GPU Priority"=dword:00000008
"Priority"=dword:00000006
"Scheduling Category"="High"

; disable startup sound
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation]
"DisableStartupSound"=dword:00000001

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\EditionOverrides]
"UserSetting_DisableStartupSound"=dword:00000001

; disable device installation settings
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata]
"PreventDeviceMetadataFromNetwork"=dword:00000001

; NETWORK AND INTERNET
; disable allow other network users to control or disable the shared internet connection
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Network\SharedAccessConnection]
"EnableControl"=dword:00000000

; SYSTEM AND SECURITY
; adjust for best performance of programs
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000026

; disable remote assistance
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance]
"fAllowToGetHelp"=dword:00000000

; TROUBLESHOOTING
; disable automatic maintenance
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance]
"MaintenanceDisabled"=dword:00000001

; SECURITY AND MAINTENANCE
; disable report problems
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting]
"Disabled"=dword:00000001

; ACCOUNTS
; disable use my sign in info after restart
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"DisableAutomaticRestartSignOn"=dword:00000001

; APPS
; disable archive apps 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Appx]
"AllowAutomaticAppArchiving"=dword:00000000

; PERSONALIZATION
; Hides the Meet Now Button on the Taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-

; remove windows widgets from taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh] 
"AllowNewsAndInterests"=dword:00000000

; remove news and interests from Taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000000

; SYSTEM
; turn on hardware accelerated gpu scheduling
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers]
"HwSchMode"=dword:00000002

; disable storage sense
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\StorageSense]
"AllowStorageSenseGlobal"=dword:00000000

; --OTHER--
; Disable update Microsoft Store apps automatically
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore]
"AutoDownload"=dword:00000002

; UWP APPS
; disable background apps
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsRunInBackground"=dword:00000002

; disable widgets
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests]
"value"=dword:00000000

; NVIDIA
; enable old nvidia sharpening
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS]
"EnableGR535"=dword:00000000

; OTHER
; remove 3d objects
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
[-HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]

; Remove Home Folder
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}]

[HKEY_USERS\.DEFAULT\Control Panel\Mouse]
"MouseSpeed"="0"
"MouseThreshold1"="0"
"MouseThreshold2"="0"
"@
    Set-Content -Path "$env:TEMP\Optimize_LocalMachine_Registry.reg" -Value $MultilineComment -Force
    # edit reg file
    $path = "$env:TEMP\Optimize_LocalMachine_Registry.reg"
    (Get-Content $path) -replace "\?", "$" | Out-File $path
    # import reg file
    Regedit.exe /S "$env:TEMP\Optimize_LocalMachine_Registry.reg"
}

function Set-RecommendedHKCURegistry {

    # Set Wallpaper (Helper Function for Recommended User Settings)
    $defaultWallpaperPath = "C:\Windows\Web\4K\Wallpaper\Windows\img0_3840x2160.jpg"
    $darkModeWallpaperPath = "C:\Windows\Web\4K\Wallpaper\Windows\img19_1920x1200.jpg"

    function Set-Wallpaper ($wallpaperPath) {
        reg.exe add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "$wallpaperPath" /f | Out-Null
        # Notify the system of the change
        rundll32.exe user32.dll, UpdatePerUserSystemParameters
    }

    # Check Windows version
    $windowsVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild

    # Apply appropriate wallpaper based on Windows version or existence of dark mode wallpaper
    if ($windowsVersion -ge 22000) {
        # Assuming Windows 11 starts at build 22000
        if (Test-Path $darkModeWallpaperPath) {
            Set-Wallpaper -wallpaperPath $darkModeWallpaperPath
        }
    }
    else {
        # Apply default wallpaper for Windows 10
        Set-Wallpaper -wallpaperPath $defaultWallpaperPath
    }

    $MultilineComment = @"
Windows Registry Editor Version 5.00

; EASE OF ACCESS
; disable narrator
[HKEY_CURRENT_USER\Software\Microsoft\Narrator\NoRoam]
"DuckAudio"=dword:00000000
"WinEnterLaunchEnabled"=dword:00000000
"ScriptingEnabled"=dword:00000000
"OnlineServicesEnabled"=dword:00000000
"EchoToggleKeys"=dword:00000000

; disable narrator settings
[HKEY_CURRENT_USER\Software\Microsoft\Narrator]
"NarratorCursorHighlight"=dword:00000000
"CoupleNarratorCursorKeyboard"=dword:00000000
"IntonationPause"=dword:00000000
"ReadHints"=dword:00000000
"ErrorNotificationType"=dword:00000000
"EchoChars"=dword:00000000
"EchoWords"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator\NarratorHome]
"MinimizeType"=dword:00000000
"AutoStart"=dword:00000000

; disable ease of access settings 
[HKEY_CURRENT_USER\Software\Microsoft\Ease of Access]
"selfvoice"=dword:00000000
"selfscan"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility]
"Sound on Activation"=dword:00000000
"Warning Sounds"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility\HighContrast]
"Flags"="4194"

[HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response]
"Flags"="2"
"AutoRepeatRate"="0"
"AutoRepeatDelay"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\MouseKeys]
"Flags"="130"
"MaximumSpeed"="39"
"TimeToMaximumSpeed"="3000"

[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
"Flags"="2"

[HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys]
"Flags"="34"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry]
"Flags"="0"
"FSTextEffect"="0"
"TextEffect"="0"
"WindowsEffect"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SlateLaunch]
"ATapp"=""
"LaunchAT"=dword:00000000

; CLOCK AND REGION
; disable notify me when the clock changes
[HKEY_CURRENT_USER\Control Panel\TimeDate]
"DstNotification"=dword:00000000

; APPEARANCE AND PERSONALIZATION
; open file explorer to this pc
; show file name extensions
; disable display file size information in folder tips
; disable show pop-up description for folder and desktop items
; disable show preview handlers in preview pane
; disable show status bar
; disable show sync provider notifications
; disable use sharing wizard
; disable animations in the taskbar
; enable show thumbnails instead of icons
; disable show translucent selection rectangle
; disable use drop shadows for icon labels on the desktop
; more pins personalization start
; disable show account-related notifications
; disable show recently opened items in start, jump lists and file explorer
; left taskbar alignment
; remove chat from taskbar
; remove task view from taskbar
; remove copilot from taskbar
; disable show recommendations for tips shortcuts new apps and more
; disable share any window from my taskbar
; disable snap window settings - SnapAssist to JointResize Entries
; alt tab open windows only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"LaunchTo"=dword:00000001
"HideFileExt"=dword:00000000
"FolderContentsInfoTip"=dword:00000000
"ShowInfoTip"=dword:00000000
"ShowPreviewHandlers"=dword:00000000
"ShowStatusBar"=dword:00000000
"ShowSyncProviderNotifications"=dword:00000000
"SharingWizardOn"=dword:00000000
"TaskbarAnimations"=dword:0
"IconsOnly"=dword:0
"ListviewAlphaSelect"=dword:0
"ListviewShadow"=dword:0
"Start_Layout"=dword:00000001
"Start_AccountNotifications"=dword:00000000
"Start_TrackDocs"=dword:00000000 
"TaskbarAl"=dword:00000000
"TaskbarMn"=dword:00000000
"ShowTaskViewButton"=dword:00000000
"ShowCopilotButton"=dword:00000000
"Start_IrisRecommendations"=dword:00000000
"TaskbarSn"=dword:00000000
"SnapAssist"=dword:00000000
"DITest"=dword:00000000
"EnableSnapBar"=dword:00000000
"EnableTaskGroups"=dword:00000000
"EnableSnapAssistFlyout"=dword:00000000
"SnapFill"=dword:00000000
"JointResize"=dword:00000000
"MultiTaskingAltTabFilter"=dword:00000003

; hide frequent folders in quick access
; disable show files from office.com
; show all taskbar icons on Windows 10
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"ShowFrequent"=dword:00000000
"ShowCloudFilesInQuickAccess"=dword:00000000
"EnableAutoTray"=dword:00000000

; enable display full path in the title bar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState]
"FullPath"=dword:00000001

; HARDWARE AND SOUND
; sound communications do nothing
[HKEY_CURRENT_USER\Software\Microsoft\Multimedia\Audio]
"UserDuckingPreference"=dword:00000003

; disable enhance pointer precision
; mouse fix (no accel with epp on)
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSpeed"="0"
"MouseThreshold1"="0"
"MouseThreshold2"="0"
"MouseSensitivity"="10"
"SmoothMouseXCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	C0,CC,0C,00,00,00,00,00,\
	80,99,19,00,00,00,00,00,\
	40,66,26,00,00,00,00,00,\
	00,33,33,00,00,00,00,00
"SmoothMouseYCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	00,00,38,00,00,00,00,00,\
	00,00,70,00,00,00,00,00,\
	00,00,A8,00,00,00,00,00,\
	00,00,E0,00,00,00,00,00

; SYSTEM AND SECURITY
; set appearance options to custom
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
"VisualFXSetting"=dword:3

; disable animate controls and elements inside windows
; disable fade or slide menus into view
; disable fade or slide tooltips into view
; disable fade out menu items after clicking
; disable show shadows under mouse pointer
; disable show shadows under windows
; disable slide open combo boxes
; disable smooth-scroll list boxes
; enable smooth edges of screen fonts
; 100% dpi scaling
; disable fix scaling for apps
; disable menu show delay
[HKEY_CURRENT_USER\Control Panel\Desktop]
"UserPreferencesMask"=hex(2):90,12,03,80,10,00,00,00
"FontSmoothing"="2"
"LogPixels"=dword:00000060
"Win8DpiScaling"=dword:00000001
"EnablePerProcessSystemDPI"=dword:00000000
"MenuShowDelay"="0"

; --IMMERSIVE CONTROL PANEL--
; PRIVACY
; disable show me notification in the settings app
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications]
"EnableAccountNotifications"=dword:00000000

; disable voice activation
[HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationEnabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationLastUsed"=dword:00000000

; disable other devices 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync]
"Value"="Deny"

; disable let websites show me locally relevant content by accessing my language list 
[HKEY_CURRENT_USER\Control Panel\International\User Profile]
"HttpAcceptLanguageOptOut"=dword:00000001

; disable let windows improve start and search results by tracking app launches  
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\EdgeUI]
"DisableMFUTracking"=dword:00000001

; disable personal inking and typing dictionary
[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization]
"RestrictImplicitInkCollection"=dword:00000001
"RestrictImplicitTextCollection"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore]
"HarvestContacts"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings]
"AcceptedPrivacyPolicy"=dword:00000000

; feedback frequency never
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Siuf\Rules]
"NumberOfSIUFInPeriod"=dword:00000000
"PeriodInNanoSeconds"=-

; SEARCH
; disable search highlights
; disable search history
; disable safe search
; disable cloud content search for work or school account
; disable cloud content search for microsoft account
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDynamicSearchBoxEnabled"=dword:00000000
"IsDeviceSearchHistoryEnabled"=dword:00000000
"SafeSearchMode"=dword:00000000
"IsAADCloudSearchEnabled"=dword:00000000
"IsMSACloudSearchEnabled"=dword:00000000

; EASE OF ACCESS
; disable magnifier settings 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\ScreenMagnifier]
"FollowCaret"=dword:00000000
"FollowNarrator"=dword:00000000
"FollowMouse"=dword:00000000
"FollowFocus"=dword:00000000

; GAMING
; disable game bar
[HKEY_CURRENT_USER\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000

; disable enable open xbox game bar using game controller
; enable game mode
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"UseNexusForGameBarEnabled"=dword:00000000
"AutoGameModeEnabled"=dword:00000001

; other settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AppCaptureEnabled"=dword:00000000
"AudioEncodingBitrate"=dword:0001f400
"AudioCaptureEnabled"=dword:00000000
"CustomVideoEncodingBitrate"=dword:003d0900
"CustomVideoEncodingHeight"=dword:000002d0
"CustomVideoEncodingWidth"=dword:00000500
"HistoricalBufferLength"=dword:0000001e
"HistoricalBufferLengthUnit"=dword:00000001
"HistoricalCaptureEnabled"=dword:00000000
"HistoricalCaptureOnBatteryAllowed"=dword:00000001
"HistoricalCaptureOnWirelessDisplayAllowed"=dword:00000001
"MaximumRecordLength"=hex(b):00,D0,88,C3,10,00,00,00
"VideoEncodingBitrateMode"=dword:00000002
"VideoEncodingResolutionMode"=dword:00000002
"VideoEncodingFrameRateMode"=dword:00000000
"EchoCancellationEnabled"=dword:00000001
"CursorCaptureEnabled"=dword:00000000
"VKToggleGameBar"=dword:00000000
"VKMToggleGameBar"=dword:00000000
"VKSaveHistoricalVideo"=dword:00000000
"VKMSaveHistoricalVideo"=dword:00000000
"VKToggleRecording"=dword:00000000
"VKMToggleRecording"=dword:00000000
"VKTakeScreenshot"=dword:00000000
"VKMTakeScreenshot"=dword:00000000
"VKToggleRecordingIndicator"=dword:00000000
"VKMToggleRecordingIndicator"=dword:00000000
"VKToggleMicrophoneCapture"=dword:00000000
"VKMToggleMicrophoneCapture"=dword:00000000
"VKToggleCameraCapture"=dword:00000000
"VKMToggleCameraCapture"=dword:00000000
"VKToggleBroadcast"=dword:00000000
"VKMToggleBroadcast"=dword:00000000
"MicrophoneCaptureEnabled"=dword:00000000
"SystemAudioGain"=hex(b):10,27,00,00,00,00,00,00
"MicrophoneGain"=hex(b):10,27,00,00,00,00,00,00

; TIME & LANGUAGE 
; disable show the voice typing mic button
; disable typing insights
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"IsVoiceTypingKeyEnabled"=dword:00000000
"InsightsEnabled"=dword:00000000

; disable capitalize the first letter of each sentence
; disable play key sounds as i type
; disable add a period after i double-tap the spacebar
; disable show key background
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\1.7]
"EnableAutoShiftEngage"=dword:00000000
"EnableKeyAudioFeedback"=dword:00000000
"EnableDoubleTapSpace"=dword:00000000
"IsKeyBackgroundEnabled"=dword:00000000

; PERSONALIZATION
; dark theme 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
"AppsUseLightTheme"=dword:00000000
"SystemUsesLightTheme"=dword:00000000
"EnableTransparency"=dword:00000001

; disable web search in start menu 
[HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"DisableSearchBoxSuggestions"=dword:00000001

; Remove meet now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-
"HideSCAMeetNow"=dword:00000001

; remove search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

; disable use dynamic lighting on my devices
; disable compatible apps in the forground always control lighting
; disable match my windows accent color
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"AmbientLightingEnabled"=dword:00000000
"ControlledByForegroundApp"=dword:00000000
"UseSystemAccentColor"=dword:00000000

; DEVICES
; disable let windows manage my default printer
[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Windows]
"LegacyDefaultPrinterMode"=dword:00000001

; disable write with your fingertip
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\EmbeddedInkControl]
"EnableInkingWithTouch"=dword:00000000

; SYSTEM
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\DWM]
"UseDpiScaling"=dword:00000000

; disable variable refresh rate & enable optimizations for windowed games
[HKEY_CURRENT_USER\Software\Microsoft\DirectX\UserGpuPreferences]
"DirectXUserGlobalSettings"="SwapEffectUpgradeEnable=1;VRROptimizeEnable=0;"

; disable notifications
; Disable Notifications on Lock Screen
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications]
"ToastEnabled"=dword:00000000
"LockScreenToastEnabled"=dword:00000000

; Disable Allow Notifications to Play Sounds
; Disable Notifications on Lock Screen
; Disable Show Reminders and VoIP Calls Notifications on Lock Screen
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings]
"NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND"=dword:00000000
"NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK"=dword:00000000
"NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.CapabilityAccess]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.StartupApp]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
"ScoobeSystemSettingEnabled"=dword:00000000

; disable suggested actions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard]
"Disabled"=dword:00000001

; battery options optimize for video quality
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
"VideoQualityOnBattery"=dword:00000001

; UWP Apps
; disable windows input experience preload
[HKEY_CURRENT_USER\Software\Microsoft\input]
"IsInputAppPreloadEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Dsh]
"IsPrelaunchEnabled"=dword:00000000

; disable copilot
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

; DISABLE ADVERTISING & PROMOTIONAL
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"ContentDeliveryAllowed"=dword:00000000
"FeatureManagementEnabled"=dword:00000000
"OemPreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEverEnabled"=dword:00000000
"RotatingLockScreenEnabled"=dword:00000000
"RotatingLockScreenOverlayEnabled"=dword:00000000
"SilentInstalledAppsEnabled"=dword:00000000
"SlideshowEnabled"=dword:00000000
"SoftLandingEnabled"=dword:00000000
"SubscribedContent-310093Enabled"=dword:00000000
"SubscribedContent-314563Enabled"=dword:00000000
"SubscribedContent-338388Enabled"=dword:00000000
"SubscribedContent-338389Enabled"=dword:00000000
"SubscribedContent-338393Enabled"=dword:00000000
"SubscribedContent-353694Enabled"=dword:00000000
"SubscribedContent-353696Enabled"=dword:00000000
"SubscribedContent-353698Enabled"=dword:00000000
"SubscribedContentEnabled"=dword:00000000
"SystemPaneSuggestionsEnabled"=dword:00000000

; OTHER
; remove gallery
[HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]
"System.IsPinnedToNameSpaceTree"=dword:00000000

; restore the classic context menu
[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
@=""

; removes OneDrive Setup
[-HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run]
"OneDriveSetup"=-

; Hides the Try New Outlook Button
[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook\Options\General]
"HideNewOutlookToggle"=dword:00000000
"@
    Set-Content -Path "$env:TEMP\Optimize_User_Registry.reg" -Value $MultilineComment -Force
    Regedit.exe /S "$env:TEMP\Optimize_User_Registry.reg"
}

# End of Registry Optimizations

# Start of Tasks and Services Functions
# Start of Tasks and Services Functions

function Set-ServiceStartup {
    # List of services to set to Disabled
    $disabledServices = @(
    'AJRouter', 'AppVClient', 'AssignedAccessManagerSvc', 
    'DiagTrack', 'DialogBlockingService', 'NetTcpPortSharing',
    'RemoteAccess', 'RemoteRegistry', 'shpamsvc', 
    'ssh-agent', 'tzautoupdate', 'uhssvc',
    'UevAgentService'
	)

    # List of services to set to Manual
    $manualServices = @(
    'ALG', 'AppIDSvc', 'AppMgmt', 'AppReadiness', 'AppXSvc', 'Appinfo',
    'AxInstSV', 'BDESVC', 'BITS', 'BTAGService', 'BcastDVRUserService_*',
    'Browser', 'CDPSvc', 'CDPUserSvc_*', 'COMSysApp', 'CaptureService_*',
    'CertPropSvc', 'ClipSVC', 'ConsentUxUserSvc_*', 'CscService', 'DcpSvc',
    'DevQueryBroker', 'DeviceAssociationBrokerSvc_*', 'DeviceAssociationService', 
    'DeviceInstall', 'DevicePickerUserSvc_*', 'DevicesFlowUserSvc_*', 
    'DisplayEnhancementService', 'DmEnrollmentSvc', 'DoSvc', 'DsSvc', 'DsmSvc',
    'EFS', 'EapHost', 'EntAppSvc', 'FDResPub', 'Fax', 'FrameServer',
    'FrameServerMonitor', 'GraphicsPerfSvc', 'HomeGroupListener', 
    'HomeGroupProvider', 'HvHost', 'IEEtwCollectorService', 'IKEEXT',
    'InstallService', 'InventorySvc', 'IpxlatCfgSvc', 'KtmRm', 'LicenseManager',
    'LxpSvc', 'MSDTC', 'MSiSCSI', 'MapsBroker', 'McpManagementService', 
    'MessagingService_*', 'MicrosoftEdgeElevationService', 
    'MixedRealityOpenXRSvc', 'MsKeyboardFilter', 'NPSMSvc_*', 'NaturalAuthentication',
    'NcaSvc', 'NcbService', 'NcdAutoSetup', 'Netman', 'NgcCtnrSvc', 'NgcSvc',
    'NlaSvc', 'P9RdrService_*', 'PNRPAutoReg', 'PNRPsvc', 'PcaSvc', 'PeerDistSvc',
    'PenService_*', 'PerfHost', 'PhoneSvc', 'PimIndexMaintenanceSvc_*', 'PlugPlay',
    'PolicyAgent', 'PrintNotify', 'PrintWorkflowUserSvc_*', 'PushToInstall', 'QWAVE',
    'RasAuto', 'RasMan', 'RetailDemo', 'RmSvc', 'RpcLocator', 'SCPolicySvc',
    'SCardSvr', 'SDRSVC', 'SEMgrSvc', 'SecurityHealthService', 
    'SensorDataService', 'SensorService', 'SensrSvc', 'SessionEnv', 
    'SharedAccess', 'SharedRealitySvc', 'SmsRouter', 'SstpSvc', 
    'StateRepository', 'StiSvc', 'StorSvc', 'TabletInputService', 'TapiSrv',
    'TextInputManagementService', 'TieringEngineService', 'TimeBroker',
    'TimeBrokerSvc', 'TokenBroker', 'TroubleshootingSvc', 'TrustedInstaller',
    'UI0Detect', 'UdkUserSvc_*', 'UmRdpService', 'UnistoreSvc_*', 
    'UserDataSvc_*', 'UsoSvc', 'VSS', 'VacSvc', 'W32Time', 'WEPHOSTSVC',
    'WFDSConMgrSvc', 'WMPNetworkSvc', 'WManSvc', 'WPDBusEnum', 'WSService',
    'WSearch', 'WaaSMedicSvc', 'WalletService', 'WarpJITSvc', 'WbioSrvc',
    'WcsPlugInService', 'WdiServiceHost', 'WdiSystemHost', 'WebClient', 'Wecsvc',
    'WerSvc', 'WiaRpc', 'WinHttpAutoProxySvc', 'WinRM', 'WpcMonSvc', 
    'WpnService', 'WwanSvc', 'XblAuthManager', 'XblGameSave', 'XboxGipSvc', 
    'XboxNetApiSvc', 'autotimesvc', 'bthserv', 'camsvc', 'cbdhsvc_*',
    'cloudidsvc', 'dcsvc', 'defragsvc', 'diagnosticshub.standardcollector.service',
    'diagsvc', 'dmwappushservice', 'dot3svc', 'edgeupdate', 'edgeupdatem', 
    'embeddedmode', 'fdPHost', 'fhsvc', 'hidserv', 'icssvc', 'lfsvc', 
    'lltdsvc', 'lmhosts', 'msiserver', 'netprofm', 'p2pimsvc', 'p2psvc', 
    'perceptionsimulation', 'pla', 'seclogon', 'smphost', 'spectrum', 
    'sppsvc', 'svsvc', 'swprv', 'upnphost', 'vds', 'vm3dservice', 
    'vmicguestinterface', 'vmicheartbeat', 'vmickvpexchange', 'vmicrdv', 
    'vmicshutdown', 'vmictimesync', 'vmicvmsession', 'vmicvss', 'wbengine', 
    'wcncsvc', 'webthreatdefsvc', 'wercplsupport', 'wisvc', 'wlidsvc', 
    'wlpasvc', 'wmiApSrv', 'workfolderssvc', 'wuauserv', 'wudfsvc'
    )

    # Set the services in the disabledServices list to Disabled
    foreach ($service in $disabledServices) {
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
    }

    # Set the services in the manualServices list to Manual
    foreach ($service in $manualServices) {
            Set-Service -Name $service -StartupType Manual -ErrorAction SilentlyContinue | Out-Null
    }
}

function Disable-ScheduledTasks {
    # Define the list of scheduled tasks to disable
    $scheduledTasks = @(
        "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "Microsoft\Windows\Autochk\Proxy",
        "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
        "Microsoft\Windows\Feedback\Siuf\DmClient",
        "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
        "Microsoft\Windows\Windows Error Reporting\QueueReporting",
        "Microsoft\Windows\Application Experience\MareBackup",
        "Microsoft\Windows\Application Experience\StartupAppTask",
        "Microsoft\Windows\Application Experience\PcaPatchDbTask",
        "Microsoft\Windows\Maps\MapsUpdateTask"
    )

    $successCount = 0
    foreach ($task in $scheduledTasks) {
            # Disable the task without wildcards
            schtasks /Change /TN $task /Disable 2>&1 | Out-Null
            $successCount++
    }
}

# End of Tasks and Services Functions

# Start of Power Settings Functions
function Set-RecommendedPowerSettings {
    # Import and set Ultimate power plan
    cmd /c "powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 99999999-9999-9999-9999-999999999999 >nul 2>&1 & powercfg /SETACTIVE 99999999-9999-9999-9999-999999999999 >nul 2>&1"

    # Get all power plans and delete them
    powercfg /L | ForEach-Object {
        if ($_ -match "^\s*Power Scheme GUID: (\S+)") {
            $guid = $matches[1]
            if ($guid -ne "99999999-9999-9999-9999-999999999999") {
                cmd /c "powercfg /delete $guid" | Out-Null
            }
        }
    }

    # Registry modifications
    $regChanges = @(
        'HKLM\SYSTEM\CurrentControlSet\Control\Power /v HibernateEnabled /t REG_DWORD /d 0', # Disables hibernate
        'HKLM\SYSTEM\CurrentControlSet\Control\Power /v HibernateEnabledDefault /t REG_DWORD /d 0', # Disables default hibernate settings
        'HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowLockOption /t REG_DWORD /d 0', # Hides the Lock option from the Power menu
        'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowSleepOption /t REG_DWORD /d 0', # Hides the Sleep option from the Power menu
        'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power /v HiberbootEnabled /t REG_DWORD /d 0', # Disables Fast Startup (Hiberboot)
        'HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583 /v ValueMax /t REG_DWORD /d 0', # Unparks CPU cores by setting the maximum processor state
        'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling /v PowerThrottlingOff /t REG_DWORD /d 1', # Disables power throttling
        'HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683 /v Attributes /t REG_DWORD /d 2', # Unhides "Hub Selective Suspend Timeout"
        'HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009 /v Attributes /t REG_DWORD /d 2' # Unhides "USB 3 Link Power Management"
    )


    foreach ($reg in $regChanges) {
        cmd /c "reg add `$reg` /f >nul 2>&1"
    }

    # Modify Power Plan settings
    $settings = @(
        @{
            SubgroupGUID = "0012ee47-9041-4b5d-9b77-535fba8b1442" # Hard Disk
            SettingGUIDs = @("6738e2c4-e8a5-4a42-b16a-e040e769756e") # Turn off hard disk after
        },
        @{
            SubgroupGUID = "0d7dbae2-4294-402a-ba8e-26777e8488cd" # Desktop Background Settings
            SettingGUIDs = @("309dce9b-bef4-4119-9921-a851fb12f0f4") # Slide show
        },
        @{
            SubgroupGUID = "19cbb8fa-5279-450e-9fac-8a3d5fedd0c1" # Wireless Adapter Settings
            SettingGUIDs = @("12bbebe6-58d6-4636-95bb-3217ef867c1a") # Power saving mode
        },
        @{
            SubgroupGUID = "238c9fa8-0aad-41ed-83f4-97be242c8f20" # Sleep
            SettingGUIDs = @(
                "29f6c1db-86da-48c5-9fdb-f2b67b1f44da", # Sleep after
                "94ac6d29-73ce-41a6-809f-6363ba21b47e", # Allow hybrid sleep
                "9d7815a6-7ee4-497e-8888-515a05f02364", # Hibernate after
                "bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d"  # Allow wake timers
            )
        },
        @{
            SubgroupGUID = "2a737441-1930-4402-8d77-b2bebba308a3" # USB Settings
            SettingGUIDs = @(
                "0853a681-27c8-4100-a2fd-82013e970683", # USB selective suspend setting
                "48e6b7a6-50f5-4782-a5d4-53bb8f07e226", # USB 3 Link Power Management
                "d4e98f31-5ffe-4ce1-be31-1b38b384c009"  # USB Hub Selective Suspend Timeout
            )
        },
        @{
            SubgroupGUID = "501a4d13-42af-4429-9fd1-a8218c268e20" # PCI Express
            SettingGUIDs = @("ee12f906-d277-404b-b6da-e5fa1a576df5") # Link State Power Management
        },
        @{
            SubgroupGUID = "7516b95f-f776-4464-8c53-06167f40cc99" # Display settings
            SettingGUIDs = @("3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e") # Turn off Display After setting
        }
    )


    foreach ($group in $settings) {
        $subgroup = $group.SubgroupGUID
        foreach ($setting in $group.SettingGUIDs) {
            powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 $subgroup $setting 0x00000000
            powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 $subgroup $setting 0x00000000
        }
    }
}

# End of Power Settings Functions

# END OF COMMAND & OPERATION FUNCTIONS

# Bloatware Apps
Get-AppxProvisionedPackage -Online | Where-Object { $appxPackages -contains $_.DisplayName } |
Remove-AppxProvisionedPackage -AllUsers -Online -ErrorAction SilentlyContinue
# Legacy Windows Features & Apps
Get-WindowsCapability -Online | Where-Object { $capabilities -contains ($_.Name -split '~')[0] } |
Remove-WindowsCapability -Online -ErrorAction SilentlyContinue
# Additional Software & Apps
Set-AppsRegistry
Remove-OneDrive
Disable-Recall
# Privacy & Security
Set-RecommendedPrivacySettings
# Optimize Registry
Set-RecommendedHKLMRegistry
Set-RecommendedHKCURegistry
# Tasks and Services
Disable-ScheduledTasks
Set-ServiceStartup
# Power Settings
Set-RecommendedPowerSettings