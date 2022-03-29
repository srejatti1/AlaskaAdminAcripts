# DEVELOPER -- SHANTAN POLEPALLY
# EMAIL -- SHANTAN.POLEPALLY@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
#1. Bounce EAI Component
try
	{
		$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
		[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
        $FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
		$ScriptName = "EAIBounce_"
		$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
		$Gateway = $ConfigFile.Settings.Siebel.Gateway
		$Enterprise = $ConfigFile.Settings.Siebel.Enterprise
		$AdminUser  = $ConfigFile.Settings.Siebel.AdminUser
		$AdminPassword=$ConfigFile.Settings.Siebel.AdminPassword
		Start-Transcript -Path $ScriptLogPath\$ScriptName$FldrNameTime.txt
		Set-Location -Path "D:\sea\ses\siebsrvr\BIN"
		.\srvrmgr.exe /g $Gateway /e $Enterprise /u $AdminUser /p $AdminPassword /i "D:\FTPRoot\Rollouts\BatchScripts\PowerShell_Files\restart_eai.txt" 
    	Set-Location -Path "D:\FTPRoot\Rollouts\BatchScripts\PowerShell_Files"
		Write-Output "COMPLETED EXECUTING EAIBounce.PS1"			
	}
Catch
	{
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Write-Output "EXCEPTION RUNNING EAIBounce.ps1" "ERROR MESSAGE: $ErrorMessage ` FAILEDITEM: $FailedItem `n"
	}
finally
	{
	Clear-Variable FldrNameTime
	Clear-Variable ScriptName
	Clear-Variable ScriptLogPath
	Clear-Variable Gateway
	Clear-Variable Enterprise
	Clear-Variable AdminUser
	Clear-Variable AdminPassword
	Stop-Transcript
	}