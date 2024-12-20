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

Start-Process @execute_sysprep

exit 0