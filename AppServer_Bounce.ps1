# DEVELOPER -- IMTIYAZ MOHAMMED
# EMAIL -- IMTIYAZ.MOHAMMED@ALASKAAIR.COM
# THIS SCRIPT IS USED TO BOUNCE THE SIEBEL SERVER
# Shantan 08/11/2021 Updated script to stop tomcat ses and logic to use  module based on environment 
try {
	Clear-Host
	$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
	# Load config file
	[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
	$global:msgBody = "Completed Executing Script"
	$global:SiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
	$global:NoOfSiebSrvrs = $ConfigFile.Settings.Siebel.NoOfSiebSrvrs
	$global:SvcName = $ConfigFile.Settings.Siebel.SvcName
	$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
	$global:MailTo = $ConfigFile.Settings.Email.MailTo
	$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
	$Env = $ConfigFile.Settings.Siebel.Env
	$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
	$ScriptName = "APPSERVERBOUNCE_"
	$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
	$global:SiebSrvrNumber = $ConfigFile.Settings.Siebel.SiebSrvrNumber
	$Environment = $ConfigFile.Settings.Siebel.Environment
	Start-Transcript $ScriptLogPath\$ScriptName$FldrNameTime.txt
	if ($Environment -eq "DEV2" -or $Environment -eq "Test2" ) { 
		Write-Output "**** Environment: $Environment" 
		Import-Module -Force "$MyDir\SiebelServiceMod.psm1" -DisableNameChecking
	}
	elseif ($Environment -eq "DEV" -or $Environment -eq "Test" -or $Environment -eq "QA" -or $Environment -eq "Prod"   ) { 
		Write-Output "**** Environment: $Environment" 
		Import-Module -Force "$MyDir\RepMigrMod.psm1" -DisableNameChecking
	}
	else {
		Write-Output "echo *** Cannot determine correct environment" 
		Write-Output "*** $Environment" 
		$Err = "Y"
	}			
	$Err = "False"
	#THIS FUNCTION IS USED TO STOP THE SIEBEL SERVER SERVICES
	Write-Output "STOPPING  SIEBEL SERVICES"
	stopSiebelServices
	$TestTime = 30
	$NoOfTries = 1..10
	foreach ($i in $NoOfTries) {
		Write-Output "SLEEP FOR $TestTime SECONDS"
		Start-Sleep $TestTime
		validateSiebelServices "Stopped"
		if ($global:ServiceValidation -eq "True") {
			break
		}
		else {
			Write-Output "SIEBEL SERVICES ARE NOT DOWN YET"
		}
	}
	
	# VERIFY ALL SIEBEL SERVERS ARE DOWN
	Write-Output "CHECKING IF ALL THE SIEBEL SERVICES ARE DOWN?"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE SIEBEL SERVICES ARE NOW STOPPED"
	}
	else {
		$Err = "True"
		Write-Output "TERMINATED EXECUTION OF AppServer_Bounce.PS1 AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
		exit
	}
	# THIS FUNCTION IS USED TO STOP THE TOMCAT SES SERVICES
	Write-Output "STOPPING THE TOMCAT SES SERVICES"
	stopSESServices
	$TestTime = 30
	$NoOfTries = 1..10
	foreach ($i in $NoOfTries) {
		Write-Output "SLEEP FOR $TestTime SECONDS"
		Start-Sleep $TestTime
		validateWebServices "Stopped"
		if ($global:ServiceValidation -eq "True") {
			break
		}
		else {
			Write-Output "TOMCAT SES SERVICES ARE NOT DOWN YET"
		}
	}
	# VALIDATE IF ALL THE TOMCAT SES SERVICES ARE DOWN
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE TOMCAT SES SERVICES ARE STOPPED"
	}
	else {
		$Err = "True"
		Write-Output "TERMINATED EXECUTION OF AppServer_Bounce.PS1 AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
		exit
	}
		
	# STARTING THE TOMCAT SES SERVICES
	Write-Output "SLEEP FOR 60 SECONDS"
	Start-Sleep 60
	Write-Output "STARTING THE TOMCAT SES SERVICES"
	startSESServices
	Write-Output "SLEEP FOR 60 SECONDS"
	Start-Sleep 60
	# VALIDATE IF ALL THE TOMCAT SES SERVICES ARE UP
	validateSESServices "Running"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE TOMCAT SES SERVICES ARE UP AND RUNNING"
	}
	else {
		$Err = "True"
		Write-Output "TERMINATED EXECUTION OF AppServer_Bounce.PS1 AS ALL THE TOMCAT SES SERVICES ARE NOT IN RUNNING STATE"
		exit
	}
	# STARTING THE SIEBEL SERVICES
	Write-Output "SLEEP FOR 60 SECONDS"
	Start-Sleep 60
	Write-Output "STARTING THE SIEBEL SERVICES"
	startSiebelServices	
	Write-Output "WAITING FOR SIEBEL SERVICES TO BE START AND WILL WAIT FOR SLEEP FOR 60 SECONDS"
	Start-Sleep 60			
	# VERIFY ALL SIEBEL SERVERS ARE UP
	Write-Output "CHECKING IF ALL THE SIEBEL SERVICES ARE STARTED?"
	validateSiebelServices "Running"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE SIEBEL SERVICES ARE NOW STARTED"
	}	
	else {
		$Err = "True"
		Write-Output "TERMINATED EXECUTION OF AppServer_Bounce.PS1 AS AS ALL THE SIEBEL SERVICES ARE NOT UP"
		exit
	}

	# Sending the status of the services after the stop/start/restart
	Write-Output "SENDING AN EMAIL TO THE ADMIN"
	Stop-Transcript
	if ($Err -eq "True") {
		Send-MailMessage  -From $MailFrom -To $MailTo -Subject "SIEBEL SERVICES ARE NOT RESTARTED " -Body "ALL THE SERVICES ARE NOT RUNNING `nPLEASE ANALYZE THE ATTACHED LOG FILE." -SmtpServer $SMTPServer -Attachments $ScriptLogPath\$ScriptName$FldrNameTime.txt
	}
	Send-MailMessage -From $MailFrom -To $MailTo  -Subject "AppServer_Bounce" -Body $msgBody -SmtpServer $SMTPServer
					
}
# used to catch any exception and occured in try block and send an email to the admin
Catch {
		
	$ErrorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	Send-MailMessage -From $MailFrom -To $MailTo -Subject "$Env : Exception Running Siebel_Bounce.ps1" -Body "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" 
}	
# This code is used to clear the variables/memory
finally {
	Clear-Variable msgBody -Scope Global
	Clear-Variable SiebSrvrName -Scope Global
	Clear-Variable NoOfSiebSrvrs -Scope Global
	Clear-Variable SvcName -Scope Global
	Clear-Variable MailFrom -Scope Global
	Clear-Variable MailTo -Scope Global
	Clear-Variable SMTPServer -Scope Global
	Clear-Variable Env
	Clear-Variable ScriptName
	Clear-Variable ScriptLogPath
	Clear-Variable Environment
	Clear-Variable SiebSrvrNumber -Scope Global
	Clear-Variable FldrNameTime
}