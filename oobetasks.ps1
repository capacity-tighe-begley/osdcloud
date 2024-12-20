# oobetasks.osdcloud.ch

$scriptFolderPath = "$env:SystemDrive\OSDCloud\Scripts"
$ScriptPathOOBE = $(Join-Path -Path $scriptFolderPath -ChildPath "OOBE.ps1")
$ScriptPathSendKeys = $(Join-Path -Path $scriptFolderPath -ChildPath "SendKeys.ps1")

If(!(Test-Path -Path $scriptFolderPath)) {
    New-Item -Path $scriptFolderPath -ItemType Directory -Force | Out-Null
}

@"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
  <!-- UnattendedWinstall https://github.com/memstechtips/UnattendedWinstall -->
  <settings pass="offlineServicing"></settings>
  <settings pass="windowsPE">
    <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
		<SetupUILanguage>
			<UILanguage>en-US</UILanguage>
		</SetupUILanguage>
		<InputLocale>0409:00000409</InputLocale>
		<SystemLocale>en-US</SystemLocale>
		<UILanguage>en-US</UILanguage>
		<UserLocale>en-US</UserLocale>
	</component>
    <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
			<ImageInstall>
				<OSImage>
					<InstallTo>
						<DiskID>0</DiskID>
						<PartitionID>3</PartitionID>
					</InstallTo>
				</OSImage>
			</ImageInstall>
			<UserData>
				<ProductKey>
					<Key>VK7JG-NPHTM-C97JM-9MPGT-3V66T</Key>
				</ProductKey>
				<AcceptEula>true</AcceptEula>
			</UserData>
			<UseConfigurationSet>false</UseConfigurationSet>
			<RunSynchronous>
				<RunSynchronousCommand wcm:action="add">
					<Order>1</Order>
					<Path>cmd.exe /c "&gt;&gt;"X:\diskpart.txt" (echo SELECT DISK=0&amp;echo CLEAN&amp;echo CONVERT GPT&amp;echo CREATE PARTITION EFI SIZE=300&amp;echo FORMAT QUICK FS=FAT32 LABEL="System"&amp;echo CREATE PARTITION MSR SIZE=16)"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>2</Order>
					<Path>cmd.exe /c "&gt;&gt;"X:\diskpart.txt" (echo CREATE PARTITION PRIMARY&amp;echo SHRINK MINIMUM=1024&amp;echo FORMAT QUICK FS=NTFS LABEL="Windows"&amp;echo CREATE PARTITION PRIMARY&amp;echo FORMAT QUICK FS=NTFS LABEL="Recovery")"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>3</Order>
					<Path>cmd.exe /c "&gt;&gt;"X:\diskpart.txt" (echo SET ID="de94bba4-06d1-4d40-a16a-bfd50179d6ac"&amp;echo GPT ATTRIBUTES=0x8000000000000001)"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>4</Order>
					<Path>cmd.exe /c "diskpart.exe /s "X:\diskpart.txt" &gt;&gt;"X:\diskpart.log" || ( type "X:\diskpart.log" &amp; echo diskpart encountered an error. &amp; pause &amp; exit /b 1 )"</Path>
				</RunSynchronousCommand>
			</RunSynchronous>
	</component>
  </settings>
  <settings pass="generalize"></settings>
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
        <CommandLine>powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "cd $env:temp | Invoke-Expression; Invoke-RestMethod -Method Get -URI https://raw.githubusercontent.com/capacity-tighe-begley/osdcloud/refs/heads/main/OOBE-removebloatware.ps1"</CommandLine>
        </SynchronousCommand>
        # <SynchronousCommand>
        # <!-- Install JumpCloud Agent -->
        # <Order>3</Order>
        # <CommandLine>powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "cd $env:temp | Invoke-Expression; Invoke-RestMethod -Method Get -URI https://raw.githubusercontent.com/TheJumpCloud/support/master/scripts/windows/InstallWindowsAgent.ps1 -OutFile InstallWindowsAgent.ps1 | Invoke-Expression; ./InstallWindowsAgent.ps1 -JumpCloudConnectKey "89637cc425cced127c0a316e5df3503a676a4389""</CommandLine>
        # </SynchronousCommand>
        <SynchronousCommand>
        <!-- Restart Computer -->
        <Order>4</Order>
        <CommandLine>powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "Restart-Computer"</CommandLine>
        </SynchronousCommand>
    </FirstLogonCommands>
    </component>
  </settings>
  <Extensions>
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

$OOBEScript =@"
`$Global:Transcript = "`$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OOBEScripts.log"
Start-Transcript -Path (Join-Path "`$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" `$Global:Transcript) -ErrorAction Ignore | Out-Null

#Add Local Administrator User 'capacity-deploy'
Start-Process Powershell -ArgumentList "-NoL -C New-LocalUser 'capacity-deploy' -NoPassword | Add-LocalGroupMember 'Administrators' -Member 'capacity-deploy'" -Wait

Write-Host -ForegroundColor DarkGray "Installing OSD PS Module"
Start-Process PowerShell -ArgumentList "-NoL -C Install-Module OSD -Force -Verbose" -Wait

# Write-Host -ForegroundColor DarkGray "Executing Keyboard Language Skript"
# Start-Process PowerShell -ArgumentList "-NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/capacity-tighe-begley/osdcloud/refs/heads/main/Set-KeyboardLanguage.ps1" -Wait

# Write-Host -ForegroundColor DarkGray "Executing Product Key Script"
# Start-Process PowerShell -ArgumentList "-NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/capacity-tighe-begley/osdcloud/refs/heads/main/Install-EmbeddedProductKey.ps1" -Wait

Write-Host -ForegroundColor DarkGray "Executing OOBEDeploy Script fomr OSDCloud Module"
Start-Process PowerShell -ArgumentList "-NoL -C Start-OOBEDeploy" -Wait

Write-Host -ForegroundColor DarkGray "Executing Cleanup Script"
Start-Process PowerShell -ArgumentList "-NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/capacity-tighe-begley/osdcloud/refs/heads/main/cleanup.ps1" -Wait

# Cleanup scheduled Tasks
Write-Host -ForegroundColor DarkGray "Unregistering Scheduled Tasks"
Unregister-ScheduledTask -TaskName "Scheduled Task for SendKeys" -Confirm:`$false
Unregister-ScheduledTask -TaskName "Scheduled Task for OSDCloud post installation" -Confirm:`$false

Write-Host -ForegroundColor DarkGray "Restarting Computer"
Start-Process PowerShell -ArgumentList "-NoL -C Restart-Computer -Force" -Wait

Stop-Transcript -Verbose | Out-File
"@

Out-File -FilePath $ScriptPathOOBE -InputObject $OOBEScript -Encoding ascii

$SendKeysScript = @"
`$Global:Transcript = "`$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-SendKeys.log"
Start-Transcript -Path (Join-Path "`$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" `$Global:Transcript) -ErrorAction Ignore | Out-Null

Write-Host -ForegroundColor DarkGray "Stop Debug-Mode (SHIFT + F10) with WscriptShell.SendKeys"
`$WscriptShell = New-Object -com Wscript.Shell

# ALT + TAB
Write-Host -ForegroundColor DarkGray "SendKeys: ALT + TAB"
`$WscriptShell.SendKeys("%({TAB})")

Start-Sleep -Seconds 1

# Shift + F10
Write-Host -ForegroundColor DarkGray "SendKeys: SHIFT + F10"
`$WscriptShell.SendKeys("+({F10})")

Stop-Transcript -Verbose | Out-File
"@

Out-File -FilePath $ScriptPathSendKeys -InputObject $SendKeysScript -Encoding ascii

# Download ServiceUI.exe
Write-Host -ForegroundColor Gray "Download ServiceUI.exe from GitHub Repo"
Invoke-WebRequest https://github.com/AkosBakos/Tools/raw/main/ServiceUI64.exe -OutFile "C:\OSDCloud\ServiceUI.exe"

#Create Scheduled Task for SendKeys with 5 seconds delay
$TaskName = "Scheduled Task for SendKeys"

$ShedService = New-Object -comobject 'Schedule.Service'
$ShedService.Connect()

$Task = $ShedService.NewTask(0)
$Task.RegistrationInfo.Description = $taskName
$Task.Settings.Enabled = $true
$Task.Settings.AllowDemandStart = $true

# https://msdn.microsoft.com/en-us/library/windows/desktop/aa383987(v=vs.85).aspx
$trigger = $task.triggers.Create(9) # 0 EventTrigger, 1 TimeTrigger, 2 DailyTrigger, 3 WeeklyTrigger, 4 MonthlyTrigger, 5 MonthlyDOWTrigger, 6 IdleTrigger, 7 RegistrationTrigger, 8 BootTrigger, 9 LogonTrigger
$trigger.Delay = 'PT5S'
$trigger.Enabled = $true

$action = $Task.Actions.Create(0)
$action.Path = 'C:\OSDCloud\ServiceUI.exe'
$action.Arguments = '-process:RuntimeBroker.exe C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe ' + $ScriptPathSendKeys + ' -NoExit'

$taskFolder = $ShedService.GetFolder("\")
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa382577(v=vs.85).aspx
$taskFolder.RegisterTaskDefinition($TaskName, $Task , 6, "SYSTEM", $NULL, 5)

#Create Scheduled Task for OOBEautounattend with 5 seconds delay
$TaskName = "Scheduled Task for OOBEautounattend"

$ShedService = New-Object -comobject 'Schedule.Service'
$ShedService.Connect()

$Task = $ShedService.NewTask(0)
$Task.RegistrationInfo.Description = $taskName
$Task.Settings.Enabled = $true
$Task.Settings.AllowDemandStart = $true

# https://msdn.microsoft.com/en-us/library/windows/desktop/aa383987(v=vs.85).aspx
$trigger = $task.triggers.Create(9) # 0 EventTrigger, 1 TimeTrigger, 2 DailyTrigger, 3 WeeklyTrigger, 4 MonthlyTrigger, 5 MonthlyDOWTrigger, 6 IdleTrigger, 7 RegistrationTrigger, 8 BootTrigger, 9 LogonTrigger
$trigger.Delay = 'PT5S'
$trigger.Enabled = $true

$action = $Task.Actions.Create(0)
$action.Path = 'C:\OSDCloud\ServiceUI.exe'
$action.Arguments = '-process:RuntimeBroker.exe C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe ' + 'Start-Process @execute_sysprep ' + ' -NoExit'

$taskFolder = $ShedService.GetFolder("\")
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa382577(v=vs.85).aspx
$taskFolder.RegisterTaskDefinition($TaskName, $Task , 6, "SYSTEM", $NULL, 5)

# Create Scheduled Task for OSDCloud post installation with 20 seconds delay
$TaskName = "Scheduled Task for OSDCloud post installation"

$ShedService = New-Object -comobject 'Schedule.Service'
$ShedService.Connect()

$Task = $ShedService.NewTask(0)
$Task.RegistrationInfo.Description = $taskName
$Task.Settings.Enabled = $true
$Task.Settings.AllowDemandStart = $true

# https://msdn.microsoft.com/en-us/library/windows/desktop/aa383987(v=vs.85).aspx
$trigger = $task.triggers.Create(9) # 0 EventTrigger, 1 TimeTrigger, 2 DailyTrigger, 3 WeeklyTrigger, 4 MonthlyTrigger, 5 MonthlyDOWTrigger, 6 IdleTrigger, 7 RegistrationTrigger, 8 BootTrigger, 9 LogonTrigger
$trigger.Delay = 'PT20S'
$trigger.Enabled = $true

$action = $Task.Actions.Create(0)
$action.Path = 'C:\OSDCloud\ServiceUI.exe'
$action.Arguments = '-process:RuntimeBroker.exe C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe ' + $ScriptPathOOBE + ' -NoExit'

$taskFolder = $ShedService.GetFolder("\")
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa382577(v=vs.85).aspx
$taskFolder.RegisterTaskDefinition($TaskName, $Task , 6, "SYSTEM", $NULL, 5)