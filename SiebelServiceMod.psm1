# DEVELOPER -- Shantan Polepally
# EMAIL -- Shantan.Polepally@ALASKAAIR.COM
# THIS MODULE FILE IS USED FOR PROVIDING THE FUNCTIONS COMMON TO ALL THE ADMIN SCRIPTS 

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

# THIS FUNCTION CHECKS THE STATUS OF TOMCAT AI SERVICE AND STOPS IT IF IT IS IN RUNNING STATE
function stopWebServices
	{
		$srvno = [int]$global:SiebSrvrNumber
		for($i=1
			$i -le $global:NoOfWebSrvrs
			$i++)
				{

				Write-Output "Checking tomcat AI service ON $global:WebSrvrName$srvno"
				$AIStatus = Service "Status" $global:AiSvc $global:WebSrvrName$srvno
				if($AIStatus -eq "Running")
						{
							Write-Output "STOPPING tomcat AI service ON $global:WebSrvrName$srvno"
							Service "stop" $global:AiSvc $global:WebSrvrName$srvno 
						}
					else
						{	
							Write-Output "Tomcat AI service ON $global:WebSrvrName$srvno IS ALREADY STOPPED"
							$global:msgBody = $global:msgBody + "Tomcat AI service on $global:WebSrvrName$srvno is not in Running state" + "`n"
						}
						$srvno++
				}
	}
		
	
# THIS FUNCTION CHECKS THE STATUS OF TOMCAT AI SERVICE AND STARTS IT IF IT IS IN STOPPED STATE
function startWebServices
{
$srvno = [int]$global:SiebSrvrNumber	
for($i=1
	$i -le $global:NoOfWebSrvrs
	$i++)
	{
		$AIStatus = Service "Status" $global:AiSvc $global:WebSrvrName$srvno
		if($AIStatus -eq "Stopped")
			{
				Write-Output "STARTING TOMCAT AI SERVICE ON $global:WebSrvrName$srvno"
				Service "start" $global:AiSvc $global:WebSrvrName$srvno
			}
		$srvno++
	}
}

#THIS FUNCTION IS USED TO CHECK THE STATUS OF THE IISADMIN AND W3SVC
function validateRestartWebServices
{
	$srvno = [int]$global:SiebSrvrNumber	
	for($i=1
		$i -le $global:NoOfWebSrvrs
		$i++){
			# CHECKING THE STATUS OF AI SERVICE AND SEND AN EMAIL TO THE ADMIN
			$AIStatus = Service "status" $global:AiSvc $global:WebSrvrName$srvno
			$global:msgBody = $global:msgBody + "$global:WebSrvrName$i, AI SERVICE status" + "`n"
			$global:msgBody = $global:msgBody + "AI SERVICE, $AIStatus" + "`n"
			Write-Output "$global:WebSrvrName$srvno, TOMCAT AI services status" 
			Write-Output "AI SERVICE, $AIStatus" 
			}
			$srvno++
}

#THIS FUNCTION IS USED TO STOP THE SIEBEL SERVER SERVICE
function stopSiebelServices
	{
		$srvno = [int]$global:SiebSrvrNumber	
		for($i=1
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
				{
					$j = $srvno
				}
			else
				{
					$j = $srvno
				}
			# CHECK SIEBEL SERVER STATUS
			Write-Output "Checking Siebel service ON $global:SvcName$j $global:SiebSrvrName$j"
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
				$srvno++
			}
	}
	
#This function is used to start the Siebel Server service
function startSiebelServices
{
	$srvno = [int]$global:SiebSrvrNumber	
for($i=1
	$i -le $global:NoOfSiebSrvrs
	$i++)
	{
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
			{
				$j = $srvno
			}
			else
			{
				$j = $srvno
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
			$srvno++
	}
}
#This function is used to check the status the Siebel Server services
function validateRestartSiebelServices
{	
	$srvno = [int]$global:SiebSrvrNumber	
	for($i=1
		$i -le $global:NoOfSiebSrvrs
		$i++){
			if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
				{
					$j = $srvno
				}
			else
				{
					$j = $srvno
				}
				# check siebel server status
				$siebStatus = Service "status" $global:SvcName$j $global:SiebSrvrName$j
				# send an email to the admin
				$global:msgBody = $global:msgBody + "$global:SiebSrvrName$j, $global:SvcName$j, $siebStatus" + "`n"
				Write-Output "$global:SiebSrvrName$j, $global:SvcName$j, $siebStatus"
				$srvno++
			}
}

# THIS FUNCTION IS USED TO VALIDATE THE STATUS OF ALL THE WEBSERVICES
function validateWebServices ($Operation)
{		
		# $Operation = $args[0]
		Write-Output "VALIDATING IF ALL THE TOMCAT AI SERVICES ARE $Operation"
		$global:ServiceValidation = "True"
		$srvno = [int]$global:SiebSrvrNumber
		for($i=1
			$i -le $global:NoOfWebSrvrs
			$i++)
			{
				# CHECKING THE STATUS OF WEB SERVER AND SEND AN EMAIL TO THE ADMIN
				$AIStatus = Service "status" $global:AiSvc $global:WebSrvrName$srvno
				if(($AIStatus -ne $Operation))
				{
					Write-Output "TOMCAT AI SERVICE IS NOT $Operation ON $global:WebSrvrName$srvno"
					$global:ServiceValidation = "False"
				}
			$srvno++
			}
}

function validateSiebelServices ($Operation)
{	
		# $Operation = $args[0]
		$global:ServiceValidation = "True"
		$srvno = [int]$global:SiebSrvrNumber	
		Write-Output "VALIDATING IF ALL THE SIEBEL SERVICES ARE $Operation"
		for($i=1
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
				if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
					{
						$j = $srvno
					}
				else
					{
						$j = $srvno
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
			$srvno++
			}
}

#This function is used to start the SES tomcat service
function startSESServices
{
$srvno = [int]$global:SiebSrvrNumber		
for($i=1
	$i -le $global:NoOfSiebSrvrs
	$i++)
	{
		if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
					{
						$j = $srvno
					}
				else
					{
						$j = $srvno
					}
		$SESStatus = Service "Status" $global:SesSvc $global:SiebSrvrName$j
		if($SESStatus -eq "Stopped")
			{
				Write-Output "STARTING TOMCAT SES SERVICE ON $global:SiebSrvrName$j"
				Service "start" $global:SesSvc $global:SiebSrvrName$j
			}
		$srvno++
	}
}

#This function is used to stop the SES tomcat service
function stopSESServices
{
$srvno = [int]$global:SiebSrvrNumber		
for($i=1
	$i -le $global:NoOfSiebSrvrs
	$i++)
	{
		if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
					{
						$j = $srvno
					}
				else
					{
						$j = $srvno
					}
		Write-Output "Checking Tomcat SES service ON  $global:SiebSrvrName$j"
		$SESStatus = Service "Status" $global:SesSvc $global:SiebSrvrName$j
		if($SESStatus -eq "Running")
			{
				Write-Output "STOPPING TOMCAT SES SERVICE ON $global:SiebSrvrName$j"
				Service "stop" $global:SesSvc $global:SiebSrvrName$j
			}
		else
			{
				# SEND AN EMAIL TO THE ADMIN IF THE SIEBEL SERVER SERVICE IS ALREADY STOPPED
				Write-Output "SES TOMCAT SERVICE ON $global:SiebSrvrName$j IS ALREADY STOPPED"
				$global:msgBody = $global:msgBody + "$global:SesSvc Service on $global:SiebSrvrName$j is not in Running state" + "`n"
			}
		 $srvno++
	}
}

# THIS FUNCTION IS USED TO VALIDATE THE STATUS OF ALL THE SES SERVICES
function validateSESServices ($Operation)
{		
		# $Operation = $args[0]
		Write-Output "VALIDATING IF ALL THE  TOMCAT SES SERVICES  ARE $Operation"
		$srvno = [int]$global:SiebSrvrNumber	
		$global:ServiceValidation = "True"
		for($i=1
			$i -le $global:NoOfSiebSrvrs
			$i++)
			{
				if(($i -le 9) -and ($global:NoOfSiebSrvrs -gt 1))
					{
						$j = $srvno
					}
				else
					{
						$j = $srvno
					}
				# CHECKING THE STATUS OF SES AND SEND AN EMAIL TO THE ADMIN
				$SESStatus = Service "Status" $global:SesSvc $global:SiebSrvrName$j
				if(($SESStatus -ne $Operation))
				{
					Write-Output "TOMCAT SES SERVICE IS NOT $Operation ON $global:SiebSrvrName$j"
					$global:ServiceValidation = "False"
				}
			$srvno++
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

	

