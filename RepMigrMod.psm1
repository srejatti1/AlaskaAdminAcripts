# DEVELOPER -- IMTIYAZ MOHAMMED
# EMAIL -- IMTIYAZ.MOHAMMED@ALASKAAIR.COM
# THIS MODULE FILE IS USED FOR PROVIDING THE FUNCTIONS COMMON TO ALL THE ADMIN SCRIPTS

# THIS FUNCTION IS USED TO SEND AN EMAIL TO THE ADMIN ON INVOACTION
function Send-Email ($emailSubject, $emailBody)
{	
	$emailSmtpServer = $global:SMTPServer
	$emailFrom = $global:MailFrom
	$emailTo = $global:MailTo
	Send-MailMessage -To $emailTo -From $emailFrom -Subject $emailSubject -Body $emailBody -SmtpServer $emailSmtpServer
}

# THIS FUNCTION IS USED TO SEND AN EMAIL WITH ATTCHMENT TO THE ADMIN ON INVOACTION
function Send-Email-Attachment ($emailSubject, $emailBody, $Attachment1FileName)
{	
	$emailSmtpServer = $global:SMTPServer
	$emailFrom = $global:MailFrom
	$emailTo = $global:MailTo
	Send-MailMessage -To $emailTo -From $emailFrom -Subject $emailSubject -Body $emailBody -SmtpServer $emailSmtpServer -Attachments $Attachment1FileName
}


#THIS FUNCTION IS USED TO STOP/START OR GET STATUS OF THE SERVICES
function Service
	{
		# THE FOLLOWING ARGUMENTS ARE USED WHEN CALLING THIS FUNCTION
		# $ARGS[0] -- OPERATION
		# $ARGS[1] -- SERVICE NAME
		# $ARGS[2] -- SERVER/COMPUTER NAME
		# THIS VARIABLE USED TO RETURN THE SERVICE STATS ON THE REQUESTED COMPUTER
		$returnVar = ""
		# THIS CONDITION IS USED TO FIND THE STATUS OF THE SERVICE ON ANY SERVER AND THIS RETURNS THE STATUS OF THE SERVICE
		if(($args[0] -eq "Status") -or ($args[0] -eq "status"))
			{
				$returnVar = (get-service -ComputerName $args[2] -Name $args[1]).status
				return $returnVar
			}
		# START SERVICE ON CALLED COMPUTER
		if(($args[0] -eq "Start") -or ($args[0] -eq "start"))
			{
				# START $ARGS[1] ON $ARGS[0]
				(get-service -ComputerName $args[2] -Name $args[1]).Start()
			}
		# STOP SERVICE ON CALLED COMPUTER
		if(($args[0] -eq "Stop") -or ($args[0] -eq "stop"))
			{
				# STOP $ARGS[1] ON $ARGS[0]
				(get-service -ComputerName $args[2] -Name $args[1]).Stop()
			}
	}

# THIS FUNCTION CHECKS THE STATUS OF IISADMIN AND W3SVC SERVICE AND STOPS THEM IF THEY ARE IN RUNNING STATE
function stopWebServices
	{
		for($i=1
			$i -le $global:NoOfWebSrvrs
			$i++)
				{
				
				Write-Output "Checking WEB AI service ON $global:WebSrvrName$i"
				$AIStatus = Service "Status" $global:AiSvc $global:WebSrvrName$i
				
					if($AIStatus -eq "Running")
						{
							Write-Output "STOPPING WEB AI SERVICES ON $global:WebSrvrName$i"
							Service "stop" $global:AiSvc $global:WebSrvrName$i 
						}
					else
						{	
							Write-Output "WEB AI SERVICES ON $global:WebSrvrName$i IS ALREADY STOPPED"
							$global:msgBody = $global:msgBody + "WEB AI SERVICES on $global:WebSrvrName$i is not in Running state" + "`n"
						}
				}
	}


		
	
# THIS FUNCTION CHECKS THE STATUS OF IIS AND WWW SERVICE AND STARTS THEM IF THEY ARE IN STOPPED STATE
function startWebServices
{	
for($i=1
	$i -le $global:NoOfWebSrvrs
	$i++)
	{
		$AIStatus = Service "Status" $global:AiSvc $global:WebSrvrName$i
		
		if($AIStatus -eq "Stopped")
			{
				Write-Output "STARTING WEB AI SERVICES ON $global:WebSrvrName$i"
				Service "start" $global:AiSvc $global:WebSrvrName$i
			}
			else
			{	
				Write-Output "WEB AI SERVICES ON $global:WebSrvrName$i IS ALREADY STARTED"
				$global:msgBody = $global:msgBody + "WEB AI SERVICES on $global:WebSrvrName$i is in Running state" + "`n"
			}
	}
}

#THIS FUNCTION IS USED TO CHECK THE STATUS OF THE WEB AI SERVICES
function validateRestartWebServices
{
	for($i=1
		$i -le $global:NoOfWebSrvrs
		$i++){
			# CHECKING THE STATUS OF WEB SERVER AND SEND AN EMAIL TO THE ADMIN
			$AIStatus = Service "status" $global:AiSvc $global:WebSrvrName$i
			$global:msgBody = $global:msgBody + "$global:WebSrvrName$i, WEB AI service status" + "`n"
			$global:msgBody = $global:msgBody + "$global:AiSvc, $AIStatus" + "`n"
			Write-Output "$global:WebSrvrName$i, WEB AI services status" 
			Write-Output "WEB AI, $AIStatus" 
			}
}

#THIS FUNCTION IS USED TO STOP THE SES TOMCAT SERVICE
function stopSESServices
	{
	for($i=1
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
				{
					$j = "0"+$i
				}
			else
				{
					$j = $i
				}
			# CHECK TOMCAT SES STATUS
			Write-Output "Checking Tomcat SES service ON  $global:SiebSrvrName$j"
			$SESStatus = Service "Status" $global:SesSvc $global:SiebSrvrName$j				
					if($SESStatus -eq "Running")
						{
							Write-Output "STOPPING TOMCAT SES ON $global:SiebSrvrName$i"
							Service "stop" $global:SesSvc $global:SiebSrvrName$j 
						}
					else
						{	
							Write-Output "SES TOMCAT SES ON $global:SiebSrvrName$j IS ALREADY STOPPED"
							$global:msgBody = $global:msgBody + " SiebelApplicationContainer_Siebel_Home_D_sea_ses Service on $global:SiebSrvrName$j is not in Running state" + "`n"
						}
			}
		}
			
# THIS FUNCTION IS USED TO STOP THE GATEWAY REGISTRY SERVICES	
function stopGtwyServices
{

	Write-Output "Checking gtwyns Service Status"					
	$GtwyStatus = Service "Status" "gtwyns" $Gateway
	if($GtwyStatus -eq "Running")
		{
			Write-Output "STOPPING gtwyns on $Gateway"
			Service "stop" "gtwyns" $Gateway
		}
	else
		{	
			Write-Output "gtwyns on  $Gateway IS ALREADY STOPPED"
			$global:msgBody = $global:msgBody + "gtwyns on $Gateway is not in Running state" + "`n"
		
		}
	}
#THIS FUNCTION IS USED TO STOP THE GATEWAY SES SERVICE
function stopGtwySESServices
{

	Write-Output "Checking $Gateway SES SERVICE Status"

	# CHECK TOMCAT SES STATUS
	$TomcatGtwyStatus = Service "Status" $global:SesSvc $Gateway				
	if($TomcatGtwyStatus -eq "Running")
		{
			Write-Output "STOPPING TOMCAT SES ON $Gateway"
			Service "stop" $global:SesSvc $Gateway
		}
	else
		{	
			Write-Output "TOMCAT SES ON $Gateway IS ALREADY STOPPED"
			$global:msgBody = $global:msgBody + "TOMCAT SES on $Gateway is not in Running state" + "`n"
		}
}

#THIS FUNCTION IS USED TO START THE GATEWAY SERVICE	
function startGtwyServices
{
	Write-Output "Checking gtwyns Service Status"					
	$GtwyStatus = Service "Status" "gtwyns" $Gateway
	if($GtwyStatus -eq "Stopped")
		{
			Write-Output "Starting gtwyns on $Gateway"
			Service "start" "gtwyns" $Gateway
		}
	else
		{	
			Write-Output "gtwyns on  $Gateway IS ALREADY RUNNING"
			$global:msgBody = $global:msgBody + "gtwyns on $Gateway is in Running state" + "`n"
		}
}	


#THIS FUNCTION IS USED TO START THE SES TOMCAT SERVICE ON GATEWAY
function startGtwySESServices
{	
		Write-Output "Checking $Gateway SES SERVICE Status"
		
		# CHECK TOMCAT SES STATUS
		$TomcatGtwyStatus = Service "Status" $global:SesSvc $Gateway
		
		if($TomcatGtwyStatus -eq "Stopped")
			{
			Write-Output "Starting TOMCAT SES ON $Gateway"
			Service "start" $global:SesSvc $Gateway
		}
	else
		{	
			Write-Output "TOMCAT SES ON $Gateway IS ALREADY RUNNING"
			$global:msgBody = $global:msgBody + "TOMCAT SES on $Gateway is not in Running state" + "`n"
		}
}

#THIS FUNCTION IS USED TO START THE SES TOMCAT SERVICE ON SIEB SERVERS
function startSESServices
{
		for($i=1
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
				{
					$j = "0"+$i
				}
			else
				{
					$j = $i
				}
			# CHECK TOMCAT SES STATUS
			$SESStatus = Service "Status" $global:SesSvc $global:SiebSrvrName$j				
			if($SESStatus -eq "Stopped")
				{
					Write-Output "STARTING TOMCAT SES SERVICES ON $global:SiebSrvrName$j"
					Service "start" $global:SesSvc $global:SiebSrvrName$j 
				}
			}
}
# THIS FUNCTION IS USED TO VALIDATE THE STATUS OF ALL THE SES SERVICES
function validateSESServices ($Operation)
	{
	
	# $Operation = $args[0]
	Write-Output "VALIDATING IF ALL THE TOMCAT SES SERVICES ARE $Operation"
	$global:ServiceValidation = "True"
	for($i=1
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
				{
					$j = "0"+$i
				}
			else
				{
					$j = $i
				}
			# CHECK TOMCAT SES STATUS
			$SESStatus = Service "Status" $global:SesSvc $global:SiebSrvrName$j				
				if(($SESStatus -ne $Operation))
				{
					Write-Output "TOMCAT SES IS NOT $Operation ON $global:SiebSrvrName$j"
					$global:ServiceValidation = "False"
				}
			}
			
	}
	
	# THIS FUNCTION IS USED TO VALIDATE THE STATUS OF GATEWAY SES SERVICES
function validateGatewaySESServices ($Operation)
{
	
	Write-Output "VALIDATING THE SES SERVICE on GATEWAY ARE $Operation"
	$global:ServiceValidation =  "True"
	
	#CHECKING THE STATUS OF SES
	$TomcatGtwyStatus = Service "Status" $global:SesSvc $global:Gateway
	if(($TomcatGtwyStatus -ne $Operation))
	
	{
		Write-Output "TOMCAT SES SERVICES IS NOT $Operation ON $global:Gateway"
		$global:ServiceValidation = "False"
	}
				
}
	# THIS FUNCTION IS USED TO VALIDATE THE STATUS OF GATEWAY REGISTRY SERVICES
function validateGatewayServices ($Operation)
{
	
	Write-Output "VALIDATING THE GATEWAY SERVICE ARE $Operation"
	$global:ServiceValidation =  "True"
	
	#CHECKING THE STATUS OF SES
	$GtwyStatus = Service "Status" "gtwyns" $global:Gateway
	if(($GtwyStatus -ne $Operation))
	
	{
		Write-Output "GATEWAY SERVICE IS NOT $Operation ON $global:Gateway"
		$global:ServiceValidation = "False"
	}
				
}

#THIS FUNCTION IS USED TO STOP THE SIEBEL SERVICE
function stopSiebelServices
	{
		for($i=1
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
				{
					$j = "0"+$i
				}
			else
				{
					$j = $i
				}
			# CHECK SIEBEL SERVER STATUS
			Write-Output "Checking SIEBEL service ON $global:SvcName$j $global:SiebSrvrName$j"
			$siebStatus = Service "status" $global:SvcName$j $global:SiebSrvrName$j
			# STOP SIEBEL SERVICES IF THEY ARE IN RUNNING STATE
			if($siebStatus -eq "Running")
				{
					# STOP SIEBEL SERVER SERVICE
					Write-Output "STOPPING $global:SvcName$j ON $global:SiebSrvrName$j"
					Service "stop" $global:SvcName$j $global:SiebSrvrName$j
				}
				else
				{
					# SEND AN EMAIL TO THE ADMIN IF THE SIEBEL SERVER SERVICE IS ALREADY STOPPED
					Write-Output "$global:SvcName$j ON $global:SiebSrvrName$j IS ALREADY STOPPED"
					$global:msgBody = $global:msgBody + "$global:SvcName$j Service on $global:SiebSrvrName$j is not in Running state" + "`n"
				}
			}
	}
	
#THIS FUNCTION IS USED TO START THE SIEBEL SERVER SERVICE
function startSiebelServices
{
for($i=1
	$i -le $global:NoOfSiebSrvrs
	$i++)
	{
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
			{
				$j = "0"+$i
			}
			else
			{
				$j = $i
			}
			# check if the siebel server is in stopped state or not
			# check siebel server status
			$siebStatus = Service "status" $global:SvcName$j $global:SiebSrvrName$j
			# start siebel services if they are in stopped state
			if($siebStatus -eq "Stopped")
			{
				# START SIEBEL SERVER SERVICE
				Write-Output "STARTING $global:SvcName$j ON $global:SiebSrvrName$j"
				Service "start" $global:SvcName$j $global:SiebSrvrName$j
			}
		else{
				Write-Output "$global:SvcName$j ON $global:SiebSrvrName$j IS ALREADY RUNNING"
				$global:msgBody = $global:msgBody + "FAILED TO START $global:SvcName$j SERVICE ON $global:SiebSrvrName$j AS THE SERVICE IS NOT IN Stopped STATE" + "`n"
			}
	}
}
#THIS FUNCTION IS USED TO CHECK THE STATUS THE SIEBEL SERVER SERVICES
function validateRestartSiebelServices
{	
	for($i=1
		$i -le $global:NoOfSiebSrvrs
		$i++){
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
				{
					$j = "0"+$i
				}
			else
				{
					$j = $i
				}
				# CHECK SIEBEL SERVER STATUS
				$siebStatus = Service "status" $global:SvcName$j $global:SiebSrvrName$j
				# SEND AN EMAIL TO THE ADMIN
				$global:msgBody = $global:msgBody + "$global:SiebSrvrName$j, $global:SvcName$j, $siebStatus" + "`n"
				Write-Output "$global:SiebSrvrName$j, $global:SvcName$j, $siebStatus"
			}
}

# THIS FUNCTION IS USED TO VALIDATE IF ALL THE WEBSERVICES ARE DOWN
function validateWebServices ($Operation)
{		
		# $Operation = $args[0]
		Write-Output "VALIDATING IF ALL ALL THE TOMCAT AI ARE $Operation"
		$global:ServiceValidation = "True"
		for($i=1
			$i -le $global:NoOfWebSrvrs
			$i++)
			{
				# CHECKING THE STATUS OF WEB SERVER AND SEND AN EMAIL TO THE ADMIN
				$AIStatus = Service "status" $global:AiSvc $global:WebSrvrName$i
				if(($AIStatus -ne $Operation))
				{
					Write-Output "WEB AI SERVICE IS NOT $Operation ON $global:WebSrvrName$i"
					$global:ServiceValidation = "False"
				}
			}
}
# THIS FUNCTION IS USED TO VALIDATE IF ALL THE SIEBEL SERVICES ARE DOWN
function validateSiebelServices ($Operation)
{	
		# $Operation = $args[0]
		$global:ServiceValidation = "True"
		Write-Output "VALIDATING IF ALL THE SIEBEL SERVICES ARE $Operation"
		for($i=1
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
				if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
					{
						$j = "0"+$i
					}
				else
					{
						$j = $i
					}
				# CHECK SIEBEL SERVER STATUS
				$returnVar = (get-service -ComputerName $global:SiebSrvrName$j -Name $global:SvcName$j).status
				if($returnVar -eq $Operation)
					{
						continue
					}
				else
					{
						$global:ServiceValidation = "False"
						Write-Output "SIEBEL SERVICE IS NOT $Operation ON $global:SiebSrvrName$j"
					}
			}
}

function validateSiebelRestServices ($Operation)
{	
		# $Operation = $args[0]
		$global:ServiceValidation = "True"
		Write-Output "VALIDATING IF ALL THE SIEBEL SERVICES ARE $Operation"
		for($i=9
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
				if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
					{
						$j = "0"+$i
					}
				else
					{
						$j = $i
					}
				# CHECK SIEBEL SERVER STATUS
				$returnVar = (get-service -ComputerName $global:SiebSrvrName$j -Name $global:SvcName$j).status
				if($returnVar -eq $Operation)
					{
						continue
					}
				else
					{
						$global:ServiceValidation = "False"
						Write-Output "SIEBEL SERVICE IS NOT $Operation ON $global:SiebSrvrName$j"
					}
			}
}