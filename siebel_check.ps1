# DEVELOPER -- IMTIYAZ MOHAMMED
# EMAIL -- IMTIYAZ.MOHAMMED@ALASKAAIR.COM
# THIS SCRIPT IS USED TO CHECK THE STATUS OF THE SIEBEL SERVICE
# Set-ExecutionPolicy Unrestricted 
# Shantan 7/15/2021 Updated Script
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
	$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
	$global:MailTo = $ConfigFile.Settings.Email.MailTo
	$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
	$global:SiebSrvrNumber = $ConfigFile.Settings.Siebel.SiebSrvrNumber
	$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
	$Env = $ConfigFile.Settings.Siebel.Env
	$ScriptName = "Siebel_Check"
	$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
	$global:Gateway = $ConfigFile.Settings.Siebel.Gateway
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
	validateGatewayServices "Running"
	if ($global:ServiceValidation -eq "False") {
		$Err = "True"
		Write-Output "Gateway Registry IS NOT Running"
	}
	elseif ($global:ServiceValidation -eq "True") {
		Write-Output "Gateway Registry IS Running"
	}
	# CHECK IF  GATEWAY SES Service is running
	validateGatewaySESServices "Running"
	if ($global:ServiceValidation -eq "False") {
		$Err = "True"
		Write-Output "Gateway SES Service IS NOT Running"
	}
	elseif ($global:ServiceValidation -eq "True") {
		Write-Output "Gateway SES Service IS Running"
	}
		
	# VERIFY ALL SIEBEL SERVERS ARE UP AND RUNNING
	validateSiebelServices "Running"
		
	# VERIFY ALL SIEBEL SERVERS ARE RUNNING
	if ($global:ServiceValidation -eq "False") {
		$Err = "True"
		Write-Output "ALL THE SIEBEL SERVICES ARE NOT RUNNING"
	}
	elseif ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE SIEBEL SERVICES ARE NOW RUNNING"
	}
	# VALIDATE IF ALL THE TOMCAT SES SERVICES ARE UP
	validateSESServices "Running"
	if ($global:ServiceValidation -eq "False") {
		$Err = "True"
		Write-Output "ALL THE SIEBEL SES SERVICES ARE NOT RUNNING"
	}
	elseif ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE SIEBEL SES SERVICES ARE NOW RUNNING"
	}
		
	# VALIDATE IF ALL THE WEBSERVICES ARE UP
	validateWebServices "Running"
	if ($global:ServiceValidation -eq "False") {
		$Err = "True"
	}
	elseif ($global:ServiceValidation -eq "True") {
		Write-Output "ALL THE TOMCAT AI SERVICES ARE UP AND RUNNING"
	}
	Stop-Transcript
	if ($Err -eq "True") {
		Send-MailMessage  -From $MailFrom -To $MailTo -Subject "SIEBEL SERVICES ARE NOT IN RUNNING STATE" -Body "ALL THE SERVICES ARE NOT RUNNING `nPLEASE ANALYZE THE ATTACHED LOG FILE." -SmtpServer $SMTPServer -Attachments $ScriptLogPath\$ScriptName$FldrNameTime.txt
	}
		
}
# USED TO CATCH ANY EXCEPTION AND OCCURED IN TRY BLOCK AND SEND AN EMAIL TO THE ADMIN
Catch {
	$ErrorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	Send-MailMessage  -From $MailFrom -To $MailTo -Subject "$Env : Exception Running Siebel_check.ps1" -Body "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" -SmtpServer $SMTPServer
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
	Clear-Variable Environment
	Clear-Variable Gateway -Scope Global
	Clear-Variable SesSvc -Scope Global
	Clear-Variable AiSvc -Scope Global
		
}