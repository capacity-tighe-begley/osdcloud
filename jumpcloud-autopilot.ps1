# Starting Transcript
Start-Transcript -OutputDirectory c:\AutoPilot -Verbose -ErrorAction Continue

# Wait for successful network connection 

do {

  $ping = test-connection -comp 8.8.8.8 -count 1 -Quiet

} until ($ping)

# Install Nuget (required version)

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Import PowerShell Management module, which has all the cmdlets for interaction with WMI

Import-Module -Name C:\windows\system32\WindowsPowerShell\v1.0\Modules\Microsoft.PowerShell.Management

# Install and import the JumpCloud Powershell Module

Install-Module -Name JumpCloud -Force

# Connect to your JumpCloud-Tenant by using the API-key ($api)

Connect-JCOnline $api -force

# Download and run the latest JC Agent (using $key)

cd $env:temp | Invoke-Expression; Invoke-RestMethod -Method Get -URI https://raw.githubusercontent.com/TheJumpCloud/support/master/scripts/windows/InstallWindowsAgent.ps1 -OutFile InstallWindowsAgent.ps1 | Invoke-Expression; ./InstallWindowsAgent.ps1 -JumpCloudConnectKey $key

# Acquire SerialNumber 
New-CimSession

$sn = gwmi win32_bios | select -Expand serialnumber

Write-Output "The SerialNumber: $sn has been acquired and will be used to query the JumpCloud System ID."

# Query System ID via JumpCloud PS Module

$sys_id = (Get-JCSystem -serialNumber $sn | select _id)._id

Write-Output "The System ID is $sys_id and will be used to assign this system to the group 'Onboarding'."

# Add this device to the designated default System Group used for 'Onboarding'.

Add-JCSystemGroupMember -GroupName 'Onboarding' -SystemID $sys_id

# Prompt for username to be assigned to the system

$username = Read-Host -Prompt 'Input the username'

Write-Output "The username: $username has been entered and will be assigned to this system."

# Assign the user to the device without being an Administrator

Add-JCSystemUser -Username $username -SystemID $sys_id -Administrator $False

Write-Output "All tasks have been completed successfully. The script will now clean up and announce a restart."

# Delete scheduled task

Unregister-ScheduledTask -TaskName "JumpCloud Auto Pilot" -Confirm:$false


# stop the transcript if still present while debugging

Stop-Transcript


# Cleanup files on C:\

Remove-Item C:\AutoPilot\*.* -Force