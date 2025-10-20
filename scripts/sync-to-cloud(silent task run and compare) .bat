@echo off
REM massCode Cloud Sync Script (Windows Batch)
REM Silent mode with smart upload (skip if unchanged)
REM Supports custom dbPath from sync-config.json
REM With Windows 10/11 Toast Notifications

chcp 65001 >nul 2>nul
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
if "!SCRIPT_DIR:~-1!"=="\" set "SCRIPT_DIR=!SCRIPT_DIR:~0,-1!"
set "CONFIG_FILE=!SCRIPT_DIR!\sync-config.json"
set "LOG_FILE=!SCRIPT_DIR!\sync-log.txt"
set "HASH_FILE=!SCRIPT_DIR!\last-sync-hash.txt"

REM Default fallback
set "DEFAULT_DB_PATH=%APPDATA%\massCode\storage\massCode.db"
set "DB_PATH=!DEFAULT_DB_PATH!"
set "SERVER_URL="
set "API_TOKEN="

REM Start logging
echo [%date% %time%] Starting massCode sync check... >> "!LOG_FILE!"

REM Try to read serverUrl, apiToken, and dbPath from JSON
if exist "!CONFIG_FILE!" (
    for /f "usebackq delims=" %%a in (`powershell -Command "$ErrorActionPreference='Stop'; try { $raw = Get-Content -Raw -Path '!CONFIG_FILE!'; $json = $raw | ConvertFrom-Json; $url = $json.serverUrl; $token = $json.apiToken; $db = $json.dbPath; if ($url) { 'SERVER_URL='+$url }; if ($token) { 'API_TOKEN='+$token }; if ($db) { 'DB_PATH='+$db } } catch { }" 2^>nul`) do (
        set "%%a"
    )
)

REM Handle relative paths in dbPath
if not "!DB_PATH!"=="" (
    REM Remove surrounding quotes if present
    set "DB_PATH=!DB_PATH:"=!"
    
    REM Handle ./ prefix
    if "!DB_PATH:~0,2!"=="./" (
        set "DB_PATH=!SCRIPT_DIR!\!DB_PATH:~2!"
    ) else if "!DB_PATH!"=="massCode.db" (
        set "DB_PATH=!SCRIPT_DIR!\massCode.db"
    ) else if "!DB_PATH:~0,1!"=="." (
        set "DB_PATH=!SCRIPT_DIR!\!DB_PATH!"
    ) else if not "!DB_PATH:~1,1!"==":" (
        set "DB_PATH=!SCRIPT_DIR!\!DB_PATH!"
    )
)

REM Check server URL
if "!SERVER_URL!"=="" (
    echo [%date% %time%] ERROR: Server URL not configured >> "!LOG_FILE!"
    call :ShowNotification "massCode Sync Failed" "Server URL not configured in sync-config.json"
    exit /b 1
)

REM Normalize URL
if "!SERVER_URL:~-1!"=="/" set "SERVER_URL=!SERVER_URL:~0,-1!"
set "UPLOAD_URL=!SERVER_URL!/api/upload"

REM Check database file
if not exist "!DB_PATH!" (
    echo [%date% %time%] ERROR: Database file not found: !DB_PATH! >> "!LOG_FILE!"
    call :ShowNotification "massCode Sync Failed" "Database file not found"
    exit /b 1
)

REM Get file size for logging
for %%A in ("!DB_PATH!") do set "FILE_SIZE=%%~zA"

REM Calculate current file hash (MD5)
echo [%date% %time%] Calculating file hash... >> "!LOG_FILE!"
for /f "delims=" %%H in ('powershell -Command "(Get-FileHash -Algorithm MD5 -Path '!DB_PATH!').Hash" 2^>nul') do (
    set "CURRENT_HASH=%%H"
)

if "!CURRENT_HASH!"=="" (
    echo [%date% %time%] WARNING: Failed to calculate hash, proceeding with upload >> "!LOG_FILE!"
    goto UPLOAD_FILE
)

echo [%date% %time%] Current file hash: !CURRENT_HASH! >> "!LOG_FILE!"

REM Read last sync hash
set "LAST_HASH="
if exist "!HASH_FILE!" (
    set /p LAST_HASH=<"!HASH_FILE!"
    echo [%date% %time%] Last sync hash: !LAST_HASH! >> "!LOG_FILE!"
)

REM Compare hashes
if "!CURRENT_HASH!"=="!LAST_HASH!" (
    echo [%date% %time%] SKIPPED: File unchanged, no upload needed >> "!LOG_FILE!"
    call :ShowNotification "massCode Sync" "Database unchanged - No upload needed"
    exit /b 0
)

echo [%date% %time%] File changed, uploading... >> "!LOG_FILE!"

:UPLOAD_FILE
echo [%date% %time%] DB Path: !DB_PATH! (!FILE_SIZE! bytes) >> "!LOG_FILE!"
echo [%date% %time%] Upload URL: !UPLOAD_URL! >> "!LOG_FILE!"

REM Upload with Authorization header if token is set
if "!API_TOKEN!"=="" (
    curl -X POST -F "file=@!DB_PATH!" "!UPLOAD_URL!" -w "%%{http_code}" -o "%TEMP%\masscode_response.txt" -s > "%TEMP%\masscode_status.txt" 2>&1
) else (
    curl -X POST -H "Authorization: Bearer !API_TOKEN!" -F "file=@!DB_PATH!" "!UPLOAD_URL!" -w "%%{http_code}" -o "%TEMP%\masscode_response.txt" -s > "%TEMP%\masscode_status.txt" 2>&1
)

REM Check HTTP status code
set /p HTTP_CODE=<"%TEMP%\masscode_status.txt"

if "!HTTP_CODE!"=="200" (
    echo [%date% %time%] SUCCESS: Upload completed (HTTP !HTTP_CODE!) >> "!LOG_FILE!"
    REM Save current hash (use dot to prevent "ECHO is off" issue)
    if not "!CURRENT_HASH!"=="" (
        echo.!CURRENT_HASH!>"!HASH_FILE!"
    )
    call :ShowNotification "massCode Sync Success" "Database uploaded successfully"
    exit /b 0
) else if "!HTTP_CODE!"=="201" (
    echo [%date% %time%] SUCCESS: Upload completed (HTTP !HTTP_CODE!) >> "!LOG_FILE!"
    REM Save current hash (use dot to prevent "ECHO is off" issue)
    if not "!CURRENT_HASH!"=="" (
        echo.!CURRENT_HASH!>"!HASH_FILE!"
    )
    call :ShowNotification "massCode Sync Success" "Database uploaded successfully"
    exit /b 0
) else (
    echo [%date% %time%] FAILED: Upload failed (HTTP !HTTP_CODE!) >> "!LOG_FILE!"
    call :ShowNotification "massCode Sync Failed" "Upload failed - HTTP !HTTP_CODE!"
    exit /b 1
)

REM Function to show Windows notification
:ShowNotification
set "TITLE=%~1"
set "MESSAGE=%~2"

REM Use Toast notification for Windows 10/11 (more reliable for background tasks)
powershell -WindowStyle Hidden -Command "& {[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null; $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02); $toastXml = [xml]$template.GetXml(); $toastXml.GetElementsByTagName('text')[0].AppendChild($toastXml.CreateTextNode('%TITLE%')) | Out-Null; $toastXml.GetElementsByTagName('text')[1].AppendChild($toastXml.CreateTextNode('%MESSAGE%')) | Out-Null; $xml = New-Object Windows.Data.Xml.Dom.XmlDocument; $xml.LoadXml($toastXml.OuterXml); $toast = [Windows.UI.Notifications.ToastNotification]::new($xml); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('massCode Sync').Show($toast)}" 2>nul

if errorlevel 1 (
    REM Fallback to balloon notification
    powershell -WindowStyle Hidden -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(5000, '%TITLE%', '%MESSAGE%', [System.Windows.Forms.ToolTipIcon]::Info); Start-Sleep -Seconds 2; $notify.Dispose()}" 2>nul
)
exit /b 0