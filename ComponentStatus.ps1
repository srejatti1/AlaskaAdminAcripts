# DEVELOPER -- SHANTAN POLEPALLY
# EMAIL -- SHANTAN.POLEPALLY@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
#1. CHECK COMPONENT STATUS
#2. EMAIL ADMIN TEAM IF COMPONENTS ARE OFFLINE
try
	{
	
		$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
		# Load config file
		[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
		$MailFrom = $ConfigFile.Settings.Email.MailFrom
		$MailTo = $ConfigFile.Settings.Email.MailTo
		$SMTPServer = $ConfigFile.Settings.Email.SMTPServer
		$Attachment = "D:\FTPRoot\Rollouts\ScriptLogs\compstatus1.txt"
		$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
		$ScriptName = "ComponentStatus_"
		$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
		$Gateway = $ConfigFile.Settings.Siebel.Gateway
		$Enterprise = $ConfigFile.Settings.Siebel.Enterprise
		$AdminUser  = $ConfigFile.Settings.Siebel.AdminUser
		$AdminPassword=$ConfigFile.Settings.Siebel.AdminPassword
		Start-Transcript -Path $ScriptLogPath\$ScriptName$FldrNameTime.txt
		Set-Location -Path "D:\sea\ses\siebsrvr\BIN"
		.\srvrmgr.exe -g $Gateway -e $Enterprise -u $AdminUser -p $AdminPassword -o "D:\FTPRoot\Rollouts\ScriptLogs\compstatus.txt" -c 'list comp show SV_NAME, CC_NAME,CC_ALIAS, CP_DISP_RUN_STATE, CP_STARTMODE, CP_START_TIME'
		Set-Location -Path "D:\FTPRoot\Rollouts\BatchScripts\PowerShell_Files"
		get-content "D:\FTPRoot\Rollouts\ScriptLogs\compstatus.txt" | select -skip 26| Out-File -FilePath "D:\FTPRoot\Rollouts\ScriptLogs\compstatus1.txt" 
		Remove-Item "D:\FTPRoot\Rollouts\ScriptLogs\compstatus.txt"
		if(Select-String -Path D:\FTPRoot\Rollouts\ScriptLogs\compstatus1.txt -Pattern "Not Online")
		{
			Write-Output "Some Components are offline"
			Send-MailMessage  -From $MailFrom -To $MailTo -Subject "Component Status Offline" -Body "Some Components are offline" -SmtpServer $SMTPServer -Attachments $Attachment
			
		}
		else
		{
			Write-Output "All Components are online"
			
		}
		Remove-Item "D:\FTPRoot\Rollouts\ScriptLogs\compstatus1.txt"
		Write-Output "COMPLETED EXECUTING ComponentStatus.PS1"
			
	}


# used to catch any exception and occured in try block and send an email to the admin
Catch
	{
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Write-Output "EXCEPTION RUNNING ComponentStatus.ps1" "ERROR MESSAGE: $ErrorMessage ` FAILEDITEM: $FailedItem `n"
	
	}

finally
	{
	Clear-Variable MailFrom  
	Clear-Variable MailTo 
	Clear-Variable SMTPServer 
	Clear-Variable FldrNameTime
	Clear-Variable ScriptName
	Clear-Variable Gateway
	Clear-Variable Enterprise
	Clear-Variable AdminUser
	Clear-Variable AdminPassword
	Clear-Variable Attachment
	Stop-Transcript
	}

