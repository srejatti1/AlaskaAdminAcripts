# DEVELOPER -- IMTIYAZ MOHAMMED
# EMAIL -- IMTIYAZ.MOHAMMED@ALASKAAIR.COM
# THIS SCRIPT IS USED TO PERFORM THE FOLLOWING OPERATIONS
# Shantan 07/26/2021 Updated Script
# Copies latest browser scripts from Dev environment to Target Environment AI Servers

try {
	Clear-Host
	$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
	Import-Module -Force "$MyDir\RepMigrMod.psm1" -DisableNameChecking
	$SrcBSDir = "\\seadvsbl19apl02\D\sea\ai\applicationcontainer\webapps\siebel"
	# LOAD CONFIG FILE WHICH CONTAINS ALL THE VALUES FOR THE PARAMETERS REQUIRED FOT THIS SCRIPT
	[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
		
	# THE FOLLOWING ARE THE GLOBAL VARIABLES WHICH ARE USED IN REPMIGRMOD.PSM1 AND THE VALUES FOR THESE PARAMETERS
	# ARE OBTAINED FROM SIEBELDEVTASKS.CONFIG
	$global:NoOfSiebSrvrs = $ConfigFile.Settings.Siebel.NoOfSiebSrvrs
	$global:SiebSrvrName = $ConfigFile.Settings.Siebel.SiebSrvrName
	$global:WebSrvrName = $ConfigFile.Settings.Siebel.WebSrvrName
	$global:NoOfWebSrvrs = $ConfigFile.Settings.Siebel.NoOfWebSrvrs
	$global:SvcName = $ConfigFile.Settings.Siebel.SvcName
	$FldrName = Get-Date -format MMddyyyy
	$FldrNameTime = (Get-Date -format MMddyyyy) + "_" + (Get-Date -format mmss)
	$global:MailFrom = $ConfigFile.Settings.Email.MailFrom
	$global:MailTo = $ConfigFile.Settings.Email.MailTo
	$global:SMTPServer = $ConfigFile.Settings.Email.SMTPServer
	$ScriptLogPath = $ConfigFile.Settings.Siebel.ScriptLogPath
	$Env = $ConfigFile.Settings.Siebel.Env
	$ScriptName = "Copy_BrowserScripts"
	$ImpRepositoryName = $ConfigFile.Settings.Siebel.ImpRepositoryName
	$AdminUser = $ConfigFile.Settings.Siebel.AdminUser
	$AdminPassword = $ConfigFile.Settings.Siebel.AdminPassword
	$ServerDataSource = $ConfigFile.Settings.Siebel.ServerDataSource
	$SiebelServerBinPath = $ConfigFile.Settings.Siebel.SiebelServerBinPath
	$RemoteSRFPath = $ConfigFile.Settings.Siebel.RemoteSRFPath
	$SRFName = $ConfigFile.Settings.Siebel.SRFName
	$SourceTSTDir = $ConfigFile.Settings.Siebel.SourceTSTDir
	$RemoteSiebelClientRoot = $ConfigFile.Settings.Siebel.RemoteSiebelClientRoot
	$RemoteSiebelToolsBinPath = $ConfigFile.Settings.Siebel.RemoteSiebelToolsBinPath
	$RemoteBrowserScriptDestPath = $ConfigFile.Settings.Siebel.RemoteBrowserScriptDestPath
	$CurrDir = $ConfigFile.Settings.Siebel.CurrDir
	$SRFPath = $ConfigFile.Settings.Siebel.SRFPath
	$global:TUKNoOfSiebSrvrs = $ConfigFile.Settings.TUK.TUKNoOfSiebSrvrs
	$global:TUKSiebSrvrName = $ConfigFile.Settings.TUK.TUKSiebSrvrName
	$global:TUKNoOfWebSrvrs = $ConfigFile.Settings.TUK.TUKNoOfWebSrvrs
	$global:TUKWebSrvrName = $ConfigFile.Settings.TUK.TUKWebSrvrName
	$Environment = $ConfigFile.Settings.Siebel.Environment
	$SiebSrvrNumber = $ConfigFile.Settings.Siebel.SiebSrvrNumber
		
		
	# NEW FILE FOR LOGGING
	Start-Transcript $ScriptLogPath\$ScriptName$FldrNameTime.txt
		
		
	# COPYING THE BROWSER SCRIPT FOLDER TO THE SEA WEB SERVER
	if ($Environment -eq "Test2" ) { 
		Write-Output "**** Environment: $Environment" 
		Write-Output "COPYING LATEST BROWSER SCRIPT FOLDER FROM $SrcBSDir TO \\$WebSrvrName$SiebSrvrNumber\$RemoteBrowserScriptDestPath"
		$latest = Get-ChildItem $SrcBSDir -Filter 'srf*' | Where { $_.PSIsContainer } | Sort CreationTime -Descending | Select -First 1
		Copy-Item -Path "$SrcBSDir\$latest" "\\$WebSrvrName$SiebSrvrNumber\$RemoteBrowserScriptDestPath" -recurse -Force -verbose
	}
	else {
		for ($i = 1
			$i -le $global:NoOfWebSrvrs
			$i++) {
			Write-Output "COPYING LATEST BROWSER SCRIPT FOLDER FROM $SrcBSDir TO \\$WebSrvrName$i\$RemoteBrowserScriptDestPath"
			$latest = Get-ChildItem $SrcBSDir -Filter 'srf*' | Where { $_.PSIsContainer } | Sort CreationTime -Descending | Select -First 1
			Copy-Item -Path "$SrcBSDir\$latest" "\\$WebSrvrName$i\$RemoteBrowserScriptDestPath" -recurse -Force -verbose
		}
	}
}			
# USED TO CATCH ANY EXCEPTION AND OCCURED IN TRY BLOCK AND SEND AN EMAIL TO THE ADMIN
Catch {
	$ErrorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	Send-Email "$Env : Exception Running SRFReplace_Apps_and_Web" "Error Message: $ErrorMessage `n FailedItem: $FailedItem `n" 
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
	Clear-Variable FldrName
	Clear-Variable FldrNameTime		
	Clear-Variable ScriptLogPath
	Clear-Variable Env
	Clear-Variable ScriptName
	Clear-Variable ImpRepositoryName
	Clear-Variable AdminUser
	Clear-Variable AdminPassword
	Clear-Variable ServerDataSource
	Clear-Variable SiebelServerBinPath
	Clear-Variable Environment
	Clear-Variable SiebSrvrNumber
	Stop-Transcript
}