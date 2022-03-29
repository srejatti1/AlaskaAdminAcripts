D:
cd D:\sea\ses\gtwysrvr\zookeeper\

Robocopy version-2 D:\sea\ses\gtwysrvr\zookeeper\version2bkp\version-2_$(Get-Date -format "yyyyMMdd_hhmmss") >> D:\sea\ses\gtwysrvr\zookeeper\version2bkp\version2bkp_$(Get-Date -format "yyyyMMdd_hhmmss").cfg
sleep 05
exit