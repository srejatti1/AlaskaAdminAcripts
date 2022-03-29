# DEVELOPER -- IMTIYAZ MOHAMMED
# EMAIL -- IMTIYAZ.MOHAMMED@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
# 1. START THE GATEWAY SERVICE
# 2. START THE SIEBEL SERVICES
# 3. START THE WEB SERVICES
# Shantan 06/09/2021 Updated Script to change start services sequence
# Shantan 07/19/2021 Updated logic to use  module based on environment
# Shantan 01/26/2022 Increase time for AI Service
try {
	Clear-Host
	$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
	# LOAD CONFIG FILE
	[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
	Import-Module -Force "$MyDir\RepMigrMod.psm1" -DisableNameChecking
	Write-Output "BRING UP THE SERVICES ON DEV"
	$global:SiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
	$global:WebSrvrName = $ConfigFile.Settings.Siebel.WebSrvrName
	$global:NoOfSiebSrvrs = $ConfigFile.Settings.Siebel.NoOfSiebSrvrs
	$global:SvcName = $ConfigFile.Settings.Siebel.SvcName
	$global:NoOfWebSrvrs = $ConfigFile.Settings.Siebel.NoOfWebSrvrs
	$global:SiebSrvrNumber = $ConfigFile.Settings.Siebel.SiebSrvrNumber
	$Env = $ConfigFile.Settings.Siebel.Env
	$global:Gateway = $ConfigFile.Settings.Siebel.Gateway
	$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
	$ScriptName = "BRINGSYSTEMUP_"
	$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
	$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
	$global:MailTo =  $ConfigFile.Settings.Email.MailTo
	$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
	$global:Environment = $ConfigFile.Settings.Siebel.Environment
	$global:SesSvc = $ConfigFile.Settings.Siebel.SesSvc
	$global:AiSvc = $ConfigFile.Settings.Siebel.AiSvc
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
	startGtwyServices
	Write-Output "SLEEP FOR 30 SECONDS"
	Start-Sleep 30
	validateGatewayServices "Running"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "Gateway Registry IS Running "
	}
	else {
		$Err = "True"
		Write-Output "Gateway Registry IS NOT Running "
		exit
	}
	Write-Output "GATEWAY IS NOW RUNNING"
	startGtwySESServices
	Start-Sleep 30
	validateGatewaySESServices "Running"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "Gateway SES IS  Running "
	}
	else {
		$Err = "True"
		Write-Output "Gateway SES Services IS NOT Running YET"
		exit
	}
	Write-Output "GATEWAY SES Service IS NOW RUNNING"
	# STARTING THE TOMCAT SES SERVICES
	Write-Output "STARTING THE TOMCAT SES SERVICES"
	startSESServices
	Write-Output "SLEEP FOR 30 SECONDS"
	Start-Sleep 30
	# VALIDATE IF ALL THE TOMCAT SES SERVICES ARE UP
	validateSESServices "Running"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE TOMCAT SES SERVICES ARE UP AND RUNNING"
	}
	else {
		$Err = "True"
		Write-Output "ALL THE TOMCAT SES SERVICES ARE NOT IN RUNNING STATE"
		exit
	}
	# STARTING THE SIEBEL SERVICES
	Write-Output "STARTING THE SIEBEL SERVICES"
	startSiebelServices	
	Write-Output "WAITING FOR SIEBEL SERVICES TO BE START AND WILL WAIT FOR SLEEP FOR 300 SECONDS"
	Write-Output "SCRIPT WILL CONTINUE ONCE THE SIEEBL SERVICES ARE STARTED"
	Start-Sleep 300			
	# VERIFY ALL SIEBEL SERVERS ARE UP
	Write-Output "CHECKING IF ALL THE SIEBEL SERVICES ARE STARTED?"
	validateSiebelServices "Running"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE SIEBEL SERVICES ARE NOW STARTED"
	}	
	else {
		$Err = "True"
		Write-Output "TERMINATED EXECUTION OF BRINGSYSTEMUP.PS1 AS ALL THE SIEBEL SERVICES ARE NOT UP"
		exit
	}
	# STARTING THE TOMCAT AI SERVICES
	Write-Output "STARTING THE TOMCAT AI SERVICES"
	startWebServices
	Write-Output "SLEEP FOR 15 SECONDS"
	Start-Sleep 15
	# VALIDATE IF ALL THE TOMCAT AI SERVICES ARE UP
	validateWebServices "Running"
	if ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE TOMCAT AI SERVICES ARE UP AND RUNNING"
	}
	else {
		$Err = "True"
		Write-Output "ALL THE TOMCAT AI SERVICES ARE NOT IN RUNNING STATE"
		exit
	}
	Stop-Transcript
	if ($Err -eq "True") {
		Send-MailMessage  -From $MailFrom -To $MailTo -Subject "SIEBEL SERVICES ARE NOT IN RUNNING STATE" -Body "ALL THE SERVICES ARE NOT RUNNING `nPLEASE ANALYZE THE ATTACHED LOG FILE." -SmtpServer $SMTPServer -Attachments $ScriptLogPath\$ScriptName$FldrNameTime.txt
	}
	Send-MailMessage -From $MailFrom -To $MailTo  -Subject "BRINGSYSTEMUP" -Body "Completed Executing Script" -SmtpServer $SMTPServer
}
	
# USED TO CATCH ANY EXCEPTION AND OCCURED IN TRY BLOCK AND SEND AN EMAIL TO THE ADMIN
Catch {
	$ErrorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	Write-Output "EXCEPTION RUNNING BRINGSYSTEMUP.ps1" "ERROR MESSAGE: $ErrorMessage `n FAILEDITEM: $FailedItem `n"
	Send-MailMessage  -From $MailFrom -To $MailTo -Subject "$Env : EXCEPTION RUNNING BRINGSYSTEMUP.PS1"  -Body "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n"  -SmtpServer $SMTPServer -Attachments $ScriptLogPath\$ScriptName$FldrNameTime.txt
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