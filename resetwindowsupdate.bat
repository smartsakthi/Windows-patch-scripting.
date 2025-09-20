@echo off
:: Check for admin rights by trying to create a folder in %windir%
>nul 2>&1 "%SYSTEMROOT%\System32\cacls.exe" "%SYSTEMROOT%\System32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~fs0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

#admin code

echo ---------------------------------------------
echo Stopping Windows Update related services wait a second...
echo ---------------------------------------------
net stop wuauserv /y
net stop usosvc /y
net stop bits /y
net stop cryptsvc /y
net stop msiserver /y

echo ---------------------------------------------
echo Deleting Windows Update history and cache...
echo ---------------------------------------------
echo renaming SoftwareDistribution and catroot2 folders...
ren c:\Windows\SoftwareDistribution SoftwareDistribution.old
ren c:\Windows\System32\catroot2 Catroot2.old

del /f "C:\Windows\Winsxs\*.xml"
del /f /s "C:\Windows\Installer\$PatchCache$\*.*"
del /f /s /q %windir%\SoftwareDistribution\DataStore\*.*
del /f /s /q %windir%\SoftwareDistribution\DataStore\Logs\edb.log
del /f /s /q %windir%\SoftwareDistribution\DataStore\Logs\*.*
del /f /s /q "C:\ProgramData\USOPrivate\UpdateStore\*.*" 
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*.*"
del /f /q "C:\Windows\SoftwareDistribution\Download\*.*"

echo Delete the completed SoftwareDistribution folder

del /f /q "C:\Windows\SoftwareDistribution\*.*"


del /s /q /f "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat" del /s /q /f "%ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat"


del /q /s /f "C:\Windows\SoftwareDistribution\DataStore*"
for /d %%p IN ("C:\Windows\SoftwareDistribution\DataStore\*.*") DO rmdir "%%p" /s /q

del /q /s /f "C:\Windows\SoftwareDistribution\Download*"
for /d %%p IN ("C:\Windows\SoftwareDistribution\Download\*.*") DO rmdir "%%p" /s /q


echo ==========================================
echo Deleting Pending Updates wait a second (if any)...
echo ==========================================
del /f /s /q "%windir%\WinSxS\pending.xml" >nul 2>&1
del /f /s /q "%windir%\WinSxS\cleanup.xml" >nul 2>&1
del /f /s /q "%windir%\SoftwareDistribution\DataStore\DataStore.edb" >nul 2>&1
 
echo ==========================================
echo Clearing Windows Update Downloaded Packages...
echo ==========================================
del /f /s /q "%windir%\SoftwareDistribution\Download\*.*" >nul 2>&1
 
echo ==========================================
echo Resetting Update History Registry Keys...
echo ==========================================
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\UX\Settings" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy" /f >nul 2>&1

echo delet xml files

:Reset
Ipconfig /flushdns
del /s /q /f "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat" del /s /q /f "%ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat"

cd /d %windir%\system32

if exist "%SYSTEMROOT%\winsxs\pending.xml.bak" del /s /q /f "%SYSTEMROOT%\winsxs\pending.xml.bak" 
if exist "%SYSTEMROOT%\winsxs\pending.xml" ( 
    takeown /f "%SYSTEMROOT%\winsxs\pending.xml" 
    attrib -r -s -h /s /d "%SYSTEMROOT%\winsxs\pending.xml" 
    ren "%SYSTEMROOT%\winsxs\pending.xml" pending.xml.bak 
) 
  
if exist "%SYSTEMROOT%\SoftwareDistribution.bak" rmdir /s /q "%SYSTEMROOT%\SoftwareDistribution.bak"
if exist "%SYSTEMROOT%\SoftwareDistribution" ( 
    attrib -r -s -h /s /d "%SYSTEMROOT%\SoftwareDistribution" 
    ren "%SYSTEMROOT%\SoftwareDistribution" SoftwareDistribution.bak 
) 
 
if exist "%SYSTEMROOT%\system32\Catroot2.bak" rmdir /s /q "%SYSTEMROOT%\system32\Catroot2.bak" 
if exist "%SYSTEMROOT%\system32\Catroot2" ( 
    attrib -r -s -h /s /d "%SYSTEMROOT%\system32\Catroot2" 
    ren "%SYSTEMROOT%\system32\Catroot2" Catroot2.bak 
) 
  
if exist "%SYSTEMROOT%\WindowsUpdate.log.bak" del /s /q /f "%SYSTEMROOT%\WindowsUpdate.log.bak" 
if exist "%SYSTEMROOT%\WindowsUpdate.log" ( 
    attrib -r -s -h /s /d "%SYSTEMROOT%\WindowsUpdate.log" 
    ren "%SYSTEMROOT%\WindowsUpdate.log" WindowsUpdate.log.bak 
) 
  
echo Registering DLLs...
cd /d %windir%\system32
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll 
regsvr32.exe /s wucltux.dll
regsvr32.exe /s wups.dll
echo Registering DLLs...
cd /d %windir%\system32
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll 
regsvr32.exe /s wucltux.dll

regsvr32.exe /s wups2.dll
regsvr32.exe /s wuwebv.dll
 
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
echo Registering DLLs...
cd /d %windir%\system32
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll 
regsvr32.exe /s wucltux.dll

regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml2.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll

echo ---------------------------------------------
echo Restarting services... wait a sec
echo ---------------------------------------------
net start wuauserv
net start usosvc
net start bits
net start cryptsvc
net start msiserver



echo ---------------------------------------------
echo Update history has been reset. please restart your system !

pause




