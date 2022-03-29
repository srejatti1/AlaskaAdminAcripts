# DEVELOPER -- IMTIYAZ MOHAMMED
# EMAIL -- IMTIYAZ.MOHAMMED@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
# 1. START THE GATEWAY SERVICE
# 2. START THE SIEBEL SERVICES
# 3. START THE WEB SERVICES
# Shantan 06/09/2021 Updated Script to change start services sequence
try
	{
	cls
		$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
		# LOAD CONFIG FILE
		[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
		Import-Module -Force "$MyDir\RepMigrMod.psm1" -DisableNameChecking
		$SEASiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
		$TUKSiebSrvrName = $ConfigFile.Settings.TUK.SiebSrvrName
		$HostCompName = $env:computername

			Write-Output "BRING UP THE SERVICES ON TEST"
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
			$ScriptName = "BRINGSYSTEMUP_"
			$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
			$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
			$global:MailTo = $ConfigFile.Settings.Email.MailTo
			$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
		
		Start-Transcript $ScriptLogPath\$ScriptName$FldrNameTime.txt
		
		# STARTING THE TOMCAT SES SERVICES
		Write-Output "STARTING THE TOMCAT SES SERVICES"
		startSESServices
		
		Write-Output "SLEEP FOR 15 SECONDS"
		Start-Sleep 15
		
		# VALIDATE IF ALL THE TOMCAT SES SERVICES ARE UP
		validateSESServices "Running"
		if($global:ServiceValidation -eq "False")
		{
			Write-Output "ALL THE TOMCAT SES SERVICES ARE NOT IN RUNNING STATE"
			#Send-Email-Attachment "$Env : ERROR EXECUTING PRODTODRFAILOVER.PS1" "ALL THE WEB SERVICES ARE NOT UP `nPLEASE ANALYZE THE ATTACHED LOG FILE." "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
			#exit
		}
		elseif($global:ServiceValidation -eq "True")
		{
			Write-Output "ALL THE TOMCAT SES SERVICES ARE UP AND RUNNING"
		}
		
		# STARTING THE SIEBEL SERVICES
		Write-Output "STARTING THE SIEBEL SERVICES"
		startSiebelServices
		
		Write-Output "WAITING FOR SIEBEL SERVICES TO BE START AND WILL WAIT FOR SLEEP FOR 30 SECONDS"
		Write-Output "SCRIPT WILL CONTINUE ONCE THE SIEEBL SERVICES ARE STARTED"
		Start-Sleep 30
				
				
		# VERIFY ALL SIEBEL SERVERS ARE UP
		Write-Output "CHECKING IF ALL THE SIEBEL SERVICES ARE STARTED?"
		if($global:ServiceValidation -eq "False")
		{
			Write-Output "TERMINATED EXECUTION OF BRINGSYSTEMUP.PS1 AS ALL THE SIEBEL SERVICES ARE NOT UP"
			#Send-Email-Attachment "$Env : ERROR EXECUTING BRINGSYSTEMUP.PS1" "ALL THE SIEBEL SERVERS ARE NOT UP `nPLEASE ANALYZE THE ATTACHED LOG FILE." "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
			exit
		}
		elseif($global:ServiceValidation -eq "True")
		{
			Write-Output "ALL THE SIEBEL SERVICES ARE NOW STARTED"
		}
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
		Clear-Variable SiebSrvrNumber -Scope Global
		Clear-Variable Env
		Clear-Variable Gateway
		Clear-Variable ScriptLogPath
		Clear-Variable SyncServ
		Clear-Variable FldrNameTime
		Clear-Variable ScriptName
		Stop-Transcript
	}