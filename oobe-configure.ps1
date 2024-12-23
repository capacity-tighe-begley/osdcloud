@"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
<settings pass="specialize">
    <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <RunSynchronous>
        <RunSynchronousCommand wcm:action="add">
          <Order>1</Order>
          <!-- Loads Scripts in File -->
          <Path>powershell.exe -NoProfile -WindowStyle Hidden -Command "$xml = [xml]::new(); $xml.Load('C:\Windows\Panther\unattend.xml'); $sb = [scriptblock]::Create( $xml.unattend.Extensions.ExtractScript ); Invoke-Command -ScriptBlock $sb -ArgumentList $xml;"</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>2</Order>
          <!-- Disables User Account Control -->
          <Path>reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>3</Order>
          <!-- Enables Running of PowerShell Scripts -->
          <Path>powershell.exe -NoProfile -WindowStyle Hidden -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>4</Order>
          <!-- Skips Forced Microsoft Account Creation -->
          <Path>reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v BypassNRO /t REG_DWORD /d 1 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>5</Order>
          <!-- Runs Script to Enable .NET3.5 from Windows Installation Media -->
          <Path>powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Windows\Temp\DotNet.ps1"</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>6</Order>
          <!-- Creates Specialize Phase Marker File -->
          <Path>cmd.exe /c echo Specialized Setup > "C:\specialize_marker.txt"</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>7</Order>
          <!-- Runs Recommended UnattendedWinstall Scripts -->
          <Path>powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Windows\Setup\Scripts\UWScript.ps1"</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>9</Order>
          <!-- Loads Default User Registry Hive to Make Changes to it -->
          <Path>reg.exe load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>10</Order>
          <!-- Add Registry Key to Run User Account Customization Script -->
          <Path>reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Runonce" /v "CurrentUser" /t REG_SZ /d "cmd.exe /c powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \"C:\Users\Default\User Customization.ps1\"" /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>11</Order>
          <!-- Unloads Default User Registry Hive. -->
          <Path>reg.exe unload "HKU\DefaultUser"</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <!-- Cleanup temporary .ps1 and .reg scripts inside C:\Windows\Temp -->
          <Order>12</Order>
          <Path>cmd /c del /f /q "C:\Windows\Temp\*.ps1" "C:\Windows\Temp\*.reg"</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>13</Order>
          <!-- Deletes Specialize Phase Marker File -->
          <Path>cmd.exe /c del /q "C:\specialize_marker.txt"</Path>
        </RunSynchronousCommand>
      </RunSynchronous>
    </component>
  </settings>
  <settings pass="auditSystem"></settings>
  <settings pass="auditUser"></settings>
  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
			<InputLocale>0409:00000409</InputLocale>
			<SystemLocale>en-US</SystemLocale>
			<UILanguage>en-US</UILanguage>
			<UserLocale>en-US</UserLocale>
	</component>
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
        <UserAccounts>
				<AdministratorPassword>
					<Value>Capacity2024!</Value>
					<PlainText>true</PlainText>
				</AdministratorPassword>
	    </UserAccounts>
			<AutoLogon>
				<Username>Administrator</Username>
				<Enabled>true</Enabled>
				<LogonCount>1</LogonCount>
				<Password>
					<Value>Capacity2024!</Value>
					<PlainText>true</PlainText>
				</Password>
			</AutoLogon>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
        <HideWirelessSetupInOOBE>false</HideWirelessSetupInOOBE>
        <NetworkLocation>Work</NetworkLocation>
        <ProtectYourPC>3</ProtectYourPC>
      </OOBE>
      <FirstLogonCommands>
        <SynchronousCommand>
        <!-- Enables Network Adapters After OOBE Completes -->
        <Order>1</Order>
        <CommandLine>powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "Get-NetAdapter | Enable-NetAdapter -Confirm:$false"</CommandLine>
        </SynchronousCommand>
        <SynchronousCommand>
        <!-- Install JumpCloud Agent -->
        <Order>2</Order>
        <CommandLine>powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "cd $env:temp | Invoke-Expression; Invoke-RestMethod -Method Get -URI https://raw.githubusercontent.com/TheJumpCloud/support/master/scripts/windows/InstallWindowsAgent.ps1 -OutFile InstallWindowsAgent.ps1 | Invoke-Expression; ./InstallWindowsAgent.ps1 -JumpCloudConnectKey "89637cc425cced127c0a316e5df3503a676a4389""</CommandLine>
        </SynchronousCommand>
        <SynchronousCommand>
        <!-- Restart Computer -->
        <Order>3</Order>
        <CommandLine>powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "Restart-Computer"</CommandLine>
        </SynchronousCommand>
    </FirstLogonCommands>
    </component>
  </settings>
<Extensions>
  <ExtractScript>
param(
    [xml] $Document
);

$scriptsDir = 'C:\Windows\Setup\Scripts\';
foreach( $file in $Document.unattend.Extensions.File ) {
    $path = [System.Environment]::ExpandEnvironmentVariables(
        $file.GetAttribute( 'path' )
    );
    if( $path.StartsWith( $scriptsDir ) ) {
        mkdir -Path $scriptsDir -ErrorAction 'SilentlyContinue';
    }
    $encoding = switch( [System.IO.Path]::GetExtension( $path ) ) {
        { $_ -in '.ps1', '.xml' } { [System.Text.Encoding]::UTF8; }
        { $_ -in '.reg', '.vbs', '.js' } { [System.Text.UnicodeEncoding]::new( $false, $true ); }
        default { [System.Text.Encoding]::Default; }
    };
    [System.IO.File]::WriteAllBytes( $path, ( $encoding.GetPreamble() + $encoding.GetBytes( $file.InnerText.Trim() ) ) );
}
  </ExtractScript>
  
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
    'MathRecognizer', 'OpenSSH.Client',
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
    Show-Header
    Write-Host "Are You Sure You Want to Remove ALL Windows Apps? (Y/N)" -ForegroundColor Black -Backgroundcolor Yellow
    Write-Host "Includes: OneDrive, Teams, Outlook for Windows and more . . ." -ForegroundColor Black -Backgroundcolor Yellow
    Write-Host "(CAUTION! Can't be Undone!)" -BackgroundColor Red
    $confirmation = Read-Host "Enter your choice"

    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        Show-Header
        Write-Host "Removing Pre-installed Apps and Features. Please wait . . ."
        # Bloatware Apps
        Get-AppxPackage -AllUsers |
        Where-Object { $appxPackages -contains $_.Name } |
        Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Out-Null
        # Legacy Windows Features & Apps
        Get-WindowsCapability -Online |
        Where-Object { $capabilities -contains ($_.Name -split '~')[0] } |
        Remove-WindowsCapability -Online -ErrorAction SilentlyContinue | Out-Null
        # Calls specified functions
        Show-Header
        Set-AppsRegistry
        Uninstall-OneDrive
        Show-Header
        Disable-Recall
        Show-Header
        Write-Host "Pre-installed Apps and Features removed successfully." -BackgroundColor Green
        Wait-IfNotSpecialize
    }
    else {
        Show-MainMenu
    }
}
# End of Software & Apps Functions

# Start of Privacy & Security Functions
# Function to Apply the Recommended Privacy Settings
function Set-RecommendedPrivacySettings {  
        if (-not $isSpecializePhase) {
            Show-Header
            Write-Host "Applying Recommended Privacy Settings . . ."
        }

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

        if (-not $isSpecializePhase) {
            Show-Header
            Write-Host "Recommended Privacy Settings Applied." -ForegroundColor Green
            Wait-IfNotSpecialize
        }
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
        Show-Header
        Write-Host "Recommended Local Machine Registry Settings Applied." -ForegroundColor Green
        Wait-IfNotSpecialize
    }

function Set-RecommendedHKCURegistry {
        Clear-Host
        Write-Host "Optimizing User Registry . . ."

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
        Show-Header
        Write-Host "Recommended User Registry Settings Applied." -ForegroundColor Green
        Wait-IfNotSpecialize
    }

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
        try {
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
        }
        catch {
            Show-Header
            Write-Host "Failed to set $service to Disabled: $_" -ForegroundColor Yellow
            Wait-IfNotSpecialize
        }
    }

    # Set the services in the manualServices list to Manual
    foreach ($service in $manualServices) {
        try {
            Set-Service -Name $service -StartupType Manual -ErrorAction SilentlyContinue | Out-Null
        }
        catch {
            Show-Header
            Write-Host "Failed to set $service to Manual: $_" -ForegroundColor Yellow
            Wait-IfNotSpecialize
        }
    }

    Show-Header
    Write-Host "Service startup types updated successfully." -ForegroundColor Green
    Wait-IfNotSpecialize
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
        try {
            # Disable the task without wildcards
            schtasks /Change /TN $task /Disable 2>&1 | Out-Null
            $successCount++
        }
        catch {
            # Silently continue if a task fails
            continue
        }
    }
    
    Show-Header
    Write-Host "Successfully disabled unneeded scheduled tasks." -ForegroundColor Green
    Wait-IfNotSpecialize
}

# Check if this is running in the specialize phase to Apply Settings automatically during Windows Installation
if (Test-Path -Path $markerFilePath) {
    # Bloatware Apps
    Get-AppxProvisionedPackage -Online |
    Where-Object { $appxPackages -contains $_.DisplayName } |
    Remove-AppxProvisionedPackage -AllUsers -Online -ErrorAction SilentlyContinue
    # Legacy Windows Features & Apps
    Get-WindowsCapability -Online |
    Where-Object { $capabilities -contains ($_.Name -split '~')[0] } |
    Remove-WindowsCapability -Online -ErrorAction SilentlyContinue
    # Additional Software & Apps
    Set-AppsRegistry
    Remove-OneDrive
    Disable-Recall
    # Privacy & Security
    Set-RecommendedPrivacySettings
    # Windows Updates
    Set-RecommendedUpdateSettings
    # Optimize Registry
    Set-RecommendedHKLMRegistry
    # Tasks and Services
    Disable-ScheduledTasks
    Set-ServiceStartup
    # Power Settings
    Set-RecommendedPowerSettings
    exit
}

Start-Process -FilePath "shutdown.exe" -ArgumentList "/r /t 1" -NoNewWindow
    ]]>
    </File>
    <!--Start Menu Template (Credit:https://schneegans.de/windows/unattend-generator/)-->
    <File path="C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml">
      <![CDATA[
<LayoutModificationTemplate Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
	<LayoutOptions StartTileGroupCellWidth="6" />
	<DefaultLayoutOverride>
		<StartLayoutCollection>
			<StartLayout GroupCellWidth="6" xmlns="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" />
		</StartLayoutCollection>
	</DefaultLayoutOverride>
</LayoutModificationTemplate>
		]]>
    </File>
  </Extensions>
</unattend>


"@ | Out-File "$($env:windir)\temp\unattend.xml" -Encoding utf8

# Execute sysprep to apply new OOBE setup settings
$execute_sysprep = @{
    FilePath     = "$($env:windir)\System32\Sysprep\sysprep.exe"
    ArgumentList = "/oobe", "/quit", "/unattend:$($env:windir)\temp\unattend.xml"
    PassThru     = $true
    Wait         = $true
}

Start-Process @execute_sysprep

exit 0