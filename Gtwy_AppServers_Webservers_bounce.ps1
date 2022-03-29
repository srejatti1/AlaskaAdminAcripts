# Developer -- Imtiyaz Mohammed
# Email -- Imtiyaz.Mohammed@alaskaair.com
# This script is used to perform a complete bounce and performs the following operations
# 1. Stop the WebServers 
# 2. Stop the Siebel Servers
# 3. Stop the Gateway
# 4. Start the Gateway
# 3. Start the Siebel Servers (Starts the Tomcat Servers before starting the Siebel Servers)
# 4. Start the WebServers
# Set-ExecutionPolicy Unrestricted 
try
	{
	cls
		$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path

		# Load config file
		[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
		Import-Module -Force "$MyDir\RepMigrMod.psm1" -DisableNameChecking

		$global:msgBody = ""
		$global:SiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
		$global:WebSrvrName = $ConfigFile.Settings.Siebel.WebSrvrName
		$global:NoOfSiebSrvrs = $ConfigFile.Settings.Siebel.NoOfSiebSrvrs
		$global:SvcName = $ConfigFile.Settings.Siebel.SvcName
		$global:NoOfWebSrvrs = $ConfigFile.Settings.Siebel.NoOfWebSrvrs
		$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
		$global:MailTo = $ConfigFile.Settings.Email.MailTo
		$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
		$Env = $ConfigFile.Settings.Siebel.Env
		$Gateway = $ConfigFile.Settings.Siebel.Gateway
		$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
		$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
		$ScriptName = "GatewayBounce"
		
		Start-Transcript $ScriptLogPath\$ScriptName$FldrNameTime.txt
		
		# This function is used to stop the Siebel Server services
		Write-Output "STOPPING THE SIEBEL SERVICES"
		stopSiebelServices
		
		#Write-Output "WAITING FOR SIEBEL SERVICES TO BE STOPPED AND WILL WAIT FOR UPTO 5 MINUTES"
		Write-Output "SCRIPT WILL CONTINUE ONCE THE SIEEBL SERVICES ARE STOPPED"
		#Start-Sleep 300
		
		# This function checks the status of TOMCAT SES service and stops them if they are in running state
		Write-Output "STOPPING THE TOMCAT SES SERVICES"
		stopSESServices
		
		Write-Output "SLEEP FOR 30 SECONDS"
		Start-Sleep 30
		
		
		# This function checks the status of IIS and WWW service and stops them if they are in running state
		Write-Output "STOPPING THE WEB SERVICES"
		stopWebServices
		
		Write-Output "SLEEP FOR 30 SECONDS"
		Start-Sleep 30
		
		
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
		
		# THIS FUNCTION IS USED TO STOP THE SIEBEL GATEWAY NAME SERVICE
		Write-Output "STOPPING THE GATEWAY SERVICE"
		(get-service -ComputerName $Gateway -Name "gtwyns").Stop()
		Start-Sleep 30
		
		# CHECK IF THE GATEWAY SERVICE IS DOWN AND START THE SERVICE IF IT IS STOPPED
		$GateWayStatus = (get-service -ComputerName $Gateway -Name "gtwyns").status
		if($GateWayStatus -eq "Stopped")
		{
			(get-service -ComputerName $Gateway -Name "gtwyns").Start()
			Start-Sleep 15
		}
		else
		{
			Write-Output "FAILED TO STOP GATEWAY SERVICE"
			exit
		}
		
		# CHECK IF THE GATEWAY SERVICE IS UP AND START THE SIEBEL SERVICE IF IT IS RUNNING
		$GateWayStatus = (get-service -ComputerName $Gateway -Name "gtwyns").status
		if($GateWayStatus -eq "Running")
		{
			startSESServices
			Start-Sleep 30
			Write-Output "STARTING THE WEB SERVICES"
			startWebServices
			Start-Sleep 30
			startSiebelServices
			Start-Sleep 30
		}
		else
		{
			Write-Output "FAILED TO START SIEBEL SERVICES AS GATEWAY SERVICE IS NOT IN RUNNING STATE"
			exit
		}
		
		# THIS FUNCTION IS USED TO CHECK THE STATUS THE SIEBEL SERVER SERVICES AFTER RESTART
		Write-Output "CHECKING THE STATUS OF SIEBEL SERVICES"
		validateRestartSiebelServices
		
			
		# SENDING THE STATUS OF THE SERVICES AFTER THE RESTART
		Write-Output "SENDING AN EMAIL TO THE ADMIN"
		#Send-Email "$Env : Admin Gateway Bounce Operation Status" $global:msgBody
		Send-Email-Attachment "$Env : Admin Gateway Bounce Operation Status" "GATEWAY BOUNCE HAS BEEN EXECUTED `nPLEASE ANALYZE THE ATTACHED LOG FILE." "$ScriptLogPath\$ScriptName$FldrNameTime.txt"
	}

# used to catch any exception and occured in try block and send an email to the admin
Catch
	{
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Send-Email "$Env : Exception executing Gateway Bounce" "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" 
	}

# clearing the variable memory/values
finally
	{
		Clear-Variable msgBody -Scope Global
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
		Clear-Variable FldrNameTime
		Clear-Variable ScriptName
		Stop-Transcript
	}