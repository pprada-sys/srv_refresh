# -------------------------------------------------------------------------------------------------
# Simple Powershell Script specific for automatic, unattended, scheduled binary REFRESH of
# WebFOCUS Reporting Server and iWay Data Migrator Servers
# Creation Date: 02/09/2020
# Developed by: Paul Prada
# 
#-------------------------------------------------------------------------------------------------

#Setting Variabls 
#Setting Server Name Testing with i8206_742.zip
$BaseDir = "E:\Software\IBI"
#TODO: Read zip file and extract server release and gen from name to use in script
$NewSrvRel = "8206_751"
$ZipFile = "i8206_751.zip"
$EDAHOME = "E:\ibi\srv82\home"
$EDAHOME_GEN = $EDAHOME\"1751"

#Check Status of the target Service
$WFSrv="WebFOCUS 82 Server"

If ($WFSrv | Where-Object Status -eq "Running") 
  {Stop-Service $WFSrv ; Start-Sleep 5 ; Write-Output "Waiting for Service to stop.."} 
 elseif ($WFSrv | Where-Object Status -ne "Stopped") {Write-Output "WebFOCUS is NOT Stopped"; Exit} 

#Start-Sleep -Seconds 5

$Status=Get-Service -Name $WFSrv

$Status
#Checking running Processes 
# Get-Process -Name edapth
# Get-Process -name edapsrv
# Get-Process -Name edap*
# Get-Process -Name tscom*
#  Get-Process -Name js* -IncludeUserName
# Get-Process -Name edapth -IncludeUserName

# #Creating Destination Folder for server disk directory
New-Item -ItemType Directory -Name $NewSrvRel -Path $BaseDir

#Extracting Server file
Expand-Archive -Path $BaseDir\$ZipFile  -DestinationPath $BaseDir\$NewSrvRel

#TODO: Exit Condition if unsuccessful
#Check Extract Operation Status
If ($? -ne "True")  {Exit-PSSession}

#Check New Directory
Get-ChildItem $BaseDir\$NewSrvRel 

#Changing Server Name
Rename-Item -Path $EDAHOME -NewName $EDAHOME_GEN
#Creating back up for home
New-Item -ItemType Directory -Name 

#Run Silent Install
# Start-Process -FilePath $BaseDir\$NewSrvRel\disk1\setup.exe -ArgumentList "-opt $BaseDir\silentrefresh.txt" -RedirectStandardError "PS_levelError.txt"
Write-Output "Running refresh here"
