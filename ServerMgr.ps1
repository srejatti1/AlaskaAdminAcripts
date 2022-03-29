# DEVELOPER -- Shantan Polepally
# EMAIL-SHANTAN.POLEPALLY@ALASKAAIR.COM
# THIS SCRIPT IS USED TO connect to servermgr

try
{
	$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
	# LOAD CONFIG FILE
	$configuration = $Args[0];
	[xml]$ConfigFile = Get-Content "$MyDir\SiebelDevTasks.config"
	$Gateway = $ConfigFile.Settings.Siebel.Gateway
	$Enterprise = $ConfigFile.Settings.Siebel.Enterprise
	$AdminUser  = $ConfigFile.Settings.Siebel.AdminUser
	$AdminPassword=$ConfigFile.Settings.Siebel.AdminPassword
	Set-Location -Path "D:\sea\ses\siebsrvr\BIN"
	.\srvrmgr.exe -g $Gateway -e $Enterprise -u $AdminUser -p $AdminPassword
}
finally
{
	Clear-Variable Gateway
	Clear-Variable Enterprise
	Clear-Variable AdminUser
	Clear-Variable AdminPassword
}