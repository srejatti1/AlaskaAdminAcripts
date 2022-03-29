#wait time
sleep 90
#Start siebel AI servers
get-Service -ComputerName seaqasbl19aplgw -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl02 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl03 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl04 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl05 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl06 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl07 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl08 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl09 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl10 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl11 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl12 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
get-Service -ComputerName seaqasbl19apl01 -Name siebelApplicationContainer_Siebel_Home_D_sea_ses | Start-Service
sleep 45

#Start siebel gateway servers
get-Service -ComputerName seaqasbl19aplgw -Name gtwyns | Start-Service
sleep 45


#Start siebel servers
get-Service -ComputerName seaqasbl19apl02 -Name siebsrvr_SBLQAENT_sblqasrv02 | Start-Service
get-Service -ComputerName seaqasbl19apl03 -Name siebsrvr_SBLQAENT_sblqasrv03 | Start-Service
get-Service -ComputerName seaqasbl19apl04 -Name siebsrvr_SBLQAENT_sblqasrv04 | Start-Service
get-Service -ComputerName seaqasbl19apl05 -Name siebsrvr_SBLQAENT_sblqasrv05 | Start-Service
get-Service -ComputerName seaqasbl19apl06 -Name siebsrvr_SBLQAENT_sblqasrv06 | Start-Service
get-Service -ComputerName seaqasbl19apl07 -Name siebsrvr_SBLQAENT_sblqasrv07 | Start-Service
get-Service -ComputerName seaqasbl19apl08 -Name siebsrvr_SBLQAENT_sblqasrv08 | Start-Service
get-Service -ComputerName seaqasbl19apl09 -Name siebsrvr_SBLQAENT_sblqasrv09 | Start-Service
get-Service -ComputerName seaqasbl19apl10 -Name siebsrvr_SBLQAENT_sblqasrv10 | Start-Service
get-Service -ComputerName seaqasbl19apl11 -Name siebsrvr_SBLQAENT_sblqasrv11 | Start-Service
get-Service -ComputerName seaqasbl19apl12 -Name siebsrvr_SBLQAENT_sblqasrv12 | Start-Service
get-Service -ComputerName seaqasbl19apl01 -Name siebsrvr_SBLQAENT_sblqasrv01 | Start-Service
sleep 60

#Start AI servers
get-Service -ComputerName seaqasbl19wb01 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Start-Service
get-Service -ComputerName seaqasbl19wb02 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Start-Service
get-Service -ComputerName seaqasbl19wb03 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Start-Service
sleep 10

#Start siebel AI StartupType Automatic
get-Service -ComputerName seaqasbl19apl01 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl02 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl03 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl04 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl05 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl06 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl07 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl08 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl09 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl10 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl11 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl12 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19wb01 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19wb02 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19wb03 -Name SiebelApplicationContainer_Siebel_Home_D_sea_ai | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19aplgw -Name SiebelApplicationContainer_Siebel_Home_D_sea_ses | Set-Service -StartupType Automatic
sleep 10

#Start siebel server StartupType Automatic
get-Service -ComputerName seaqasbl19apl01 -Name siebsrvr_SBLQAENT_sblqasrv01 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl02 -Name siebsrvr_SBLQAENT_sblqasrv02 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl03 -Name siebsrvr_SBLQAENT_sblqasrv03 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl04 -Name siebsrvr_SBLQAENT_sblqasrv04 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl05 -Name siebsrvr_SBLQAENT_sblqasrv05 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl06 -Name siebsrvr_SBLQAENT_sblqasrv06 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl07 -Name siebsrvr_SBLQAENT_sblqasrv07 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl08 -Name siebsrvr_SBLQAENT_sblqasrv08 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl09 -Name siebsrvr_SBLQAENT_sblqasrv09 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl10 -Name siebsrvr_SBLQAENT_sblqasrv10 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl11 -Name siebsrvr_SBLQAENT_sblqasrv11 | Set-Service -StartupType Automatic
get-Service -ComputerName seaqasbl19apl12 -Name siebsrvr_SBLQAENT_sblqasrv12 | Set-Service -StartupType Automatic
sleep 05
exit


