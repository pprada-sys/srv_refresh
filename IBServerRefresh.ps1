﻿# Simple Powershell Script specific for automatic, unattended, scheduled binary refresh/upgrade of
# WebFOCUS Reporting Server and iWay Data Migrator Servers

#Setting Server Name Testing with i8206_742.zip
$BaseDir = "E:\Software\IBI\"
$NewSrvRel = "8206_742"
$ZipFile = "i8206_742.zip"

#TODO: Getting Server Parm from input for upgrade. For now creating statically with 8206_742

#Creating Destination Folder for server disk directory
New-Item -ItemType Directory -Name $NewSrvRel -Path $BaseDir

#Extracting Server file
Expand-Archive -Path $BaseDir\$ZipFile  -DestinationPath $BaseDir\$NewSrvRel

#Check Extract Operation Status
$?

#Check New Directory
Get-ChildItem $BaseDir\$NewSrvRel 

#Run Silent Install
Start-Process -FilePath $BaseDir\$NewSrvRel\disk1\setup.exe -ArgumentList -L0x409 -opt $BaseDir\silentinst.txt -RedirectStandardError "PS_levelError.txt"
