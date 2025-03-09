@echo off
setlocal enabledelayedexpansion

echo *************************
echo Adobe Creative Cloud Apps Panel Fix Tool
echo *************************
echo.

:: Define paths - Windows version
set "XML_PATH=%ProgramFiles(x86)%\Common Files\Adobe\OOBE\Configs\ServiceConfig.xml"
set "CC_APP=%ProgramFiles(x86)%\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe"

:: Check if Creative Cloud app exists
if not exist "!CC_APP!" (
    echo [WARNING] Could not find Adobe Creative Cloud at the expected location:
    echo !CC_APP!
    echo The Adobe software might be installed in a different location.
    echo Aborting - no changes were made
    echo.
    echo *************************
    exit /b 1
)

:: Check if the XML config exists
if not exist "!XML_PATH!" (
    echo [WARNING] Could not find the Adobe configuration file:
    echo !XML_PATH!
    echo The Adobe software might be using a different configuration.
    echo Aborting - no changes were made
    echo.
    echo *************************
    exit /b 1
)

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This tool needs administrative privileges to modify Adobe settings.
    echo.
    echo Attempting to restart with elevated privileges...
    echo If a User Account Control prompt appears, please click "Yes".
    echo.
    
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo [OK] Administrative privileges acquired

:: Create a backup with timestamp
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set DATESTAMP=%%c%%a%%b)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (set TIMESTAMP=%%a%%b)
set "BACKUP_PATH=!XML_PATH!.bak-!DATESTAMP!-!TIMESTAMP!"

copy "!XML_PATH!" "!BACKUP_PATH!" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Failed to make a backup copy of the configuration file
    echo Aborting - no changes were made
    echo.
    echo *************************
    exit /b 1
)

echo [OK] Created backup of the configuration file:
echo Original: !XML_PATH!
echo Backup:   !BACKUP_PATH!
echo (If something goes wrong, you can restore from the backup manually)
echo.

:: Use PowerShell to handle the correct XML pattern for Windows
echo [PROCESSING] Checking XML configuration...

:: Search for the Windows-specific XML pattern
powershell -Command "$xml = Get-Content -Path '!XML_PATH!' -Raw; if ($xml -match '<panel>\s*<name>AppsPanel</name>\s*<visible>false</visible>\s*</panel>') { $true } else { $false }" > "%TEMP%\check_result.txt"
set /p CHECK_RESULT=<"%TEMP%\check_result.txt"

if "!CHECK_RESULT!"=="True" (
    :: Use PowerShell with proper pattern matching for the Windows XML format
    powershell -Command "$content = Get-Content -Path '!XML_PATH!' -Raw; $pattern = '(<panel>\s*<name>AppsPanel</name>\s*<visible>)false(</visible>\s*</panel>)'; $replacement = '${1}true${2}'; $newContent = $content -replace $pattern, $replacement; Set-Content -Path '%TEMP%\adobe_config_temp.xml' -Value $newContent -NoNewline" 

    if %errorlevel% neq 0 (
        echo [WARNING] Failed to modify the configuration
        echo Aborting - no changes were made
        echo.
        echo *************************
        exit /b 1
    )
    
    :: Replace the original file with our modified version
    copy /Y "%TEMP%\adobe_config_temp.xml" "!XML_PATH!" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [WARNING] Failed to update the configuration file
        echo Aborting - no changes were made
        echo.
        echo *************************
        exit /b 1
    )
    
    :: Verify the change was made with PowerShell
    powershell -Command "$xml = Get-Content -Path '!XML_PATH!' -Raw; if ($xml -match '<panel>\s*<name>AppsPanel</name>\s*<visible>true</visible>\s*</panel>') { $true } else { $false }" > "%TEMP%\verify_result.txt"
    set /p VERIFY_RESULT=<"%TEMP%\verify_result.txt"
    
    if "!VERIFY_RESULT!"=="True" (
        echo [OK] Adobe Apps Panel has been successfully re-enabled.
    ) else (
        echo [WARNING] Something went wrong while modifying the configuration.
        echo Attempting to restore from backup...
        copy /Y "!BACKUP_PATH!" "!XML_PATH!" >nul 2>&1
        echo Please try again or seek technical assistance.
        echo.
        echo *************************
        exit /b 1
    )
) else (
    :: Check if already enabled
    powershell -Command "$xml = Get-Content -Path '!XML_PATH!' -Raw; if ($xml -match '<panel>\s*<name>AppsPanel</name>\s*<visible>true</visible>\s*</panel>') { $true } else { $false }" > "%TEMP%\enabled_check.txt"
    set /p ENABLED_CHECK=<"%TEMP%\enabled_check.txt"
    
    if "!ENABLED_CHECK!"=="True" (
        echo [OK] Apps Panel is already enabled in the configuration file
    ) else (
        echo [WARNING] Could not find the Apps Panel configuration in the expected format.
        echo The Adobe configuration file may have a different structure than expected.
        echo No changes were made to your configuration.
        echo.
        echo You may need to manually enable the Apps Panel or check for Adobe updates.
        echo.
        echo *************************
        exit /b 1
    )
)

echo.
echo [PROCESSING] Stopping Adobe background services...
echo This may take a moment...

:: Stop Adobe services
taskkill /F /IM "Adobe Desktop Service.exe" >nul 2>&1
taskkill /F /IM "Adobe CEF Helper.exe" >nul 2>&1
taskkill /F /IM "AdobeIPCBroker.exe" >nul 2>&1
taskkill /F /IM "CCLibrary.exe" >nul 2>&1
taskkill /F /IM "CCXProcess.exe" >nul 2>&1
taskkill /F /IM "CoreSync.exe" >nul 2>&1
taskkill /F /IM "Creative Cloud.exe" >nul 2>&1

echo.
echo [PROCESSING] Launching Adobe Creative Cloud...

:: Start Adobe Creative Cloud
start "" "!CC_APP!"
if %errorlevel% neq 0 (
    echo [WARNING] Failed to launch Adobe Creative Cloud app
    echo Please try opening it manually from the Start Menu.
) else (
    echo [OK] Adobe Creative Cloud launched successfully
)

echo.
echo [OK] Process completed!
echo The Creative Cloud app should now show the Apps Panel.
echo If you still experience issues, try restarting your computer.
echo *************************

:: Wait for user input before closing
echo.
echo Press any key to exit...
pause >nul

endlocal
exit /b 0