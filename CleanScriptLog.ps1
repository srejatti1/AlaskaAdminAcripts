# DEVELOPER -- Shantan Polepally
# EMAIL -SHANTAN.POLEPALLY@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
# 1. To Delete scriptlog files


try
{
	
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# LOAD CONFIG FILE
$configuration = $Args[0];
[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
$ScriptName = "CLEANSCRIPTLOG_"
$Env = $ConfigFile.Settings.Siebel.Env
$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
$ScriptLogDuration =[int]$ConfigFile.Settings.Siebel.ScriptLogDuration
$Limit = (Get-Date).AddDays(-$ScriptLogDuration)
$HostCompName = $env:computername
Start-Transcript -Path $ScriptLogPath\$ScriptName$FldrNameTime.txt

Write-Output "Remove  files in  $ScriptLogPath older than $ScriptLogDuration days" 

# Delete files older than the $Limit.

$files = Get-ChildItem $ScriptLogPath -Recurse | Where-Object { $_.LastWriteTime -lt $Limit } 

Write-Output "Files cleaned are: $files  "
#Get-ChildItem $ScriptLogPath -Recurse | Where-Object { $_.LastWriteTime -lt $Limit } | Remove-Item

Write-Host "COMPLETED EXECUTING LOGARCHIVECLEANUP.PS1"

}
# USED TO CATCH ANY EXCEPTION AND OCCURED IN TRY BLOCK AND SEND AN EMAIL TO THE ADMIN
Catch
	{
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Write-Output "EXCEPTION RUNNING CLEANSCRIPTLOG.ps1" "ERROR MESSAGE: $ErrorMessage `n FAILEDITEM: $FailedItem `n"
		#Send-Email-Attachment "$Env : EXCEPTION RUNNING CLEANSCRIPTLOG.PS1" "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
	}
finally{
 Clear-Variable ScriptLogPath 
 Clear-Variable ScriptLogDuration
 Clear-Variable FldrNameTime
 Clear-Variable ScriptName
 Clear-Variable Limit
 Clear-Variable Env
 Clear-Variable HostCompName
 Clear-Variable files
 Stop-Transcript
 
}