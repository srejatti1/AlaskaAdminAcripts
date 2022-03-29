# DEVELOPER -- IMTIYAZ MOHAMMED
# EMAIL -- IMTIYAZ.MOHAMMED@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
# 1. STOP THE WEBSERVICES
# 2. STOP THE SIEBEL SERVICES
# 3. STOP THE GATEWAY SERVICE
# Shantan 06/09/2021 Updated Script to change stop services sequence
# Shantan 07/19/2021 Updated logic to use  module based on environment 
try {
	Clear-Host
	$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
	# LOAD CONFIG FILE
	[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
	$global:SiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
	$global:WebSrvrName = $ConfigFile.Settings.Siebel.WebSrvrName
	$global:NoOfSiebSrvrs = $ConfigFile.Settings.Siebel.NoOfSiebSrvrs
	$global:SvcName = $ConfigFile.Settings.Siebel.SvcName
	$global:NoOfWebSrvrs = $ConfigFile.Settings.Siebel.NoOfWebSrvrs
	$global:SiebSrvrNumber = $ConfigFile.Settings.Siebel.SiebSrvrNumber
	$Env = $ConfigFile.Settings.Siebel.Env
	$global:Gateway = $ConfigFile.Settings.Siebel.Gateway
	$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
	$ScriptName = "BRINGSYSTEMDOWN_"
	$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
	$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
	$global:MailTo = $ConfigFile.Settings.Email.MailTo
	$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
	$global:Environment = $ConfigFile.Settings.Siebel.Environment
	$global:SesSvc = $ConfigFile.Settings.Siebel.SesSvc
	$global:AiSvc = $ConfigFile.Settings.Siebel.AiSvc
	Start-Transcript $ScriptLogPath\$ScriptName$FldrNameTime.txt
	Write-Output "BRING DOWN THE SERVICES ON $Environment"	
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
	# THIS FUNCTION CHECKS THE STATUS OF IIS AND WWW SERVICE AND STOPS THEM IF THEY ARE IN RUNNING STATE
	Write-Output "STOPPING THE WEB AI SERVICES"
	stopWebServices
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
			Write-Output "WEB AI SERVICES ARE NOT DOWN YET"
		}
	}
	# VALIDATE IF ALL THE TOMCAT AI SERVICES ARE DOWN
	Write-Output "CHECKING IF WEB AI SERVICES ARE DOWN?"
	#VALIDATEWEBSERVICES "STOPPED"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE WEB AI SERVICES ARE STOPPED"
	}
	else {
		$Err = "True"
		Write-Output "TERMINATED EXECUTION OF BRINGSYSTEMDOWN.PS1 AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
		exit
	}
	
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
		Write-Output "TERMINATED EXECUTION OF BRINGSYSTEMDOWN.PS1 AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
		exit
	}
	# THIS FUNCTION CHECKS THE STATUS OF TOMCAT SES SERVICE AND STOPS THEM IF THEY ARE IN RUNNING STATE
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
	#VALIDATESESSERVICES "STOPPED"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE TOMCAT SES SERVICES ARE STOPPED"
	}
	else {
		$Err = "True"
		Write-Output "TERMINATED EXECUTION OF BRINGSYSTEMDOWN.PS1 AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
		exit
	}
	# THIS FUNCTION IS USED TO STOP THE SIEBEL GATEWAY NAME SERVICE
	stopGtwySESServices
	$TestTime = 30
	$NoOfTries = 1..5
	foreach ($i in $NoOfTries) {
		Write-Output "SLEEP FOR $TestTime SECONDS"
		Start-Sleep $TestTime
		validateGatewaySESServices "Stopped"
		if ($global:ServiceValidation -eq "True") {
			break
		}
		else {
			Write-Output "Gateway SES IS NOT DOWN YET"

		}
	}
	# VALIDATE IF Gateway SES SERVICES ARE DOWN
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE GATEWAY SES SERVICES ARE STOPPED"
	}
	else {
		Write-Output "TERMINATED EXECUTION OF BRINGSYSTEMDOWN.PS1 AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
		$Err = "True"
		exit
	}
	
	# THIS FUNCTION IS USED TO STOP THE  GATEWAY Registry
	stopGtwyServices
	$TestTime = 30
	$NoOfTries = 1..5
	foreach ($i in $NoOfTries) {
		Write-Output "SLEEP FOR $TestTime SECONDS"
		Start-Sleep $TestTime
		validateGatewayServices "Stopped"
		if ($global:ServiceValidation -eq "True") {
			break
		}
		else {
			Write-Output "Gateway Registry IS NOT DOWN YET"
		}
	}
	# VALIDATE IF Gateway SES SERVICES ARE DOWN
	#VALIDATEGATEWAYSERVICES "STOPPED"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE GATEWAY Registry SERVICES ARE STOPPED"
	}
	else {
		Write-Output "TERMINATED EXECUTION OF BRINGSYSTEMDOWN.PS1 AS ALL THE SIEBEL SERVICES ARE NOT DOWN"
		$Err = "True"
		exit
	}
			
	Write-Output "GATEWAY IS NOW STOPPED"
	Stop-Transcript
	if ($Err -eq "True") {
		Send-MailMessage  -From $MailFrom -To $MailTo -Subject "SIEBEL SERVICES ARE NOT STOPPING" -Body "ALL THE SERVICES ARE NOT STOPPING `nPLEASE ANALYZE THE ATTACHED LOG FILE." -SmtpServer $SMTPServer -Attachments $ScriptLogPath\$ScriptName$FldrNameTime.txt
	}
	Send-MailMessage  -From $MailFrom -To $MailTo -Subject "Stop Siebel Services " -Body "Completed Executing Script BRINGSYSTEMDOWN" -SmtpServer $SMTPServer
				
}

# USED TO CATCH ANY EXCEPTION AND OCCURED IN TRY BLOCK AND SEND AN EMAIL TO THE ADMIN
Catch {
	$ErrorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	Send-MailMessage  -From $MailFrom -To $MailTo -Subject "$Env : EXCEPTION RUNNING BRINGSYSTEMDOWN.PS1"  -Body "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n"  -SmtpServer $SMTPServer -Attachments $ScriptLogPath\$ScriptName$FldrNameTime.txt
}

# CLEARING THE VARIABLE MEMORY/VALUES
finally {
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
	Clear-Variable Gateway -Scope Global
	Clear-Variable ScriptLogPath
	Clear-Variable FldrNameTime
	Clear-Variable ScriptName
	Clear-Variable Environment
	Clear-Variable SesSvc 
	Clear-Variable AiSvc  
	}