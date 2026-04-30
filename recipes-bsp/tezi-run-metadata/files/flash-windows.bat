@echo off
setlocal enabledelayedexpansion

REM Defaults
set "VERBOSITY=2"
set "ERASE_BOOT=1"
set "ERASE_USER=1"
set "UUU_ARGS="
set "WIC_IMG="
set "BL_IMG="
set "WIC_IMG_LINK=wic-image.lnk"
set "BL_IMG_LINK=bootloader.lnk"

:parse_args
if "%~1"=="" goto after_args
    if /I "%~1"=="--help" goto show_help
    if /I "%~1"=="-h" goto show_help
    if /I "%~1"=="--wic" (
        set "WIC_IMG=%~2"
        shift
        shift
        goto parse_args
    )
    if /I "%~1"=="--bootloader" (
        set "BL_IMG=%~2"
        shift
        shift
        goto parse_args
    )
    if /I "%~1"=="--erase-user" (
        set "ERASE_USER=1"
        shift
        goto parse_args
    )
    if /I "%~1"=="--no-erase-user" (
        set "ERASE_USER=0"
        shift
        goto parse_args
    )
    if /I "%~1"=="--erase-boot" (
        set "ERASE_BOOT=1"
        shift
        goto parse_args
    )
    if /I "%~1"=="--no-erase-boot" (
        set "ERASE_BOOT=0"
        shift
        goto parse_args
    )
    if /I "%~1"=="-q" (
        set "VERBOSITY=1"
        shift
        goto parse_args
    )
    if /I "%~1"=="-v" (
        set "VERBOSITY=3"
        shift
        goto parse_args
    )
    call :show_help 1>&2
    echo ERROR: Invalid option "%~1"
    exit /b 1
:after_args

REM Check for required arguments
if "%WIC_IMG%"=="" (
    call :show_help
    echo ERROR: Missing --wic argument.
    exit /b 1
)

if "%BL_IMG%"=="" (
    call :show_help
    echo ERROR: Missing --bootloader argument.
    exit /b 1
)

REM Make links (actually copies in Windows batch)
if not exist "%WIC_IMG%" (
    echo WIC image "%WIC_IMG%" not found - aborting.
    exit /b 1
)
if not exist "%BL_IMG%" (
    echo Bootloader image "%BL_IMG%" not found - aborting.
    exit /b 1
)
copy /Y "%WIC_IMG%" "%WIC_IMG_LINK%" >nul
copy /Y "%BL_IMG%" "%BL_IMG_LINK%" >nul

call :hdr "Loading bootloader and entering Fastboot mode..."
call :run_uuu "flash\fastboot.uuu"
if errorlevel 1 goto exit_error

if "%ERASE_BOOT%"=="1" (
    call :hdr "Erasing boot partitions..."
    call :run_uuu "flash\erase-boot.uuu"
    if errorlevel 1 goto exit_error
)

if "%ERASE_USER%"=="1" (
    call :hdr "Erasing user partition..."
    call :run_uuu "flash\erase-user.uuu"
    if errorlevel 1 goto exit_error
)

call :hdr "Flashing device..."
call :run_uuu "flash\flash-all.uuu"
if errorlevel 1 goto exit_error

del /Q "%WIC_IMG_LINK%" "%BL_IMG_LINK%" 2>nul

call :hdr "Flashing was successful!"
exit /b 0

:show_help
echo Usage: flash-linux.bat [-q^-v]
echo.                   [--erase-user ^| --no-erase-user]
echo.                   [--erase-boot ^| --no-erase-boot]
echo.                   --wic WIC_IMAGE --bootloader BOOTLOADER_IMAGE
echo.
echo Mandatory switches:
echo.    --wic          Path to WIC image to flash.
echo.    --bootloader   Path to bootloader image to flash.
echo.
echo Optional switches:
echo.    -q^-v
echo.                   Be quieter (-q) or more verbose (-v).
echo.    --erase-user^|--no-erase-user
echo.                   Whether or not to erase the user data partition before flashing.
echo.    --erase-boot^|--no-erase-boot
echo.                   Whether or not to erase the boot partitions.
exit /b 0

:hdr
if %VERBOSITY% GEQ 1 (
    echo= %~1
    if %VERBOSITY% GEQ 2 echo.
)
exit /b 0

:run_uuu
if %VERBOSITY% GEQ 3 (
    echo Running: .\recovery\uuu.exe %UUU_ARGS% -V %*
    .\recovery\uuu.exe %UUU_ARGS% -V %*
) else if %VERBOSITY% GEQ 2 (
    echo Running: .\recovery\uuu.exe %UUU_ARGS% %*
    .\recovery\uuu.exe %UUU_ARGS% %*
) else (
    .\recovery\uuu.exe %UUU_ARGS% %* >nul
)
exit /b %ERRORLEVEL%

:exit_error
echo ERROR: Failed to flash device.
del /Q "%WIC_IMG_LINK%" "%BL_IMG_LINK%" 2>nul
exit /b 1
