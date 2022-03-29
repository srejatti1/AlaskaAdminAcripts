# DEVELOPER -- Shyam Sundar
# EMAIL -- SHYAM.SUNDAR@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
# 1. STOP THE WEBSERVICES
# 2. STOP THE SIEBEL SERVICES
# 3. STOP THE GATEWAY SERVICE
# 4. STOP THE SYNC SERVICES
# Shantan 06/09/2021 Updated Script to change stop services sequence
try
	{
	cls
		$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
		# LOAD CONFIG FILE
		$configuration = $Args[0]
		[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
		Import-Module -Force "$MyDir\RepMigrMod.psm1" -DisableNameChecking
		$SEASiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
		$TUKSiebSrvrName = $ConfigFile.Settings.TUK.SiebSrvrName
		$HostCompName = $env:computername

			Write-Output "BRING DOWN THE SERVICES ON Dev"
			$global:SiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
			$global:WebSrvrName = $ConfigFile.Settings.Siebel.WebSrvrName
			$global:NoOfSiebSrvrs = $ConfigFile.Settings.Siebel.NoOfSiebSrvrs
			$global:SvcName = $ConfigFile.Settings.Siebel.SvcName
			$global:NoOfWebSrvrs = $ConfigFile.Settings.Siebel.NoOfWebSrvrs
			$global:SiebSrvrNumber = $ConfigFile.Settings.Siebel.SiebSrvrNumber
			$Env = $ConfigFile.Settings.Siebel.Env
			$Gateway = $ConfigFile.Settings.Siebel.Gateway
			$SyncServ  = $ConfigFile.Settings.Siebel.SyncServ
		
			$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
			$ScriptName = "BRINGSYSTEMDOWN_"
			$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
			$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
			$global:MailTo = $ConfigFile.Settings.Email.MailTo
			$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
		
		Start-Transcript $ScriptLogPath\$ScriptName$FldrNameTime.txt
		
		
		#THIS FUNCTION IS USED TO STOP THE SIEBEL SERVER SERVICES
		Write-Output "STOPPING THE SIEBEL SERVICES"
		stopSiebelServices
		
		Write-Output "WAITING FOR SIEBEL SERVICES TO BE STOPPED AND WILL WAIT FOR UPTO 60 SECONDS"
		Write-Output "SCRIPT WILL CONTINUE ONCE THE SIEEBL SERVICES ARE STOPPED"
		Start-Sleep 60
		
		$TestTime = 30
		$NoOfTries = 1..10
		foreach($i in $NoOfTries)
		{
			Write-Output "SIEBEL IS NOT DOWN YET, SLEEP FOR 30 SECONDS"
			Start-Sleep $TestTime
			validateSiebelServices "Stopped"
			if($global:ServiceValidation -eq "True")
			{
				break
			}
		}
		
		# VERIFY ALL SIEBEL SERVERS ARE DOWN
		Write-Output "CHECKING IF ALL THE SIEBEL SERVICES ARE DOWN?"
		if($global:ServiceValidation -eq "False")
		{
			Write-Output "TERMINATED EXECUTION OF BRINGSYSTEMDOWN.PS1 AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
			Send-Email-Attachment "$Env : ERROR EXECUTING BRINGSYSTEMDOWN.PS1" "ALL THE SIEBEL SERVERS ARE NOT DOWN `nPLEASE ANALYZE THE ATTACHED LOG FILE." "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
			exit
		}
		elseif($global:ServiceValidation -eq "True")
		{
			Write-Output "ALL THE SIEBEL SERVICES ARE NOW STOPPED"
		}
		
	
		
		# THIS FUNCTION CHECKS THE STATUS OF TOMCAT SES SERVICE AND STOPS THEM IF THEY ARE IN RUNNING STATE
		Write-Output "STOPPING THE TOMCAT SES SERVICES"
		stopSESServices
		
		Write-Output "SLEEP FOR 30 SECONDS"
		Start-Sleep 30
		
		$TestTime = 30
		$NoOfTries = 1..10
		foreach($i in $NoOfTries)
		{
			Write-Output "SIEBEL IS NOT DOWN YET, SLEEP FOR 30 SECONDS"
			Start-Sleep $TestTime
			validateSESServices "Stopped"
			if($global:ServiceValidation -eq "True")
			{
				break
			}
		
		# VALIDATE IF ALL THE TOMCAT SES SERVICES ARE DOWN
		validateSESServices "Stopped"
		if($global:ServiceValidation -eq "False")
		{
			Send-Email-Attachment "$Env : ERROR EXECUTING BRINGSYSTEMDOWN.PS1" "ALL THE TOMCAT SES SERVICES ARE NOT DOWN `nPLEASE ANALYZE THE ATTACHED LOG FILE." "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
			exit
		}
		elseif($global:ServiceValidation -eq "True")
		{
			Write-Output "ALL THE TOMCAT SES SERVICES ARE STOPPED"
		}		
			
		# SENDING THE STATUS TO ADMIN
		Write-Output "COMPLETED EXECUTING BRINGSYSTEMDOWN.PS1"
		Write-Output "PLEASE ANALYZE THE LOG FILE"
		Write-Output "SENDING AN EMAIL TO THE ADMIN"
		Send-Email-Attachment "$Env : COMPLETED EXECUTING BRINGSYSTEMDOWN.PS1" "BRINGSYSTEMDOWN.PS1 SCRIPT HAS BEEN EXECUTED `nPLEASE ANALYZE THE ATTACHED LOG FILE." "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
	}

# USED TO CATCH ANY EXCEPTION AND OCCURED IN TRY BLOCK AND SEND AN EMAIL TO THE ADMIN
Catch
	{
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Write-Output "EXCEPTION RUNNING BRINGSYSTEMDOWN.ps1" "ERROR MESSAGE: $ErrorMessage `n FAILEDITEM: $FailedItem `n"
		Send-Email-Attachment "$Env : EXCEPTION RUNNING BRINGSYSTEMDOWN.PS1" "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
	}

# CLEARING THE VARIABLE MEMORY/VALUES
finally
	{
		Clear-Variable SiebSrvrName -Scope Global
		Clear-Variable WebSrvrName -Scope Global
		Clear-Variable NoOfSiebSrvrs -Scope Global
		Clear-Variable SvcName -Scope Global
		Clear-Variable NoOfWebSrvrs -Scope Global
		Clear-Variable MailFrom -Scope Global
		Clear-Variable MailTo -Scope Global
		Clear-Variable SMTPServer -Scope Global
		Clear-Variable Env
		Clear-Variable Gateway
		Clear-Variable ScriptLogPath
		Clear-Variable SyncServ
		Clear-Variable FldrNameTime
		Clear-Variable ScriptName
		Clear-Variable SEASiebSrvrName
		Clear-Variable TUKSiebSrvrName
		Stop-Transcript
	}