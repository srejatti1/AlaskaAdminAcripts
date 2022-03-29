# DEVELOPER -- IMTIYAZ MOHAMMED
# THIS SCRIPT IS USED TO START THE SIEBEL SERVICE
try
	{
		cls
		$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path

		# LOAD CONFIG FILE
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
		
		# CHECK IF THE GATEWAY SERVICE IS DOWN AND START THE SERVICE IF IT IS STOPPED
		$GateWayStatus = (get-service -ComputerName $Gateway -Name "gtwyns").status
		if($GateWayStatus -eq "Stopped")
		{
			Write-Output "GATEWAY SERVICE IS DOWN"
			Write-Output "STARTING THE GATEWAY SERVICE"
			(get-service -ComputerName $Gateway -Name "gtwyns").Start()
			Start-Sleep 15
		}
		
		# CHECK IF THE GATEWAY SERVICE IS UP AND START THE SIEBEL SERVICE IF IT IS RUNNING
		$GateWayStatus = (get-service -ComputerName $Gateway -Name "gtwyns").status
		if($GateWayStatus -eq "Running")
		{
			Write-Output "GATEWAY SERVICE IS UP AND RUNNING"
			Write-Output "STARTING THE SES TOMCAT SERVICES"
			
			startSESServices
            Start-Sleep 30
			
            # VERIFY SES TOMCAT SERVICES ARE UP AND RUNNING
			validateSESServices "Running"
			
            if($global:ServiceValidation -eq "True")
            {
                Write-Output "SES TOMCAT SERVICES ARE UP AND RUNNING"
				Write-Output "STARTING TOMCAT AI SERVICES"
				startWebServices
				
				# VERIFY AI TOMCAT SERVICE IS UP AND RUNNING
				
				validateWebServices "Running"
				
				if($global:ServiceValidation -eq "True")
				{
				Write-Output "AI TOMCAT SERVICES ARE UP AND RUNNING"
				# VERIFY ALL SIEBEL SERVERS ARE UP AND RUNNING
				
				validateSiebelServices "Running"
			
				# VERIFY ALL SIEBEL SERVERS ARE RUNNING
				if($global:ServiceValidation -eq "False")
				{
					Write-Output "STARTING THE SIEBEL SERVICES"
					startSiebelServices
					Write-Output "SLEEP FOR 30 SECONDS"
					Start-Sleep 30
				}
				elseif($global:ServiceValidation -eq "True")
				{
					Write-Output "ALL THE SIEBEL SERVICES ARE RUNNING"
				}
			}
		}
		
		# VERIFY ALL SIEBEL SERVERS ARE UP AND RUNNING
		validateSiebelServices "Running"
		
		# VERIFY ALL SIEBEL SERVERS ARE RUNNING
		if($global:ServiceValidation -eq "False")
		{
			Write-Output "ALL THE SIEBEL SERVICES ARE NOT RUNNING"
		}
		elseif($global:ServiceValidation -eq "True")
		{
			Write-Output "ALL THE SIEBEL SERVICES ARE NOW RUNNING"
		}
	}
# USED TO CATCH ANY EXCEPTION AND OCCURED IN TRY BLOCK AND SEND AN EMAIL TO THE ADMIN
Catch
	{
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Send-Email "$Env : Exception Running SiebelServerStart.ps1" "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" 
	}

# CLEARING THE VARIABLE MEMORY/VALUES	
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
	}