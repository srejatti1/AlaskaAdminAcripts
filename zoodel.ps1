Get-ChildItem –Path "D:\sea\ses\gtwysrvr\zookeeper\version2bkp" -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-15))} | Remove-Item -Recurse -Force -Confirm:$false
exit