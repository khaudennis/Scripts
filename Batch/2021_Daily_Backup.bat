@echo off
REM Batch script used with Task Scheduler to archive/backup data
REM Source and Destination should omit trailing slash

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "datestamp=%YYYY%%MM%%DD%"

echo. >"X:\Archive\Logs\%datestamp%.txt"

robocopy "\\SOURCE\FOLDER" "DESTINATION_DRIVE:" /R:1 /TEE /Log:DESTINATION_DRIVE:\Logs\copy_log.txt