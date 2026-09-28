:: UnicodeEscape2UTF8 v2.0.0
:: Автор: bursoft
:: Плагин конвертирует файлы *.smali в папках smali*, переводя Unicode-последовательности типа "\u043f\u0440\u0438\u0432\u0435\u0442\u0029" в человекопонятные "привет)"
if "%bat_version%"=="" goto:eof
cls
echo.
cecho {!colG!}!bat_title!{# #}{\n}
echo !bat_page!
echo !bat_line!
echo.
echo !str_plugin_name!.
echo.
if "!apk_base!"=="*" (
	FOR /D %%F IN ("_INPUT_APK\!apk_base!") DO (
	if not "%%~nxF"=="_RES_REPLACE" (
		echo [*] !str_converting! %%~nxF ...
		FOR /D %%S IN ("_INPUT_APK\%%~nxF\smali*") DO (
			cecho  - %%~nxS: 
			set "smali_dir=_INPUT_APK\%%~nxF\%%~nxS"
			python "!plugdir!UnicodeEscape2UTF8.py"
		)
	)
	)
) else (
	FOR /D %%F IN ("_INPUT_APK\!apk_base!" "_INPUT_APK\!apk_base!_apkeditor") DO (
		echo [*] !str_converting! %%~nxF ...
		FOR /D %%S IN ("_INPUT_APK\%%~nxF\smali*") DO (
			cecho  - %%~nxS: 
			set "smali_dir=_INPUT_APK\%%~nxF\%%~nxS"
			python "!plugdir!UnicodeEscape2UTF8.py"
		)
	)
)
echo.
cecho {!colG!}!str_done!{# #}{\n}
pause
::	native2ascii -reverse -encoding UTF-8 "%%~nxS\%%~a" "%%~nxS\%%~a.utf-8"
