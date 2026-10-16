rem () { :; } ; command -v godot >/dev/null 2>&1 && GODOT_CMD=godot || GODOT_CMD=/home/ian/.local/bin/godot ; [ -n "$BASH_VERSION" ] && { echo "==================================================================" && echo "[1/2] Running Unified Headless Test Runner..." && echo "==================================================================" && DISPLAY=:0 $GODOT_CMD --headless --path restaurant_tycoon_3d -s scripts/run_all_tests.gd && echo "" && echo "==================================================================" && echo "[2/2] Capturing Game Visual Views and Snapshots..." && echo "==================================================================" && DISPLAY=:0 $GODOT_CMD --path restaurant_tycoon_3d -s scripts/capture_game.gd && echo "" && echo "==================================================================" && echo "[SUCCESS] Both test execution and snapshot capture passed (Exit code 0)!" && echo "==================================================================" && exit 0 || exit 1 ; }
@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ==================================================================
echo [1/2] Running Unified Headless Test Runner...
echo ==================================================================
.\Godot_v4.3-stable_win64_console.exe --headless --path restaurant_tycoon_3d -s scripts/run_all_tests.gd
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Headless test suite failed with exit code %ERRORLEVEL%!
    exit /b %ERRORLEVEL%
)

echo.
echo ==================================================================
echo [2/2] Capturing Game Visual Views and Snapshots...
echo ==================================================================
.\Godot_v4.3-stable_win64_console.exe --path restaurant_tycoon_3d -s scripts/capture_game.gd
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Game snapshot capture failed with exit code %ERRORLEVEL%!
    exit /b %ERRORLEVEL%
)

echo.
echo ==================================================================
echo [SUCCESS] Both test execution and snapshot capture passed (Exit code 0)!
echo ==================================================================
exit /b 0
