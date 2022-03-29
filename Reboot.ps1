#stop siebel servers
sleep 10
get-Service -ComputerName seaqasbl19apl01 -Name siebsrvr_SBLQAENT_sblqasrv01 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl02 -Name siebsrvr_SBLQAENT_sblqasrv02 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl03 -Name siebsrvr_SBLQAENT_sblqasrv03 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl04 -Name siebsrvr_SBLQAENT_sblqasrv04 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl05 -Name siebsrvr_SBLQAENT_sblqasrv05 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl06 -Name siebsrvr_SBLQAENT_sblqasrv06 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl07 -Name siebsrvr_SBLQAENT_sblqasrv07 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl08 -Name siebsrvr_SBLQAENT_sblqasrv08 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl09 -Name siebsrvr_SBLQAENT_sblqasrv09 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl10 -Name siebsrvr_SBLQAENT_sblqasrv10 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl11 -Name siebsrvr_SBLQAENT_sblqasrv11 | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl12 -Name siebsrvr_SBLQAENT_sblqasrv12 | Stop-Service -Force -NoWait
sleep 60

#stop siebel gateway servers
get-Service -ComputerName seaqasbl19aplgw -Name gtwyns | Stop-Service -Force -NoWait
sleep 10

#stop siebel AI servers
get-Service -ComputerName seaqasbl19apl02 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl03 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl04 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl05 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl06 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl07 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl08 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl09 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl10 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl11 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl12 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19wb01 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19wb02 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19wb03 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19aplgw -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
get-Service -ComputerName seaqasbl19apl01 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Stop-Service -Force -NoWait
sleep 60


#siebel server StartupType Manual
get-Service -ComputerName seaqasbl19apl01 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl02 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl03 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl04 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl05 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl06 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl07 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl08 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl09 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl10 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl11 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl12 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19wb01 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19wb02 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19wb03 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19aplgw -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Manual


#siebel AI server StartupType Manual
get-Service -ComputerName seaqasbl19apl01 -Name siebsrvr_SBLQAENT_sblqasrv01 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl02 -Name siebsrvr_SBLQAENT_sblqasrv02 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl03 -Name siebsrvr_SBLQAENT_sblqasrv03 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl04 -Name siebsrvr_SBLQAENT_sblqasrv04 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl05 -Name siebsrvr_SBLQAENT_sblqasrv05 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl06 -Name siebsrvr_SBLQAENT_sblqasrv06 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl07 -Name siebsrvr_SBLQAENT_sblqasrv07 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl08 -Name siebsrvr_SBLQAENT_sblqasrv08 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl09 -Name siebsrvr_SBLQAENT_sblqasrv09 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl10 -Name siebsrvr_SBLQAENT_sblqasrv10 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl11 -Name siebsrvr_SBLQAENT_sblqasrv11 | Set-Service -StartupType Manual
get-Service -ComputerName seaqasbl19apl12 -Name siebsrvr_SBLQAENT_sblqasrv12 | Set-Service -StartupType Manual

#siebel gateway server StartupType Manual
get-Service -ComputerName seaqasbl19aplgw -Name gtwyns | Set-Service -StartupType Manual

#Reboot gateway servers
Restart-Computer -ComputerName	seaqasbl19aplgw -Force
sleep 60
#Reboot QA servers
Restart-Computer -ComputerName	seaqasbl19apl02 -Force
Restart-Computer -ComputerName	seaqasbl19apl03 -Force
Restart-Computer -ComputerName	seaqasbl19apl04 -Force
Restart-Computer -ComputerName	seaqasbl19apl05 -Force
Restart-Computer -ComputerName	seaqasbl19apl06 -Force
Restart-Computer -ComputerName	seaqasbl19apl07 -Force
Restart-Computer -ComputerName	seaqasbl19apl08 -Force
Restart-Computer -ComputerName	seaqasbl19apl09 -Force
Restart-Computer -ComputerName	seaqasbl19apl10 -Force
Restart-Computer -ComputerName	seaqasbl19apl11 -Force
Restart-Computer -ComputerName	seaqasbl19apl12 -Force
Restart-Computer -ComputerName	seaqasbl19wb01 -Force
Restart-Computer -ComputerName	seaqasbl19wb02 -Force
Restart-Computer -ComputerName	seaqasbl19wb03 -Force
sleep 60
Restart-Computer -ComputerName	seaqasbl19apl01 -Force
sleep 05
exit
