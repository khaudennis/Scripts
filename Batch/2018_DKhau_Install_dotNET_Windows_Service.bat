REM Installs a Windows Service utilizing the InstallUtil helper executable.
REM Dennis Khau, 2018
@echo off

set frameworkDirectory="C:\Windows\Microsoft.NET\Framework64\v4.0.30319"

IF [%1] == [] GOTO InvalidParam
::ELSE
GOTO Init

IF [%2] == [] GOTO InvalidParam
::ELSE
GOTO Init
	
:Init
SET originDir=%1
SET destinationDir=%2

REM Check for .NET Framework
IF NOT EXIST %frameworkDirectory% GOTO NoFramework
cd %frameworkDirectory%

REM Uninstall Existing Service
sc.exe STOP "Windows Service"
installutil.exe /u "%destinationDir%\Windows_Service.exe"

REM Check for Destination Exists
IF NOT EXIST %destinationDir% GOTO NoDestination

:InitContinue
REM Create Backup
cd %destinationDir%
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set currentDate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set currentTime=%%a%%b)
robocopy %destinationDir% "..\_Backup\%currentDate%_%currentTime%" /E /PURGE

REM Copy New Service to Existing Directory (excluding the Configuration XML)
robocopy %originDir% %destinationDir% /E /PURGE /XF "%originDir%\Windows_Service.exe.config"

REM Point to .NET Framework, Install and Start the Service
cd %frameworkDirectory%
installutil.exe "%destinationDir%\Windows_Service.exe"
net start "Windows_Service"

exit /b 0

:InvalidParam
	echo PARAMETER REQUIRED. Call the script and provide the following params: [SCRIPT_NAME].bat [SOURCE_URI] [DESTINATION_URI]
	exit /b 1
	
:NoFramework
	echo No .NET Framework detected.
	exit /b 1

:NoDestination
	echo Destination folder does not exist.
	mkdir %destinationDir%
	GOTO InitContinue