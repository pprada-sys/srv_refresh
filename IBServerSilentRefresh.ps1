<#
 Simple Powershell Script specific for automatic, unattended, scheduled binary REFRESH of
 WebFOCUS Reporting Server and iWay Data Migrator Servers
 Creation Date: 02/09/2020
 Developed by: Paul Prada
 
 02.18.2020 Added Post Refresh start up and post start checks 
 02.15.2020 Resolved directory issues. script running successfully up to Refreshing point
 02.14.2020 Adding main structure after proof of concept tests
#>

#---- Step 1 collect zip extract, check and prep install directory
#Accept Parameter argument for zip file to refresh to
param([string] $ZipFile) 

#Set Locations of Refres install
$SWDir = "E:\Software\IBI"
$TmpExtractDir = "tmp_dir"

#Checkpoint
$ZipFileExists = Test-Path -Path $SWDir\$ZipFile
If($ZipFileExists -ne "True") {Write-Output "No ZipFile.. Exiting"; EXIT} else {Write-Output "Good file Continue.."}

#Creating Destination Folder for server disk directory
New-Item -ItemType Directory -Name $TmpExtractDir -Path $SWDir

#Extracting Server file
Expand-Archive -Path $SWDir\$ZipFile  -DestinationPath $SWDIR\$TmpExtractDir

#Another checkpoint for existance of New version.cfg
$VersionFileExists = Test-Path -Path $SWDir\$TmpExtractDir\disk1\version.cfg
If($VersionFileExists -ne "True") {Write-Output "No Version File.. Exiting"; EXIT} 
  else {Write-Output "Good file Continue.."}

#Read New version.cfg and pull out Release and Gen for edahome rename value 
$NewRel1 = @(Get-Content -Path $SWDIR\$TmpExtractDir\disk1\version.cfg | Select-String "irel" | ForEach-Object {$_ -split" "})
$NewRel = $NewRel1[2]

$NewGen1 = @(Get-Content -Path $SWDIR\$TmpExtractDir\disk1\version.cfg | Select-String "gen_num" | ForEach-Object {$_ -split" "})
$NewGen = $NewGen1[2]

$NewRel
$NewGen

#Rename tmp_directory before running refresh
Rename-Item -Path $SWDIR\$TmpExtractDir -NewName $SWDIR\$NewRel"_"$NewGen
If ($? -ne "True")  {Exit}


#---- Step 2 Check Server and stop and Prep the backup directory
#Check Status of the target Service and stopping for Refresh
$WFSrv="WebFOCUS 82 Server"

If (Get-Service -Name $WFSrv | Where-Object Status -eq "Running") 
  {Stop-Service -Name $WFSrv ; Start-Sleep 5 ; Write-Output "Waiting for Service to stop.."} 
 elseif ($WFSrv | Where-Object Status -ne "Stopped") {Write-Output "WebFOCUS is NOT Stopped"; Exit} 

#Setting static EDAHOME to be upgraded. Should not change but may need switch logic for DM vs WF
$EHOMEDir = "E:\ibi\srv82"
$EHOME = "home"

#Renaming Old existing EDAHOME to add Gen level for backup
Rename-Item -Path $EHOMEDir\$EHOME -NewName $EHOMEDir\$EHOME"_"$NewGen 

#Creating New Fake EDAHOME to be installed over
New-Item -ItemType Directory -Name $EHOME -Path $EHOMEDir

#Create New Fake etc directory in Fake EDAHOME
New-Item -ItemType Directory -Name "etc" -Path $EHOMEDir\$EHOME

#Copy original version.cfg to fake home
Copy-Item -Path $EHOMEDir\$EHOME"_"$NewGen\etc\version.cfg -Destination $EHOMEDir\$EHOME\etc

#Another checkpoint
$FakeEHOMEDirExists = Test-Path -Path $EHOMEDir\$EHOME"_"$NewGen
If($FakeEHOMEDirExists -ne "True") {Write-Output "FakeDirectory not foudn .. Exiting"; EXIT} 
  else {Write-Output "Good Directory Continue.."}

#--- Step 3 Run unattended Refresh
#Run Silent Install
Start-Process -FilePath $SWDIR\$NewRel"_"$NewGen\disk1\setup.exe -ArgumentList "-L0x409 -opt $SWDIR\silentrefresh.txt" -RedirectStandardError "PS_levelError.txt"
Write-Output "Running refresh..."

#TODO Find, copy and check inu.log for good refresh status

Start-Sleep 480

#--- Step 4 Start Server and check isetup and edaprint logs 
Start-Service -Name $WFSrv ; Start-sleep 5 ; Write-output "Starting Server...waiting 5 seconds.."

Start-Sleep 10

$EprintExists = Test-Path -Path $EHOMEDir\wfs\edaprint.log
If($EprintExists -ne "True") {Write-Output "Something's wrong.."; Write-Output " Reversing.."}

#Checking Status of Reporting Server 
$EPrint = "edaprint.log"
$EPstring = "Workspace Initialization", "Gen Number:","Release:","listening"

ForEach ($estring in $EPstring) 
  {
    Get-Content -Path $EHOMEDir\wfs\$EPrint | Select-String $estring

}

Exit
