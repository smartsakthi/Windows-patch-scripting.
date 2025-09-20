@echo off
echo Initiating Windows Update check...
 
REM This command triggers a scan for updates.
REM The "ScanInstallWait" parameter ensures that if updates are found,
REM they will be downloaded and installed (if configured to do so automatically).

UsoClient.exe StartInteractiveScan

echo Windows Update check initiated.

pause