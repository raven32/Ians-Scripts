#### Description: Install RSAT via powershell.
###  Written by:  Ian Wright
###  Date:        1/29/19
 

## Vars for script to run 
$WSUSL = "HKLM:\software\Policies\Microsoft\Windows\WindowsUpdate\AU"
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"


function Test-RegistryValue {

param (

 [parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Path,

[parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Value
)

try {

Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
 return $true
 }

catch {

return $false

}

}


Function Disable-WSUS {
if ((Test-RegistryValue -Path $WSUSL "UseWUServer") -eq $true) {Remove-ItemProperty -Path $WSUSL -Name "UseWUServer"} else {Write-Host "WSUS Already dissabled"}

## stoping WSUS Service's
Write-Host "Stopping Windows Update Services..." 
Stop-Service -Name BITS 
Stop-Service -Name wuauserv 
Stop-Service -Name appidsvc 
Stop-Service -Name cryptsvc 

## starting WSUS Service's
 Write-Host "Starting Windows Update Services..." 
Start-Service -Name BITS 
Start-Service -Name wuauserv 
Start-Service -Name appidsvc 
Start-Service -Name cryptsvc 
}
 

Function Enable-WSUS {
if ((Test-RegistryValue -Path $WSUSL "UseWUServer") -eq $False) {New-ItemProperty -Path $WSUSL -Name "UseWUServer" -Value '1' -PropertyType DWORD} else {Write-Host "WSUS Already Enabled"}

## Stoping WSUS Service's
Write-Host "Stopping Windows Update Services..." 
Stop-Service -Name BITS 
Stop-Service -Name wuauserv 
Stop-Service -Name appidsvc 
Stop-Service -Name cryptsvc 

## starting WSUS Service's
 Write-Host "Starting Windows Update Services..." 
Start-Service -Name BITS 
Start-Service -Name wuauserv 
Start-Service -Name appidsvc 
Start-Service -Name cryptsvc 
}


# check if wsus is present and dissable if it is
Disable-WSUS

# Install neded Modules and RSAT Toosl
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

# updated existing modules already installed on windows.
update-module


# re-enable WSUS After everything else is done.
Enable-WSUS





