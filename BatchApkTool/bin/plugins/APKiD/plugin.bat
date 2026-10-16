:: APKid BAT plugin for windows 10+ (native support for ANSI colors on the console) 2024-02-03
:: Author: Tilks
:: Android Application Identifier for Packers, Protectors, Obfuscators and Oddities
:: https://github.com/rednaga/APKiD
:: version apkid-3.1.0 (Apr 9, 2026)
:: Author: rednaga
set "args="
if "%bat_version%"=="" goto:eof
cls
echo APKiD 3.1.0 :: from RedNaga :: rednaga.io
FOR %%F IN ("_INPUT_APK\!apk_name!") DO (
	echo.
	python "!plugdir!main.py" "%%~F"
)
pause
goto:eof
