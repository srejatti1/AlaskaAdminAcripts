# DEVELOPER -- IMTIYAZ MOHAMMED
# EMAIL -- IMTIYAZ.MOHAMMED@ALASKAAIR.COM
# THIS SCRIPT IS USED TO BOUNCE THE SIEBEL SERVER
try
	{
		cls
		$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path

		# Load config file
		[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
		Import-Module -Force "$MyDir\RepMigrMod.psm1" -DisableNameChecking

		$global:msgBody = ""
		$global:SiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
		$global:NoOfSiebSrvrs = $ConfigFile.Settings.Siebel.NoOfSiebSrvrs
		$global:SvcName = $ConfigFile.Settings.Siebel.SvcName
		$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
		$global:MailTo = $ConfigFile.Settings.Email.MailTo
		$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
		$Env = $ConfigFile.Settings.Siebel.Env

		#This function is used to stop the Siebel Server services
		Write-Output "STOPPING THE SIEBEL SERVERS"
		stopSiebelServices
		
		#Write-Output "WAITING FOR SIEBEL SERVICES TO BE STOPPED AND WILL WAIT FOR UPTO 5 MINUTES"
		Write-Output "SCRIPT WILL CONTINUE ONCE THE SIEEBL SERVICES ARE STOPPED"
		#Start-Sleep 300
		
		$TestTime = 30
		$NoOfTries = 1..10
		foreach($i in $NoOfTries)
		{
			Write-Output "SIEBEL IS NOT DOWN YET, SLEEP FOR 30 SECONDS"
			validateSiebelServices "Stopped"
			if($global:ServiceValidation -eq "True")
			{
				break
			}
			Start-Sleep $TestTime
		}
		
		# VERIFY ALL SIEBEL SERVERS ARE DOWN
		Write-Output "CHECKING IF ALL THE SIEBEL SERVICES ARE DOWN?"
		if($global:ServiceValidation -eq "False")
		{
			Write-Output "TERMINATED EXECUTION OF PRODTODRFAILOVER AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
			# Send-Email-Attachment "$Env : ERROR EXECUTING PRODTODRFAILOVER.PS1" "ALL THE SIEBEL SERVERS ARE NOT DOWN `nPLEASE ANALYZE THE ATTACHED LOG FILE." "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
			exit
		}
		elseif($global:ServiceValidation -eq "True")
		{
			Write-Output "ALL THE SIEBEL SERVICES ARE NOW STOPPED"
		}
		
		#This function is used to start the Siebel Server services
		Write-Output "STARTING THE SIEBEL SERVERS"
		startSiebelServices
		
		Start-Sleep 10
		
		#This function is used to check the status the Siebel Server services after restart
		Write-Output "CHECKING THE STATUS OF SIEBEL SERVICE"
		validateRestartSiebelServices

		# Sending the status of the services after the stop/start/restart
		Write-Output "SENDING AN EMAIL TO THE ADMIN"
		Send-Email "$Env : Admin Siebel Bounce Operation Status" $global:msgBody
		
	}
# used to catch any exception and occured in try block and send an email to the admin
Catch
	{
		echo "catch"
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Send-Email "$Env : Exception Running Siebel_Bounce.ps1" "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" 
	}	
# This code is used to clear the variables/memory
finally
	{
		Clear-Variable msgBody -Scope Global
		Clear-Variable SiebSrvrName -Scope Global
		Clear-Variable NoOfSiebSrvrs -Scope Global
		Clear-Variable SvcName -Scope Global
		Clear-Variable MailFrom -Scope Global
		Clear-Variable MailTo -Scope Global
		Clear-Variable SMTPServer -Scope Global
		Clear-Variable Env
	}