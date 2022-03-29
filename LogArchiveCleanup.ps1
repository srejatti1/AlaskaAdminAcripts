# DEVELOPER -- VASU
# EMAIL -VASUDEVA.YERRAGURAVAGARI@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
# 1. TO Delete log archives
# Shantan 06/18/2021 Updated code

try
{
	
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# LOAD CONFIG FILE
$configuration = $Args[0];
[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
$ScriptName = "LOGARCHIVECLEANUP_"
$Env = $ConfigFile.Settings.Siebel.Env
$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
$LogarchivePath = $ConfigFile.Settings.Siebel.LogarchivePath
$LogCleanupDuration =[int]$ConfigFile.Settings.Siebel.LogCleanupDuration
$Limit = (Get-Date).AddDays(-$LogCleanupDuration)
$HostCompName = $env:computername
Start-Transcript -Path $ScriptLogPath\$ScriptName$FldrNameTime.txt

Write-Output "Remove  logarchive folders in $HostCompName at $LogarchivePath older than $LogCleanupDuration days" 

# Delete files older than the $Limit.

$folders = Get-ChildItem -Path $LogarchivePath -Recurse -Directory | Where-Object {$_.lastwritetime -lt $Limit}
Write-Output "Old Folders than $LogCleanupDuration days are $folders  "
# Delete any empty directories left behind after deleting the old files.
Get-ChildItem -Path $LogarchivePath -Recurse -Directory | Where-Object {$_.lastwritetime -lt $Limit} | Remove-Item -Recurse -Force
#Get-ChildItem -Path $LogarchivePath -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse

Write-Host "COMPLETED EXECUTING LOGARCHIVECLEANUP.PS1"

}
# USED TO CATCH ANY EXCEPTION AND OCCURED IN TRY BLOCK AND SEND AN EMAIL TO THE ADMIN
Catch
	{
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Write-Output "EXCEPTION RUNNING BRINGSYSTEMDOWN.ps1" "ERROR MESSAGE: $ErrorMessage `n FAILEDITEM: $FailedItem `n"
		#Send-Email-Attachment "$Env : EXCEPTION RUNNING BRINGSYSTEMDOWN.PS1" "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
	}
finally{
 Clear-Variable LogarchivePath  
 Clear-Variable ScriptLogPath 
 Clear-Variable LogCleanupDuration
 Clear-Variable FldrNameTime
 Clear-Variable ScriptName
 Clear-Variable Limit
 Clear-Variable Env
 Clear-Variable HostCompName
 Clear-Variable folders
 Stop-Transcript
 
}