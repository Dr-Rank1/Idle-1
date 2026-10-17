@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo       IDLE DINER 3D - ANDROID BUILD ^& DEPLOY
echo ========================================================

:: 1. Locate ADB
set "ADB_CMD=adb"
where adb >nul 2>&1
if %ERRORLEVEL% neq 0 (
    if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        set "ADB_CMD=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
    ) else if exist "%ANDROID_HOME%\platform-tools\adb.exe" (
        set "ADB_CMD=%ANDROID_HOME%\platform-tools\adb.exe"
    ) else (
        echo [WARNING] adb not found in PATH or standard SDK paths.
    )
)

:: 2. Locate Godot Console
set "GODOT_BIN=.\Godot_v4.3-stable_win64_console.exe"
if not exist "%GODOT_BIN%" (
    set "GODOT_BIN=godot"
    where godot >nul 2>&1
    if !ERRORLEVEL! neq 0 (
        echo [ERROR] Godot executable not found!
        exit /b 1
    )
)

:: 3. Ensure Build Directory
if not exist "build" mkdir "build"

:: 4. Verify/Setup Android Export Templates
set "TEMPLATES_DIR=%APPDATA%\Godot\export_templates\4.3.stable"
if not exist "%TEMPLATES_DIR%\android_debug.apk" (
    echo [INFO] Godot Android export templates not detected in %TEMPLATES_DIR%.
    echo [INFO] Running automatic template installer...
    python restaurant_tycoon_3d\setup_android_templates.py
    if !ERRORLEVEL! neq 0 (
        echo [ERROR] Failed to set up Android export templates.
        exit /b 1
    )
)

:: 5. Export Android APK
echo.
echo [1/2] Exporting Android APK (com.drrank.idlediner, arm64-v8a)...
"%GODOT_BIN%" --headless --path restaurant_tycoon_3d --export-debug "Android" ../build/IdleDiner3D.apk
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Godot export failed with error code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
)

if not exist "build\IdleDiner3D.apk" (
    echo [ERROR] Expected APK build\IdleDiner3D.apk was not created.
    exit /b 1
)

echo [INFO] Export succeeded: build\IdleDiner3D.apk

:: 6. Install to connected device via ADB
echo.
echo [2/2] Checking for connected Android devices...
"%ADB_CMD%" devices

for /f "skip=1 tokens=1,2" %%A in ('"%ADB_CMD%" devices') do (
    if "%%B"=="device" (
        set "DEVICE_ID=%%A"
        goto :INSTALL_DEVICE
    )
)

echo [WARNING] No authorized Android device detected. Skipping install.
echo [TIP] To install manually once connected: "%ADB_CMD% install -r build\IdleDiner3D.apk"
goto :END

:INSTALL_DEVICE
echo [INFO] Installing build\IdleDiner3D.apk to device %DEVICE_ID%...
"%ADB_CMD%" -s %DEVICE_ID% install -r "build\IdleDiner3D.apk"
if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================================
    echo  SUCCESS: Idle Diner 3D installed to %DEVICE_ID%!
    echo ========================================================
) else (
    echo [ERROR] ADB installation failed with code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
)

:END
endlocal
