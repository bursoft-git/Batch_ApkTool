::
::	ÁÀÒ×Õ ÀÏÊÒÎÎË by BurSoft
::
@echo off
set colB=07
set colG=0A
set colR=0C
set colY=0E
set trans_value=243
COLOR %colB%
set "dp0dir=%~dp0"
set "rootdir=%dp0dir:~0,-4%"
setLocal EnableExtensions EnableDelayedExpansion
set OS_PATH=
set OS_arch=x64& if %PROCESSOR_ARCHITECTURE%==x86 if not defined PROCESSOR_ARCHITEW6432 set OS_arch=x86
if "%OS_arch%"=="x64" (set OS_PATH=!dp0dir!bin64;!dp0dir!bin64\jre\bin;!dp0dir!bin64\python3;)
for /f "tokens=4 delims=[.]" %%a in ('ver') do (set OS_version=%%a)
if %OS_version% LSS 7600 (
	set OS_PATH=!dp0dir!binXP;!dp0dir!binXP\jre\bin;!dp0dir!binXP\python3;!OS_PATH!
) else (
	if %OS_version% LSS 10240 (
		set OS_PATH=!dp0dir!bin7;!OS_PATH!
	) 
)
set PATH=!OS_PATH!!dp0dir!;!dp0dir!jre\bin;!dp0dir!python3;!PATH!;!JAVA_HOME!\bin;!SystemRoot!\Sysnative;!SystemRoot!\system32;!SystemRoot!\SysWOW64
set PATHEXT=.COM;.EXE;.BAT;.CMD;!PATHEXT!
mode con:cols=105 lines=48
if not "%~1"=="launcher" (
	goto:eof
	for /f "tokens=2 delims=," %%a in ('tasklist /V /FI "IMAGENAME eq cmd.exe" /FO CSV /NH ^| find /I "BAT by BurSoft"') do (
		nircmd win activate process /%%~a
		nircmd win flash process /%%~a 2
		goto:eof
	)
)
set title_text=BAT by BurSoft
title !title_text!
cd /d "!dp0dir!"
if not exist language\english.lng (
	COLOR !colR!
	echo ERROR^^!
	echo Batch ApkTool is not fully installed or do not have full access to the folder
	PAUSE
	goto:eof
)
if exist language\lang (
	for /F "usebackq tokens=1* delims==" %%a in ("language\lang") do set %%a=%%b
) else (
	for /f "delims=" %%a in ('chcp') DO set x=%%a
	if not !x!==!x:866=! (set language=russian) else (set language=english)
)
call :__language
set opt=
FOR %%a IN (sfk.exe nircmd.exe nhrt.exe) DO (
	if not exist bin64\%%a if not exist %%a set opt=!opt!%%a 
)
if not "%opt%"=="" (
	COLOR !colR!
	echo !str_error!
	echo !str_necessary_files_missing! (%opt%^)
	PAUSE
	goto:eof
)
set bat_version=3.9.2
set bat_title=                                     BATCH APKTOOL %bat_version% by BurSoft                                     
set bat_page=                                  http://bursoft-portable.blogspot.com
set bat_line=--------------------------------------------------------------------------------------------------------
set logR=log_recompile.txt
set logD=log_decompile.txt
set TEMP=!TEMP!\BAT_temp
set TMP=!TMP!\BAT_temp
set JAVA_TOOL_OPTIONS=
set _JAVA_OPTIONS=
if exist "!dp0dir!jre\bin\javac.exe" set "JAVA_HOME=!dp0dir!jre\"
if exist "!dp0dir!binXP\jre\bin\javac.exe" set "JAVA_HOME=!dp0dir!binXP\jre\"
if exist "!dp0dir!bin64\jre\bin\javac.exe" set "JAVA_HOME=!dp0dir!bin64\jre\"
set PYTHONPATH=
set PYTHONHOME=
set ANDROID_SERIAL=
set ADB_MDNS=1
set ADB_MDNS_OPENSCREEN=0
set scrcpy_serial=N
if %OS_version% LSS 10240 set ADB_MDNS_OPENSCREEN=1
set workdir=.
if exist settings.ini (
	for /f "delims=" %%a in ('inifile settings.ini [global_settings]') do %%a
)
if not %trans_value%==255 (nircmd win trans ititle "BAT by BurSoft" %trans_value%)
COLOR %colB%
set opt=0
echo "!dp0dir!" | FINDSTR /I "%% ^! ^^" >nul 2>nul
if not errorlevel 1 set opt=1
cd /d "!rootdir!"
if errorlevel 1 set opt=1
if %opt%==1 (
	COLOR !colR!
	echo !str_error!
	echo !str_startup_error1!
	PAUSE
	goto:eof
)
type NUL > write_test
if exist "write_test" (
	del /f /q write_test 2>nul
) else (
	COLOR !colR!
	echo !str_error!
	echo !str_startup_error2!
	PAUSE
	goto:eof
)
md "!TEMP!" "!TMP!" 2>nul
if not exist bin\language\lang (
	set bindir=bin\
	call :setlanguage
)
if "%~1"=="launcher" (
	set java_version=%~2
	set java_text=%~3
	goto SkipJava
)
::where /F java.exe
for /f "delims=" %%a in ('sfk pathfind java.exe 2^>nul') do (
	if not defined java_version (
		for /f "tokens=2,3 delims=	" %%b in ('sfk ver -win "%%~a" 2^>nul') do (
			for /f "tokens=1,3 delims=." %%d in ("%%~c") do (
				set java_version=%%~d
				if !java_version! GTR 8 (
					set java_text=%%~c
				) else (
					set java_text=%%~e
					set java_text=!java_version!u!java_text:~0,-1!
				)
			)
			if "%%~b"=="windows-64" (set java_text=!java_text! x64)
		)
	)
)
:SkipJava
if defined java_version (
	set title_text=!title_text! (Java !java_text!^)
	title !title_text!
	if !java_version! LSS 8 (
		cecho {!colR!}!str_previous_java1! !java_text!{# #}{\n}
		cecho {!colR!}!str_previous_java2!{# #}{\n}
		echo !str_get_java!
		PAUSE
	)
) else (
	cecho {!colR!}!str_java_notfound!{# #}{\n}
	echo !str_get_java!
	PAUSE
)
:restart3
cd /d "!rootdir!"
set apktool=apktool.jar
set smali=smali.jar
set apkeditor=APKEditor.jar
set api=35
set sign_after=ON
set open_log=MANUAL
set adb_ip=
set apk_name=*
set jar_name=*
set res_resolve_mode=default
set deldebuginfo=OFF
set key_name=testkey.pk8
set bindir=bin\
set projdir=..
set framedir=_framework
set rewrite_check=ON
set sound_notifications=OFF
set save_orig_manifest=OFF
set set_postfix=OFF
set tray_notifications=ON
set use_aapt2=aapt2
set adb_mode=off
set force_sign_v1=OFF
set dex_compression_level=0
set produce_v4_sign=OFF
set pull_folder=/sdcard/Download/
set push_folder=/sdcard/Download/
set scr_cmd=--max-size=1920 --max-fps=60 --keep-active
set scr_cmd_add=
set logcat_level=Verbose
if not "!workdir!"=="." (
	if exist "!workdir!" (
		cd "!workdir!"
		set bindir=..\bin\
		set projdir=..\!workdir!
	) else (
		set workdir=.
		call :saveglobal "workdir"
	)
)
md _framework _INPUT_APK _INPUT_JAR _OUT_APK _OUT_JAR _system 2>nul
md "%bindir%framework" "%bindir%temp" 2>nul
if exist batchapktool.ini (
	for /f "delims=" %%a in ('inifile batchapktool.ini [settings]') do %%a
)
if not exist "%bindir%!apktool!" (
	FOR %%F IN (%bindir%apktool*.jar) DO set apktool=%%~nxF
	call :savesettings "apktool"
)
if not exist "%bindir%!smali!" (
	FOR %%F IN (%bindir%smali*.jar) DO set smali=%%~nxF
	call :savesettings "smali"
)
if not exist "%bindir%!apkeditor!" (
	FOR %%F IN (%bindir%apkeditor*.jar) DO set apkeditor=%%~nxF
	call :savesettings "apkeditor"
)
:restart2
set apk_base=*
if not "!apk_name!"=="*" (
	if exist "_INPUT_APK\!apk_name!" (
		FOR %%F IN ("!apk_name!") DO set apk_base=%%~nF
	) else (
		set apk_name=*
		call :savesettings "apk_name"
	)
)
set jar_base=*
if not "!jar_name!"=="*" (
	if exist "_INPUT_JAR\!jar_name!" (
		FOR %%F IN ("!jar_name!") DO set jar_base=%%~nF
	) else (
		set jar_name=*
		call :savesettings "jar_name"
	)
)
FOR %%F IN ("!key_name!") DO set key_base=%%~nF
for /f "tokens=1,2 delims=.,_-" %%a in ("!smali:~6!") do (
	set smali_ver1=%%~a
	set smali_ver2=%%~b
)
set old_smali=0
if "!smali_ver1!"=="1" (set old_smali=1)
if "!smali_ver1!"=="2" (
	if "!smali_ver2!"=="0" (set old_smali=1)
	if "!smali_ver2!"=="1" (set old_smali=1)
)
for /f "tokens=1,2 delims=.,_-" %%a in ("!apktool:~8!") do (
	set apktool_ver1=%%~a
	set apktool_ver2=%%~b
)
:restart
cls
COLOR %colB%
title !title_text!
echo.
cecho {!colG!}!bat_title!{# #}{\n}
echo !bat_page!
echo !bat_line!
echo   80  !str_project! : !workdir!
echo   81  !str_currentapk! : !apk_name!
echo   82  !str_currentjar! : !jar_name!
echo   83  SMALI                                        : !smali!
echo   84  - !str_apilevel! : %api%
echo   85  APKTOOL                                      : !apktool!
echo   86  - !str_res_mode! : !res_resolve_mode!
echo   87  !str_dontwritedebug! : !str_%deldebuginfo%!
echo   88  !str_signafter! : !str_%sign_after%!
echo   89  - !str_key! : !key_name!
echo   90  !str_language! : !language!
echo !bat_line!
cecho {!colG!}APKTOOL:{# #}                                           {!colG!}TOOLS:{# #}{\n}  1   !str_decompile! 4   !str_signfiles!{\n}  2   !str_decompile_r! 5   !str_zipalfiles!{\n}  3   !str_recompile! 6   !str_viewsource!{\n}                                                   7   !str_plugins!{\n}!bat_line!{\n}{!colG!}APKEDITOR:{# #}                                         {!colG!}SMALI:{# #}{\n}  01  !str_decompile! 05  !str_baksmaliapk!{\n}  02  !str_decompile_r! 06  !str_smaliapk!{\n}  03  !str_recompile! 07  !str_baksmalijar!{\n}  04  !str_merge_apks! 08  !str_smalijar!{\n}!bat_line!{\n}{!colG!}!str_adbmenu!{# #} !ANDROID_SERIAL!{\n}  10  !str_devices! 15  !str_screenrecord!{\n}  11  !str_adbpm! 16  !str_shell!{\n}  12  !str_adbcontrol! 17  !str_logs!{\n}  13  !str_adbfilemanager! 18  !str_reboot!{\n}  14  !str_screenshot! 19  !str_info!{\n}                                                   20  !str_kill-server!{\n}!bat_line!{\n}{!colG!}!str_servicemenu!{# #}{\n}
echo   30  !str_cleanup1! 32  !str_cleanup3!
echo   31  !str_cleanup2! 33  !str_cleanup4!
echo !bat_line!
echo.
if "%~1"=="refresh_menu" (goto:eof)
SET INPUT=
SET /P INPUT=!str_choosetask! 
IF /I !INPUT!==bat (goto about)
IF !INPUT!==80 (goto setproject)
IF !INPUT!==81 (goto setcurrentapk)
IF !INPUT!==82 (goto setcurrentjar)
IF !INPUT!==83 (goto setsbversion)
IF !INPUT!==84 (goto setapi)
IF !INPUT!==85 (goto setapktoolversion)
IF !INPUT!==86 (goto set_res_mode)
IF !INPUT!==87 (goto setdeldebuginfo)
IF !INPUT!==88 (goto setsign)
IF !INPUT!==89 (goto setsignkey)
IF !INPUT!==90 (call :setlanguage) & goto restart
IF !INPUT!==01 (set opt_decompile=& goto decompile_apkeditor)
IF !INPUT!==02 (set opt_decompile=-dex& goto decompile_apkeditor)
IF !INPUT!==03 (goto recompile_apkeditor)
IF !INPUT!==04 (goto mergeapks)
IF !INPUT!==05 (goto baksmaliapk)
IF !INPUT!==06 (goto smaliapk)
IF !INPUT!==07 (goto baksmalijar)
IF !INPUT!==08 (goto smalijar)
IF !INPUT!==1 (set opt_decompile=& goto decompile_apktool)
IF !INPUT!==2 (set opt_decompile=-s& goto decompile_apktool)
IF !INPUT!==3 (goto recompile_apktool)
IF !INPUT!==4 (goto signzip)
IF !INPUT!==5 (goto zipalignoutapks)
IF !INPUT!==6 (goto javasource)
IF !INPUT!==7 (goto plugins)
IF !INPUT!==10 (goto adbdevices)
IF !INPUT!==11 (goto adbpackagemanager)
IF !INPUT!==12 (goto adbremount)
IF !INPUT!==13 (goto adbfilemanager)
IF !INPUT!==14 (goto adbscreenshot)
IF !INPUT!==15 (goto screenrecord)
IF !INPUT!==16 (goto adbshell)
IF !INPUT!==17 (goto adblogs)
IF !INPUT!==18 (goto adbreboot)
IF !INPUT!==19 (goto adbinfo)
IF !INPUT!==20 (goto adbexit)
IF !INPUT!==30 (call :clean "_framework _system") & goto restart
IF !INPUT!==31 (call :clean "_INPUT_APK _INPUT_JAR") & goto restart2
IF !INPUT!==32 (call :clean "_OUT_APK _OUT_JAR") & goto restart
IF !INPUT!==33 (call :clean "_framework _INPUT_APK _INPUT_JAR _OUT_APK _OUT_JAR _system") & goto restart2
IF !INPUT!==00 (goto advanced_settings)
IF "!INPUT:~0,1!"=="7" (
	set count=0
	FOR /D %%F IN (%bindir%plugins\*) DO (
		set /A count+=1
		set name!count!=%%~nxF
	)
	set "INPUT=!INPUT:~1!"
	if !INPUT! GTR !count! (goto restart)
	if !INPUT! LSS 1 (goto restart)
	goto _plugins_quick
)
IF "!INPUT:~0,2!"=="11" (
	set "INPUT=!INPUT:~2!"
	FOR %%a IN (1 2 3 4 5 6 7 8 9) DO (if !INPUT!==%%a goto _adbpackagemanager_quick)
)
IF "!INPUT:~0,2!"=="13" (
	set "INPUT=!INPUT:~2!"
	FOR %%a IN (1 2 3 4 5) DO (if !INPUT!==%%a goto _adbfilemanager_quick)
)
IF "!INPUT:~0,2!"=="17" (
	set "INPUT=!INPUT:~2!"
	FOR %%a IN (1 2 3 4 5 6) DO (if !INPUT!==%%a goto _adblogs_quick)
)
IF "!INPUT:~0,2!"=="18" (
	set "INPUT=!INPUT:~2!"
	FOR %%a IN (1 2 3) DO (if !INPUT!==%%a goto _adbreboot_quick)
)
goto restart
:advanced_settings
cls
echo.
cecho {!colG!}                                           ADVANCED SETTINGS{# #}{\n}
echo !bat_line!
echo   1  !str_manifest_opt!  : !str_%save_orig_manifest%!
echo   2  !str_force_sign_v1!  : !str_%force_sign_v1%!
echo   3  !str_produce_v4_sign!  : !str_%produce_v4_sign%!
echo   4  !str_dex_compression! : !dex_compression_level!
echo   5  !str_use_aapt_2! : !use_aapt2!
echo.
echo   6  !str_rewrite_opt!  : !str_%rewrite_check%!
echo   7  !str_set_postfix!  : !str_%set_postfix%!
echo   8  !str_openlog!  : !str_%open_log%!
echo   9  !str_sound_opt!  : !str_%sound_notifications%!
echo.
echo   0  !str_back_to_main_menu!
echo.
SET INPUT=
SET /P INPUT=!str_choosetask! 
IF !INPUT!==1 (
	if %save_orig_manifest%==OFF (set save_orig_manifest=ON) else (set save_orig_manifest=OFF)
	call :savesettings "save_orig_manifest"
)
IF !INPUT!==2 (
	if %force_sign_v1%==OFF (set force_sign_v1=ON) else (set force_sign_v1=OFF)
	call :savesettings "force_sign_v1"
)
IF !INPUT!==3 (
	if %produce_v4_sign%==OFF (set produce_v4_sign=ON) else (set produce_v4_sign=OFF)
	call :savesettings "produce_v4_sign"
)
IF !INPUT!==4 (
	:_setcompression
	set INPUT=
	set /P INPUT=!str_dex_compression_text! 
	if "!INPUT!"=="" goto _setcompression
	if !INPUT! GTR 9 goto _setcompression
	if !INPUT! LSS 0 goto _setcompression
	set dex_compression_level=!INPUT!
	call :savesettings "dex_compression_level"
	goto advanced_settings
)
IF !INPUT!==5 (
	if %use_aapt2%==aapt1 (set use_aapt2=aapt2) else (set use_aapt2=aapt1)
	call :savesettings "use_aapt2"
)
IF !INPUT!==6 (
	if %rewrite_check%==OFF (set rewrite_check=ON) else (set rewrite_check=OFF)
	call :savesettings "rewrite_check"
)
IF !INPUT!==7 (
	if %set_postfix%==OFF (set set_postfix=ON) else (set set_postfix=OFF)
	call :savesettings "set_postfix"
)
IF !INPUT!==8 (
	if %open_log%==ON (set open_log=MANUAL) else (set open_log=ON)
	call :savesettings "open_log"
)
IF !INPUT!==9 (
	if %sound_notifications%==ON (set sound_notifications=OFF) else (set sound_notifications=ON)
	call :savesettings "sound_notifications"
)
IF !INPUT!==0 (goto restart)
goto advanced_settings
:: --------------------
:plugins
cecho {!colG!}  !str_selplugin!{# #}{\n}
set count=0
FOR /D %%F IN (%bindir%plugins\*) DO (
	set /A count+=1
	set name!count!=%%~nxF
	set plugin_name=%%~nxF
	if not "!language!"=="english" (
		if exist "%bindir%plugins\%%~nxF\language\!language!.lng" (
			for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%plugins\%%~nxF\language\!language!.lng"') do (
				if "%%a"=="plugin_name" set %%a=!plugin_name!: %%b
			)
		)
	)
	if "!plugin_name!"=="%%~nxF" (
		if exist "%bindir%plugins\%%~nxF\language\english.lng" (
			for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%plugins\%%~nxF\language\english.lng"') do (
				if "%%a"=="plugin_name" set %%a=!plugin_name!: %%b
			)
		)
	)
	echo    !count! = !plugin_name!
	set /A MOD=!count! %% 45
	if !MOD! equ 0 pause
)
echo.
echo    0 = !str_cancel!
:_plugins
set INPUT=
set /P INPUT=!str_makechoice! 
:_plugins_quick
if !INPUT!==0 goto restart
if !INPUT! GTR !count! (goto _plugins)
if !INPUT! LSS 1 (goto _plugins)
set "plugdir=!dp0dir!plugins\!name%INPUT%!\"
if exist "!plugdir!system" (
	set system_plugin=1
) else (
	set system_plugin=0
	setLocal EnableExtensions EnableDelayedExpansion
)
echo "!PATH!" | FIND /I "!plugdir!" >nul 2>nul
if errorlevel 1 (set PATH=!plugdir!;!PATH!)
set "str_plugin_name=!name%INPUT%!"
if exist "!plugdir!language\english.lng" (
	for /F "eol=; tokens=1* delims==" %%a in ('type "!plugdir!language\english.lng"') do set str_%%a=%%b
)
if not "!language!"=="english" (
	if exist "!plugdir!language\!language!.lng" (
		for /F "eol=; tokens=1* delims==" %%a in ('type "!plugdir!language\!language!.lng"') do set str_%%a=%%b
	)
)
call "!plugdir!plugin.bat"
if !system_plugin!==0 endLocal
goto restart
:measure_time
set temp_time=!time:~0,2!
if "!temp_time:~0,1!"=="0" set temp_time=!temp_time:~1,1!
set /A temp_time=!temp_time! * 3600 + (1!time:~3,2! - 100) * 60 + 1!time:~6,2! - 100
if %~1==start (
	set start_time=!temp_time!
) else (
	set stop_time=!temp_time!
	if !stop_time! GEQ !start_time! (
		set /A diff_time=!stop_time! - !start_time!
	) else (
		set /A diff_time=!stop_time! + 86400 - !start_time!
	)
	set /A time_h=!diff_time! / 3600
	set /A time_m=(!diff_time! - !time_h! * 3600^) / 60
	set /A time_s=!diff_time! %% 60
	set elapsed_time=
	if not !time_h!==0 set elapsed_time=!time_h! !str_elapsed_h! 
	if not !time_m!==0 set elapsed_time=!elapsed_time!!time_m! !str_elapsed_m! 
	set elapsed_time=!str_elapsed_time!: !elapsed_time!!time_s! !str_elapsed_s!
)
goto:eof
:: --------------------
:install_framework
call :log_version "%~1" "apktool"
if "!apktool_ver1!"=="1" (
	del /f /q "%USERPROFILE%\apktool\framework\*.apk" 2>nul
) else (
	del /f /q "%bindir%framework\*.apk" 2>nul
)
FOR /f "delims=" %%F IN ('sfk list -quiet -quot "!framedir!" .apk 2^>nul') DO (
	cecho [*] !str_instframe! %%~nxF...
	echo [*] !str_instframe! %%~nxF>>%~1
	if "!apktool_ver1!"=="1" (
		java -jar "%bindir%!apktool!" if "%%~F" >>%~1 2>&1
	) else (
		java -jar "%bindir%!apktool!" if -p "%bindir%framework" "%%~F" >>%~1 2>&1
	)
	if not "!errorlevel!"=="0" (
		set /A error_count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_instframe_error! %%~nxF>>%~1
	) else (
		echo.
	)
)
goto:eof
:decompile_apktool
set count2=0
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (set /A count2+=1)
if %count2%==0 (
	cecho {!colR!}[*] !str_inputapk_empty!{# #}{\n}
	pause
	goto restart
)
if %rewrite_check%==ON (
	call :check_rewrite "_INPUT_APK" "!apk_base!.apk"
	if !_temp_!==0 goto restart
)
call :measure_time start
set error_count=0
call :install_framework "%logD%"
set opt=
if not %res_resolve_mode%==default (set opt=--res-resolve-mode %res_resolve_mode%)
if "!apktool_ver1!"=="1" (set opt=)
if "!apktool_ver1!"=="2" (
	set opt=
	if /I !apktool_ver2! GEQ 9 (
		if %res_resolve_mode%==default (set opt=-resm keep)
		if %res_resolve_mode%==greedy (set opt=-resm dummy)
		if %res_resolve_mode%==lazy (set opt=-resm remove)
	)
)
set opt_decompile=%opt% %opt_decompile%
if %deldebuginfo%==ON (set opt_decompile=--no-debug-info %opt_decompile%)
set count3=0
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_decompiling! %%~nxF...
	echo [*] !str_decompiling! %%~nxF>>%logD%
	rd /s /q "_INPUT_APK\%%~nF" 2>nul
	if "!apktool_ver1!"=="1" (
		java -jar "%bindir%!apktool!" d -f %opt_decompile% "_INPUT_APK\%%~nxF" "_INPUT_APK\%%~nF" >>%logD% 2>&1
	) else (
		java -jar "%bindir%!apktool!" d -f %opt_decompile% -o "_INPUT_APK\%%~nF" -p "%bindir%framework" "_INPUT_APK\%%~nxF" >>%logD% 2>&1
	)
	if not "!errorlevel!"=="0" (
		set /A error_count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_decompiling_error! %%~nxF>>%logD%
	) else (
		echo.
	)
	md "_INPUT_APK\%%~nF\_backup" 2>nul
	type NUL > "_INPUT_APK\%%~nF\_backup\expert_mode_disabled"
	if not exist "_INPUT_APK\%%~nF\original" (
		7z x -tzip "_INPUT_APK\%%~nxF" -o"_INPUT_APK\%%~nF\original" AndroidManifest.xml stamp-cert-sha256 META-INF -aoa -sccWIN >nul 2>>%logD%
	)
	xcopy "_INPUT_APK\%%~nF\original" "_INPUT_APK\%%~nF\_backup\original\" /e /h /i /r /q /y >nul 2>nul
	FOR %%a IN (AndroidManifest.xml apktool.yml) DO (
		copy "_INPUT_APK\%%~nF\%%a" "_INPUT_APK\%%~nF\_backup\" >nul
	)
	ATTRIB +H "_INPUT_APK\%%~nF\_backup" >nul
	echo.>>%logD%
)
call :job_done "%logD%"
goto restart
:check_rewrite
set _temp_=1
FOR %%F IN ("%~1\%~2") DO (
	if exist "%~1\%%~nF%~3" (
		cecho {!colR!}!str_warn_rewrite1!{# #}{\n}
		SET INPUT=
		SET /P INPUT=!str_warn_rewrite2! 
		IF '!INPUT!'=='1' goto:eof
		set _temp_=0
		goto:eof
	)
)
goto:eof
:recompile_apktool
rd /s /q "!TMP!" 2>nul
md "!TMP!" 2>nul
call :measure_time start
set error_count=0
call :install_framework "%logR%"
set opt_recompile=
if "!apktool_ver1!"=="2" (
	if /I !apktool_ver2! GEQ 4 (
		if /I !apktool_ver2! LEQ 8 (
			if %use_aapt2%==aapt2 (set opt_recompile=--use-aapt2)
		)
	)
	if /I !apktool_ver2! GEQ 9 (
		if %use_aapt2%==aapt1 (set opt_recompile=--use-aapt1)
	)
)
set count2=0
set count3=0
FOR /D %%F IN ("_INPUT_APK\!apk_base!") DO (
	set "apk_dir=%%~nxF"
	if not "!apk_dir:~-10!"=="_apkeditor" set /A count2+=1
)
FOR /D %%F IN ("_INPUT_APK\!apk_base!") DO (
set "apk_dir=%%~nxF"
if not "!apk_dir:~-10!"=="_apkeditor" (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_recompiling! %%~nxF...
	echo [*] !str_recompiling! %%~nxF >>%logR%
	rd /s /q "_INPUT_APK\%%~nxF\build" "_INPUT_APK\%%~nxF\dist" 2>nul
	if "!apktool_ver1!"=="1" (
		pushd "!dp0dir!"
		java -jar "!apktool!" b "!projdir!\_INPUT_APK\%%~nxF" "!projdir!\_INPUT_APK\%%~nxF\dist\%%~nxF.apk" >>"!projdir!\%logR%" 2>&1
	) else (
		java -jar "%bindir%!apktool!" b %opt_recompile% -o "_INPUT_APK\%%~nxF\dist\%%~nxF.apk" -p "%bindir%framework" "_INPUT_APK\%%~nxF" >>%logR% 2>&1
	)
	if not "!errorlevel!"=="0" (
		if "!apktool_ver1!"=="1" popd
		set /A error_count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_recompiling_error! "%%~nxF">>%logR%
	) else (
		if "!apktool_ver1!"=="1" popd
		echo.
		if exist "_INPUT_APK\%%~nxF\dist\%%~nxF.apk" (
			7z a -tzip "_INPUT_APK\%%~nxF\dist\%%~nxF.apk" ".\_INPUT_APK\%%~nxF\original\META-INF" -mx7 >nul 2>nul
			if %save_orig_manifest%==ON (
				7z a -tzip "_INPUT_APK\%%~nxF\dist\%%~nxF.apk" ".\_INPUT_APK\%%~nxF\original\AndroidManifest.xml" -mx7 >nul 2>nul
			)
			set postfix=
			if %set_postfix%==ON (
				FOR /L %%P IN (1,1,100) DO (
					if exist "_OUT_APK\%%~nxF!postfix!.apk" (
						set postfix=_%%P
					)
				)
			)
			if %sign_after%==ON (
				set "sign_folder=_INPUT_APK\%%~nxF\dist"
				set "sign_name=%%~nxF"
				set "sign_out=_OUT_APK\%%~nxF!postfix!.apk"
				call :sign ".apk" "2>>%logR%"
			) else (
				zipalign -f -p 4 "_INPUT_APK\%%~nxF\dist\%%~nxF.apk" "_OUT_APK\%%~nxF!postfix!.apk" >nul 2>>%logR%
			)
		)
	)
	echo.>>%logR%
	rd /s /q "_INPUT_APK\%%~nxF\dist" 2>nul
)
)
call :job_done "%logR%"
goto restart
:signzip
set error_count=0
call :measure_time start
FOR %%F IN ("_INPUT_APK\!apk_name!") DO (
	set postfix=
	if %set_postfix%==ON (
		FOR /L %%P IN (1,1,100) DO (
			if exist "_OUT_APK\%%~nF!postfix!%%~xF" (
				set postfix=_%%P
			)
		)
	)
	echo [*] !str_signing! %%~nxF...
	set "sign_folder=_INPUT_APK"
	set "sign_name=%%~nF"
	set "sign_out=_OUT_APK\%%~nF!postfix!%%~xF"
	call :sign "%%~xF"
)
echo.
if !error_count! GTR 0 (cecho {!colR!}%str_doneerrors%{# #}{\n}) else (cecho {!colG!}!str_done!{# #}{\n})
call :measure_time stop
echo !elapsed_time!
pause
goto restart
:sign
set sign_error=0
COPY "!sign_folder!\!sign_name!%~1" "%bindir%temp\!sign_name!_%~1" >nul
7z d -tzip "%bindir%temp\!sign_name!_%~1" META-INF\*.MF META-INF\*.SF META-INF\*.RSA META-INF\*.DSA META-INF\*.EC META-INF\sig-* >nul 2>nul
if errorlevel 1 (
	zip -d -ic "%bindir%temp\!sign_name!_%~1" META-INF/*.MF META-INF/*.SF META-INF/*.RSA META-INF/*.DSA META-INF/*.EC META-INF/sig-* >nul %~2
)
set opt_sign=
if /I "%~1"==".apk" (
	zipalign -f -p 4 "%bindir%temp\!sign_name!_%~1" "!sign_out!" >nul %~2
	if "!errorlevel!"=="0" (
		if %produce_v4_sign%==OFF (set opt_sign=--v4-signing-enabled false)
		if %force_sign_v1%==ON (set opt_sign=--min-sdk-version 10 !opt_sign!)
		java -Xmx1024M -Xss1m -jar "%bindir%apksigner.jar" sign --key "%bindir%!key_name!" --cert "%bindir%!key_base!.x509.pem" !opt_sign! "!sign_out!" >nul %~2
		if not "!errorlevel!"=="0" set sign_error=1
	) else (
		set sign_error=1
	)
) else (
	if %produce_v4_sign%==OFF (set opt_sign=--v2-signing-enabled false --v3-signing-enabled false --v4-signing-enabled false)
	java -Xmx1024M -Xss1m -jar "%bindir%apksigner.jar" sign --key "%bindir%!key_name!" --cert "%bindir%!key_base!.x509.pem" --out "!sign_out!" --min-sdk-version 10 !opt_sign! "%bindir%temp\!sign_name!_%~1" >nul %~2
	if not "!errorlevel!"=="0" set sign_error=1
)
if "!sign_error!"=="1" (
	set /A error_count+=1
	cecho {!colR!}[*] !str_signing_error! !sign_name!%~1{# #}{\n}
	del /f /q "!sign_out!" 2>nul
)
del /f /q "%bindir%temp\!sign_name!_%~1" 2>nul
goto:eof
:zipalignoutapks
set error_count=0
call :measure_time start
FOR %%F IN ("_INPUT_APK\!apk_name!") DO (
	set postfix=
	if %set_postfix%==ON (
		FOR /L %%P IN (1,1,100) DO (
			if exist "_OUT_APK\%%~nF!postfix!%%~xF" (
				set postfix=_%%P
			)
		)
	)
	echo [*] !str_zipal! %%~nxF...
	zipalign -f -p 4 "_INPUT_APK\%%~nxF" "_OUT_APK\%%~nF!postfix!%%~xF" >nul
	if not "!errorlevel!"=="0" (
		set /A error_count+=1
		cecho {!colR!}[*] !str_zipal_error! %%~nxF{# #}{\n}
	)
)
echo.
if !error_count! GTR 0 (cecho {!colR!}%str_doneerrors%{# #}{\n}) else (cecho {!colG!}!str_done!{# #}{\n})
call :measure_time stop
echo !elapsed_time!
pause
goto restart
:javasource
set temp_name=
for /f "delims=" %%a in ('FileToOpen "set temp_name=" ".\*.apk;*.dex;*.jar;*.class;*.smali;*.zip;*.aar;*.arsc;*.jadx.kts;*.xapk;*.apkm;*.apks;*.jadx;*.aab" "!str_dragajd!"') do %%a
if not '!temp_name!'=='' (
	start cmd /c %bindir%tools\jadx\bin\jadx-gui.bat !temp_name!
)
goto restart
:: --------------------
:log_version
echo -------------------------------------------------->%~1
echo Batch ApkTool                : !bat_version!>>%~1
if '%~2'=='apktool' (
	echo APKTOOL                      : !apktool!>>%~1
	if not %save_orig_manifest%==OFF (
		echo Save AndroidManifest.xml     : !str_%save_orig_manifest%!>>%~1
	)
	echo !str_signafter_log! : !str_%sign_after%!>>%~1
)
if '%~2'=='smali' (
	echo SMALI                        : !smali!>>%~1
	echo !str_apilevel_log! : !api!>>%~1
	echo !str_signafter_log! : !str_%sign_after%!>>%~1
)
if '%~2'=='smali-jar' (
	echo SMALI                        : !smali!>>%~1
	echo !str_apilevel_log! : !api!>>%~1
)
if '%~2'=='apkeditor' (
	echo APKEDITOR                    : !apkeditor!>>%~1
	echo !str_signafter_log! : !str_%sign_after%!>>%~1
)
echo -------------------------------------------------->>%~1
echo.>>%~1
goto:eof
:job_done
echo.>>%~1
if !error_count! GTR 0 (
	echo %str_doneerrors%>>%~1
) else (
	echo !str_done!>>%~1
)
call :measure_time stop
echo !elapsed_time! >>%~1
REM convert logfiles to UTF8
::sfk atou "%~1" -codepage=!str_codepage! -tofile "%~1" >nul
nhrt -sre:"([^^\r])\n" -fet:"$1\r\n" -cp:!str_codepage!,UTF-8_BOM "%~1" >nul
echo.
if !error_count! GTR 0 (
	cecho {!colR!}%str_doneerrors%{# #}{\n}
	echo !elapsed_time!
	if %tray_notifications%==ON (
		start nircmd trayballoon "Batch ApkTool" "%str_doneerrors%" "!rootdir!\BatchApkTool.exe" 3000
	)
	if %sound_notifications%==ON (
		start nircmd speak text "Done with errors"
	)
) else (
	cecho {!colG!}!str_done!{# #}{\n}
	echo !elapsed_time!
	if %tray_notifications%==ON (
		start nircmd trayballoon "Batch ApkTool" "!str_done!" "!rootdir!\BatchApkTool.exe" 3000
	)
	if %sound_notifications%==ON (
		start nircmd speak text "Done"
	)
)
if %open_log%==ON (
	start %~1
	pause
) else (
	SET INPUT=
	SET /P INPUT=!str_press1! 
	IF !INPUT!==1 start %~1
)
goto:eof
:get_date_time
set DATE2=!DATE:/=-!
set DATE2=!DATE2: =_!
set TIME2=!TIME::=.!
set TIME2=!TIME2: =!
set TIME2=!TIME2:~0,-3!
goto:eof
:clean
cecho  {!colR!}!str_deletedialog!{# #} %~1{\n}
cecho  {!colG!}!str_proceed!{# #}{\n}
echo    1 = !str_yes!
echo    0 = !str_cancel!
:_clean
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT!==0 goto:eof
IF !INPUT!==1 (
	rd /s /q %~1 2>nul
	md %~1 2>nul
	cecho {!colG!}!str_done!{# #}{\n}
	pause
	goto:eof
)
goto _clean
:: --------------------
:setproject
pushd "!rootdir!"
set count=2
cecho {!colG!}  !str_selproj!{# #}{\n}
echo    1 = !str_usedefproj!
echo    2 = !str_createnewproj!
FOR /D %%F IN (*) DO (
	set x=%%~F
	if !x!==!x:_framework=! (
	if /I not "%%~F"=="_INPUT_APK" (
	if /I not "%%~F"=="_INPUT_JAR" (
	if /I not "%%~F"=="_OUT_APK" (
	if /I not "%%~F"=="_OUT_JAR" (
	if /I not "%%~F"=="_system" (
	if /I not "%%~F"=="bin" (
		set /A count+=1
		set name!count!=%%~nxF
		echo    !count! = %%~nxF
	)
	)
	)
	)
	)
	)
	)
	)
	)
)
popd
echo.
echo    0 = !str_cancel!
:_setproject
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT!==0 goto restart
if !INPUT! GTR !count! (goto _setproject)
if !INPUT! LSS 1 (goto _setproject)
set name1=.
:_project
if !INPUT!==2 (
	set name2=
	set /P name2=!str_inputprojname! 
	if '!name2!'=='' goto _project
)
set workdir=!name%INPUT%!
md "!workdir!" 2>nul
call :saveglobal "workdir"
goto restart3
:setcurrentapk
set temp_name=*
for /f "delims=" %%a in ('FileToOpen "set temp_name=" ".\_INPUT_APK\*.apk;*.zip;*.jar" "!str_selectapk!"') do %%a
if not '!temp_name!'=='*' (
	FOR %%F IN (!temp_name!) DO (
		if /I !temp_name!=="!cd!\_INPUT_APK\%%~nxF" (
			set temp_name=%%~nxF
		) else (
			goto setcurrentapk
		)
	)
)
if not '!temp_name!'=='!apk_name!' (
	set apk_name=!temp_name!
	call :savesettings "apk_name"
	goto restart2
)
goto restart
:setcurrentjar
set temp_name=*
for /f "delims=" %%a in ('FileToOpen "set temp_name=" ".\_INPUT_JAR\*.jar" "!str_selectjar!"') do %%a
if not '!temp_name!'=='*' (
	FOR %%F IN (!temp_name!) DO (
		if /I !temp_name!=="!cd!\_INPUT_JAR\%%~nxF" (
			set temp_name=%%~nxF
		) else (
			goto setcurrentjar
		)
	)
)
if not '!temp_name!'=='!jar_name!' (
	set jar_name=!temp_name!
	call :savesettings "jar_name"
	goto restart2
)
goto restart
:setapktoolversion
set count=0
cecho {!colG!}  !str_selectapktool!{# #}{\n}
FOR %%F IN ("%bindir%apktool_*.jar" "%bindir%apktool-*.jar") DO (
	set /A count+=1
	set name!count!=%%~nxF
	echo    !count! = %%~nxF
)
echo.
echo    0 = !str_cancel!
:_apktoolversion
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT!==0 goto restart
if !INPUT! GTR !count! (goto _apktoolversion)
if !INPUT! LSS 1 (goto _apktoolversion)
set apktool=!name%INPUT%!
call :savesettings "apktool"
goto restart2
:setsbversion
set count=0
cecho {!colG!}  !str_selectsmali!{# #}{\n}
FOR %%F IN ("%bindir%smali-*.jar" "%bindir%smali_*.jar") DO (
	set /A count+=1
	set name!count!=%%~nxF
	echo    !count! = %%~nxF
)
echo.
echo    0 = !str_cancel!
:_sbversion
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT!==0 goto restart
if !INPUT! GTR !count! (goto _sbversion)
if !INPUT! LSS 1 (goto _sbversion)
set smali=!name%INPUT%!
call :savesettings "smali"
goto restart2
:setapi
echo !bat_line!
cecho {!colG!}  !str_apilevels! !str_aversions!{# #}{\n}
echo !bat_line!
echo   37              Android 17 (CINNAMON_BUN)
echo   36              Android 16 (BAKLAVA)
echo   35              Android 15 (VANILLA_ICE_CREAM)
echo   34              Android 14 (UPSIDE_DOWN_CAKE)
echo   33              Android 13 (TIRAMISU)
echo   31              Android 12 (S)
echo   30              Android 11 (R)
echo   29              Android 10 (Q)
echo   28              Android 9 (P)
echo   26              Android 8.0 (O)
echo   24              Android 7.0 (N)
echo   23              Android 6.0 (M)
echo   21              Android 5.0 (LOLLIPOP)
echo   19              Android 4.4 (KITKAT)
echo   15              Android 4.0 (ICE_CREAM_SANDWICH)
echo   10              Android 2.3 (GINGERBREAD)
echo.
echo    0 = !str_cancel!
:_api
set INPUT=
set /P INPUT=!str_enterapi! 
if !INPUT!==0 goto restart
::set x=-10-15-16-17-18-19-
::if !x!==!x:-%INPUT%-=! (
if !INPUT! GTR 37 (
	cecho {!colR!}!str_invalidapi!{# #}{\n}
	goto _api
)
if !INPUT! LSS 1 (
	cecho {!colR!}!str_invalidapi!{# #}{\n}
	goto _api
)
set api=!INPUT!
call :savesettings "api"
goto restart
:setsignkey
set count=0
cecho {!colG!}  !str_selectkey!{# #}{\n}
FOR %%F IN (%bindir%*.pk8) DO (
	set /A count+=1
	set name!count!=%%~nxF
	echo    !count! = %%~nxF
)
echo.
echo    0 = !str_cancel!
:_signkey
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT!==0 goto restart
if !INPUT! GTR !count! (goto _signkey)
if !INPUT! LSS 1 (goto _signkey)
set key_name=!name%INPUT%!
call :savesettings "key_name"
goto restart2
:setlanguage
set count=0
cecho {!colG!}!str_selectlang!{# #}{\n}
FOR %%F IN (%bindir%language\*.lng) DO (
	set /A count+=1
	set name!count!=%%~nF
	echo   !count! = %%~nF
)
:_language
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT! GTR !count! (goto _language)
if !INPUT! LSS 1 (goto _language)
set language=!name%INPUT%!
echo language=!language!>%bindir%language\lang
:__language
chcp 1252>nul
for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%language\english.lng"') do set str_%%a=%%b
if "!language!"=="english" goto:eof
for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%language\!language!.lng"') do (
	if "%%a"=="codepage" chcp %%b>nul
)
for /F "eol=; tokens=1* delims==" %%a in ('type "%bindir%language\!language!.lng"') do set str_%%a=%%b
goto:eof
:set_res_mode
if %res_resolve_mode%==default (set res_resolve_mode=greedy& goto set_res_mode_done)
if %res_resolve_mode%==greedy (set res_resolve_mode=lazy& goto set_res_mode_done)
set res_resolve_mode=default
:set_res_mode_done
call :savesettings "res_resolve_mode"
goto restart
:setdeldebuginfo
if %deldebuginfo%==ON (set deldebuginfo=OFF) else (set deldebuginfo=ON)
call :savesettings "deldebuginfo"
goto restart
:setsign
if %sign_after%==ON (set sign_after=OFF) else (set sign_after=ON)
call :savesettings "sign_after"
goto restart
:savesettings
if not exist batchapktool.ini type nul >batchapktool.ini
inifile batchapktool.ini [settings] "%~1=!%~1!"
goto:eof
:saveglobal
if not exist "%bindir%settings.ini" type nul >"%bindir%settings.ini"
start /B inifile "%bindir%settings.ini" [global_settings] "%~1=!%~1!"
goto:eof
:: --------------------
:decompile_apkeditor
set count2=0
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (set /A count2+=1)
if %count2%==0 (
	cecho {!colR!}[*] !str_inputapk_empty!{# #}{\n}
	pause
	goto restart
)
if %rewrite_check%==ON (
	call :check_rewrite "_INPUT_APK" "!apk_base!.apk" "_apkeditor"
	if !_temp_!==0 goto restart
)
call :measure_time start
set error_count=0
call :log_version "log_decompile_apkeditor.txt" "apkeditor"
set apkeditor_frameworks=
FOR /f "delims=" %%F IN ('sfk list -quiet -quot "!framedir!" .apk 2^>nul') DO (
	set apkeditor_frameworks=-framework "!framedir!\%%~nxF" !apkeditor_frameworks!
)
if %deldebuginfo%==ON (set opt_decompile=-no-dex-debug %opt_decompile%)
set count3=0
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_decompiling! %%~nxF...
	echo [*] !str_decompiling! %%~nxF>>log_decompile_apkeditor.txt
	rd /s /q "_INPUT_APK\%%~nF_apkeditor" 2>nul
	java -jar "%bindir%!apkeditor!" d -i "_INPUT_APK\%%~nxF" -o "_INPUT_APK\%%~nF_apkeditor" !apkeditor_frameworks! -f !opt_decompile! >>log_decompile_apkeditor.txt 2>&1
	if not "!errorlevel!"=="0" (
		set /A error_count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_decompiling_error! %%~nxF>>log_decompile_apkeditor.txt
	) else (
		echo.
	)
	echo.>>log_decompile_apkeditor.txt
)
call :job_done "log_decompile_apkeditor.txt"
goto restart
:recompile_apkeditor
call :measure_time start
set error_count=0
call :log_version "log_recompile_apkeditor.txt" "apkeditor"
set apkeditor_frameworks=
FOR /f "delims=" %%F IN ('sfk list -quiet -quot "!framedir!" .apk 2^>nul') DO (
	set apkeditor_frameworks=-framework "!framedir!\%%~nxF" !apkeditor_frameworks!
)
set count2=0
set count3=0
FOR /D %%F IN ("_INPUT_APK\!apk_base!_apkeditor") DO (set /A count2+=1)
FOR /D %%F IN ("_INPUT_APK\!apk_base!_apkeditor") DO (
	set /A count3+=1
	title !title_text! [!count3!/!count2!]
	cecho [*] !str_recompiling! %%~nxF...
	echo [*] !str_recompiling! %%~nxF >>log_recompile_apkeditor.txt
	java -jar "%bindir%!apkeditor!" b -i "_INPUT_APK\%%~nxF" -o "_OUT_APK\%%~nxF.apk" !apkeditor_frameworks! -f >>log_recompile_apkeditor.txt 2>&1
	if not "!errorlevel!"=="0" (
		set /A error_count+=1
		cecho {!colR!} !str_error!{# #}{\n}
		echo [*] ---^> !str_recompiling_error! "%%~nxF">>log_recompile_apkeditor.txt
	) else (
		echo.
		set postfix=
		if %set_postfix%==ON (
			FOR /L %%P IN (1,1,100) DO (
				if exist "_OUT_APK\%%~nxF!postfix!.apk" (
					set postfix=_%%P
				)
			)
		)
		if %sign_after%==ON (
			set "sign_folder=_OUT_APK"
			set "sign_name=%%~nxF!postfix!"
			set "sign_out=_OUT_APK\%%~nxF!postfix!.apk"
			call :sign ".apk" "2>>log_recompile_apkeditor.txt"
		) else (
			zipalign -f -p 4 "_OUT_APK\%%~nxF!postfix!.apk" "_OUT_APK\%%~nxF!postfix!.apk" >nul 2>>log_recompile_apkeditor.txt
		)
	)
	echo.>>log_recompile_apkeditor.txt
)
call :job_done "log_recompile_apkeditor.txt"
goto restart
:mergeapks
set temp_name=
for /f "delims=" %%a in ('FileToOpen "set temp_name=" ".\*.apks;*.apkm;*.xapk" "!str_selectapk!" /multiselect') do %%a
if defined temp_name (
	call :log_version "log_merge.txt" "apkeditor"
	call :measure_time start
	set error_count=0
	FOR %%F IN (!temp_name!) DO (
		call :GetParent "%%~F" "apks_folder"
		set postfix=
		if %set_postfix%==ON (
			FOR /L %%P IN (1,1,100) DO (
				if exist "!apks_folder!\%%~nF_merged!postfix!.apk" (
					set postfix=_%%P
				)
			)
		)
		cecho [*] !str_merging! %%~nxF...
		echo [*] !str_merging! %%~nxF>>log_merge.txt
		java -jar "%bindir%!apkeditor!" m -f -i "%%~F" -o "!apks_folder!\%%~nF_merged!postfix!.apk" >>log_merge.txt 2>&1
		if not "!errorlevel!"=="0" (
			set /A error_count+=1
			cecho {!colR!} !str_error!{# #}{\n}
		) else (
			echo.
		)
		if %sign_after%==ON (
			set "sign_folder=!apks_folder!"
			set "sign_name=%%~nF_merged!postfix!"
			set "sign_out=!apks_folder!\%%~nF_merged!postfix!.apk"
			call :sign ".apk" "2>>log_merge.txt"
		)
		echo.>>log_merge.txt
	)
	call :job_done "log_merge.txt"
)
goto restart
:GetParent "input_string" "var_with_string_before_backslash" "var_with_string_after_backslash"
set "str=%~1"
FOR /L %%P IN (2,1,260) DO (
	if "!str:~-%%P,1!"=="\" (
		set "%~2=!str:~0,-%%P!"
		if not "%~3"=="" (
			set "str=!str:~-%%P!"
			set "%~3=!str:\=!"
		)
		goto:eof
	)
)
set "%~2="
if not "%~3"=="" (set "%~3=%~1")
goto:eof
:baksmaliapk
if %rewrite_check%==ON (
	call :check_rewrite "_INPUT_APK" "!apk_base!.apk"
	if !_temp_!==0 goto restart
)
set error_count=0
call :measure_time start
call :log_version "%logD%" "smali"
if %old_smali%==1 (
	set opt=-l -s
	if %deldebuginfo%==ON (set opt=-b -l -s)
) else (
	set opt=d -l --sl
	if %deldebuginfo%==ON (set opt=!opt! --di false)
)
FOR %%F IN ("_INPUT_APK\!apk_base!.apk") DO (
	echo [*] !str_baksmaling! %%~nxF...
	echo [*] !str_baksmaling! %%~nxF...>>%logD%
	set "_name_=%%~nF"
	call :baksmali "apk"
)
call :job_done "%logD%"
goto restart
:baksmalijar
if %rewrite_check%==ON (
	call :check_rewrite "_INPUT_JAR" "!jar_base!.jar"
	if !_temp_!==0 goto restart
)
set error_count=0
call :measure_time start
call :log_version "%logD%" "smali-jar"
if %old_smali%==1 (
	set opt=
	if %deldebuginfo%==ON (set opt=-b)
) else (
	set opt=d
	if %deldebuginfo%==ON (set opt=!opt! --di false)
)
FOR %%F IN ("_INPUT_JAR\!jar_base!.jar") DO (
	echo [*] !str_baksmaling! %%~nxF...
	echo [*] !str_baksmaling! %%~nxF...>>%logD%
	set "_name_=%%~nF"
	call :baksmali "jar"
)
call :job_done "%logD%"
goto restart
:smaliapk
set error_count=0
call :measure_time start
call :log_version "%logR%" "smali"
if %old_smali%==1 (
	set opt=
) else (
	set opt=a
)
FOR /D %%F IN ("_INPUT_APK\!apk_base!") DO (
	set "apk_dir=%%~nxF"
	if not "!apk_dir:~-10!"=="_apkeditor" (
		echo [*] !str_smaling! %%~nxF...
		echo [*] !str_smaling! %%~nxF...>>%logR%
		set "_name_=%%~nxF"
		call :smali "apk"
	)
)
call :job_done "%logR%"
goto restart
:smalijar
set error_count=0
call :measure_time start
call :log_version "%logR%" "smali-jar"
if %old_smali%==1 (
	set opt=
) else (
	set opt=a
)
FOR /D %%F IN ("_INPUT_JAR\!jar_base!") DO (
	echo [*] !str_smaling! %%~nxF...
	echo [*] !str_smaling! %%~nxF...>>%logR%
	set "_name_=%%~nxF"
	call :smali "jar"
)
call :job_done "%logR%"
goto restart
:baksmali
rd /s /q "_INPUT_%~1\!_name_!" 2>nul
7z x -tzip "_INPUT_%~1\!_name_!.%~1" -o"_INPUT_%~1\!_name_!" *.dex -aoa -sccWIN >nul 2>>%logD%
set count2=0
FOR %%F IN ("_INPUT_%~1\!_name_!\*.dex") DO (set /A count2+=1)
if %count2%==0 (
	cecho {!colG!}!str_dex_notfound!{# #}{\n}
	echo !str_dex_notfound!>>%logD%
	goto:eof
)
FOR %%F IN ("_INPUT_%~1\!_name_!\*.dex") DO (
	if /I "%%~nF"=="classes" (set REN2=smali) else (set REN2=smali_%%~nF)
	if not %count2%==1 (
		echo  - %%~nxF
		echo  - %%~nxF>>%logD%
	)
	java -Xmx1024m -jar "%bindir%bak!smali!" %opt% -a %api% -o "_INPUT_%~1\!_name_!\!REN2!" "%%~F" >>%logD% 2>&1
	if not "!errorlevel!"=="0" (
		set /A error_count+=1
		cecho {!colR!}[*] !str_bsmerror! !_name_!.%~1:%%~nxF{# #}{\n}
		echo [*] ---^> !str_bsmerror! !_name_!.%~1:%%~nxF>>%logD%
	)
)
del /f /q "_INPUT_%~1\!_name_!\*.dex" 2>nul
goto:eof
:smali
FOR /D %%F IN ("_INPUT_%~1\!_name_!\smali*") DO (
	set REN2=%%~nxF
	if /I "%%~nxF"=="smali" (set REN2=classes) else (set REN2=!REN2:smali_=!)
	java -Xmx1024m -jar "%bindir%!smali!" %opt% -a %api% -o "_INPUT_%~1\!_name_!\!REN2!.dex" "%%~F" >>%logR% 2>&1
	if not "!errorlevel!"=="0" (
		set /A error_count+=1
		cecho {!colR!}[*] !str_smerror! !_name_!{# #}{\n}
		echo [*] ---^> !str_smerror! !_name_!>>%logR%
		goto:eof
	)
)
if not exist "_INPUT_%~1\!_name_!.%~1" (
	set /A error_count+=1
	cecho {!colR!}[*] !str_orignotfound!{# #}{\n}
	echo [*] ---^> !str_orignotfound!>>%logR%
	goto:eof
)
COPY "_INPUT_%~1\!_name_!.%~1" "%bindir%temp\" >nul
7z a -tzip "%bindir%temp\!_name_!.%~1" ".\_INPUT_%~1\!_name_!\*.dex" -mx!dex_compression_level! >nul 2>nul
if errorlevel 1 (
	zip -j -!dex_compression_level! "%bindir%temp\!_name_!.%~1" "_INPUT_%~1\!_name_!\*.dex" >nul 2>>%logR%
)
set postfix=
if %set_postfix%==ON (
	FOR /L %%P IN (1,1,100) DO (
		if exist "_OUT_%~1\!_name_!!postfix!.%~1" (
			set postfix=_%%P
		)
	)
)
if /I "%~1"=="jar" (
	zipalign -f -p 4 "%bindir%temp\!_name_!.%~1" "_OUT_%~1\!_name_!!postfix!.%~1" >nul 2>>%logR%
)
if /I "%~1"=="apk" (
	if %sign_after%==ON (
		set "sign_folder=%bindir%temp"
		set "sign_name=!_name_!"
		set "sign_out=_OUT_%~1\!_name_!!postfix!.%~1"
		call :sign ".%~1" "2>>%logR%"
	) else (
		zipalign -f -p 4 "%bindir%temp\!_name_!.%~1" "_OUT_%~1\!_name_!!postfix!.%~1" >nul 2>>%logR%
	)
)
del /f /q "%bindir%temp\!_name_!.%~1" 2>nul
goto:eof
:: --------------------
:adbdevices
::cecho {!colG!}  !str_connection_type!{# #}{\n}
set count=0
for /f "skip=1 tokens=1* delims=	" %%a in ('adb devices') do (
	set /A count+=1
	set device!count!=%%~a
	set device_!count!=%%~b
	set device__!count!=device
)
if %OS_version% GEQ 7600 (
	for /f "skip=1 tokens=1,2,3 delims=	" %%a in ('adb mdns services') do (
		set /A count+=1
		set device!count!=%%~c
		set x=%%b
		if !x!==!x:pairing=! (
			set device_!count!=%%~a
			set device__!count!=tcp
		) else (
			set device_!count!=%%~a ***
			set device__!count!=pairing
		)
	)
)
if !count!==0 (
	set ANDROID_SERIAL=
	set adb_mode=off
	cecho {!colR!}[*] !str_devices_not_found!^^!{# #}{\n}
)
if not '!adb_ip!'=='' (
	set /A count+=1
	set device!count!=!adb_ip!
	set device_!count!=MANUAL
	set device__!count!=tcp
)
set /a count_qr=!count! + 1
set INPUT=
if !count!==0 (
	echo    !count_qr! = !str_connect_qr!
	echo    0 = !str_cancel!
	SET /P INPUT=[*] !str_input_ip! 
) else (
	FOR /L %%a IN (1,1,!count!) DO (
		if '!device_%%a!'=='device' (
			cecho    %%a = !device%%a! [{!colG!}!device_%%a!{# #}]{\n}
		) else (
			if '!device_%%a!'=='offline' (
				cecho    %%a = !device%%a! [{!colR!}!device_%%a!{# #}]{\n}
			) else (
				if '!device_%%a!'=='unauthorized' (
					cecho    %%a = !device%%a! [{!colY!}!device_%%a!{# #}]{\n}
				) else (
					echo    %%a = !device%%a! [!device_%%a!]
				)
			)
		)
	)
	echo    !count_qr! = !str_connect_qr!
	echo    0 = !str_cancel!
	SET /P INPUT=[*] !str_input_ip3!: 
)
if !INPUT!==!count_qr! goto adbqr
if !INPUT!==0 goto restart
if '!INPUT!'=='' goto adbdevices
set INPUT=!INPUT:,=.!
set device0=!device%INPUT%!
set device__0=!device__%INPUT%!
if !INPUT!==!INPUT:.=! (
	if !INPUT:~-1!==d (
		adb disconnect !device%INPUT:~0,-1%!
		if "!ANDROID_SERIAL!"=="!device%INPUT:~0,-1%!" set ANDROID_SERIAL=
		pause
	)
	if !INPUT! GTR !count! (goto adbdevices)
	if !INPUT! LSS 1 (goto adbdevices)
	if !device__0!==device (
		set ANDROID_SERIAL=!device0!
		set adb_mode=connected
	)
	if !device__0!==pairing (
		adb pair !device0!
		pause
	)
	if !device__0!==tcp (
		set ANDROID_SERIAL=!device0!
		set adb_mode=connected
		adb connect !device0!
		pause
	)
) else (
	if !INPUT:~-1!==p (
		adb pair !INPUT:~0,-1!
		pause
	) else (
		set ANDROID_SERIAL=!INPUT!
		set adb_mode=connected
		set adb_ip=!INPUT!
		call :savesettings "adb_ip"
		adb connect !INPUT!
		pause
	)
)
goto restart
:adbqr
pushd "%bindir%temp"
set "tempdir=!CD!"
popd
<nul set /p =[*] Connecting..
type NUL > "!tempdir!\adb_qr.txt"
echo n|start /wait cmd /c "mode 38,30& python "%bindir%tools\adb_qr\adb_qr.py" --pair-only"
set device_ip=
set device_guid=
for /f "tokens=1-7 delims=[=]: " %%a in ('type "!tempdir!\adb_qr.txt"') do (
	if "%%a_%%b_%%c"=="Successfully_paired_to" (
		set "device_ip=%%d"
		set "device_guid=%%g"
	)
)
if not defined device_ip (
	cecho  {!colR!}!str_error!{# #}{\n}
	pause
	goto restart
)
nircmd wait 1000
set count=0
for /f "skip=1 tokens=1-3 delims=:	" %%a in ('adb devices') do (
	if "%%b"=="device" (
		set /A count+=1
		set "device!count!=%%a"
		set "device_!count!="
	)
	if "%%c"=="device" (
		set /A count+=1
		set "device!count!=%%a"
		set "device_!count!=%%b"
	)
)
FOR /L %%a IN (1,1,!count!) DO (
	if "!device%%a!"=="!device_ip!" (
		cecho  {!colG!}!device%%a!:!device_%%a!{# #}{\n}
		set "ANDROID_SERIAL=!device%%a!:!device_%%a!"
		pause
		goto restart
	)
	if "!device%%a:~0,10!"=="!device_guid:~0,10!" (
		cecho  {!colG!}!device%%a!{# #}{\n}
		set "ANDROID_SERIAL=!device%%a!"
		pause
		goto restart
	)
)
for /f "skip=1 tokens=1-4 delims=:	" %%a in ('adb mdns services') do (
	set x=%%b
	if !x!==!x:pairing=! (
		if "%%c"=="!device_ip!" (
			for /f "delims=" %%e in ('adb connect %%c:%%d') do (
				set y=%%e
				if not !y!==!y:connected=! (
					cecho  {!colG!}!y!{# #}{\n}
					set "ANDROID_SERIAL=%%c:%%d"
					pause
					goto restart
				)
			)
		)
	)
)
cecho  {!colR!}!str_error!{# #}{\n}
pause
goto restart
:adbpackagemanager
cecho {!colG!}  !str_installtodef!{# #}{\n}
echo    1 = !str_singlefile!
echo    2 = !str_allfrom! _OUT_APK
echo    3 = !str_allfrom! _system
echo.
cecho {!colG!}  !str_adbpkg!:{# #}{\n}
echo    4 = !str_pkgall!
echo    5 = !str_pkgsys!
echo    6 = !str_pkgusr!
echo    7 = !str_pkgdis!
echo    8 = !str_pkgdel!
echo    9 = !str_pkglist!
echo.
echo    0 = !str_cancel!
:_adbpackagemanager
set INPUT=
SET /P INPUT=!str_makechoice! 
:_adbpackagemanager_quick
IF !INPUT!==1 (
	set temp_name=
	for /f "delims=" %%a in ('FileToOpen "set temp_name=" ".\*.apk;*.apks;*.apkm;*.xapk" "!str_selectapk!" /multiselect') do %%a
	if defined temp_name (
		call :get_sdk
		FOR %%F IN (!temp_name!) DO (
			echo [*] !str_installing! %%~nxF...
			if /I "%%~xF"==".apk" (
				adb install -r -t !install_opt! "%%~F"
			) else (
				set "apks_file=%%~F"
				call :install_apks
			)
		)
		pause
	)
	call :restart "refresh_menu"
	goto adbpackagemanager
)
IF !INPUT!==2 (
	call :get_sdk
	FOR %%F IN (_OUT_APK\*.apk _OUT_APK\*.xap) DO (
		echo [*] !str_installing! %%~nxF...
		if /I "%%~xF"==".apk" (
			adb install -r -t !install_opt! "%%~F"
		) else (
			set "apks_file=%%~F"
			call :install_apks
		)
	)
	pause
	call :restart "refresh_menu"
	goto adbpackagemanager
)
IF !INPUT!==3 (
	call :get_sdk
	FOR %%F IN (_system\*.apk _system\*.xap) DO (
		echo [*] !str_installing! %%~nxF...
		if /I "%%~xF"==".apk" (
			adb install -r -t !install_opt! "%%~F"
		) else (
			set "apks_file=%%~F"
			call :install_apks
		)
	)
	pause
	call :restart "refresh_menu"
	goto adbpackagemanager
)
IF !INPUT!==4 (
	set pkg_filter=ALL
	goto list_processing
)
IF !INPUT!==5 (
	set pkg_filter=SYSTEM
	goto list_processing
)
IF !INPUT!==6 (
	set pkg_filter=USER
	goto list_processing
)
IF !INPUT!==7 (
	set pkg_filter=DISABLED
	goto list_processing
)
IF !INPUT!==8 (
	set pkg_filter=UNINSTALLED
	goto list_processing
)
IF !INPUT!==9 (
	set temp_name=
	for /f "delims=" %%a in ('FileToOpen "set temp_name=" ".\*.txt"') do %%a
	if defined temp_name (
		set pkg_filter=FILE
		copy !temp_name! "%bindir%temp\apps-file.txt" >nul
		goto list_processing
	)
)
IF !INPUT!==0 (goto restart)
goto _adbpackagemanager
:get_sdk
set install_opt=
for /f "delims=" %%s in ('adb shell getprop ro.build.version.sdk ^| nhrt -set:\r -e -notitle') DO set "install_API=%%~s"
if /I !install_API! GEQ 34 (
	set install_opt=--bypass-low-target-sdk-block
)
goto:eof
:install_apks
del /f /q "%bindir%temp\APKs" 2>nul
md "%bindir%temp\APKs" 2>nul
7z x -tzip "!apks_file!" -o"%bindir%temp\APKs" *.apk -aoa -sccWIN >nul
set split_apks=
pushd "%bindir%temp\APKs"
FOR %%s IN (*.apk) DO (
	set split_apks=!split_apks!%%s 
)
adb install-multiple -r -t !install_opt! !split_apks!
popd
del /f /q "%bindir%temp\APKs" 2>nul
goto:eof
:list_processing
adb get-state >nul
if not "!errorlevel!"=="0" (
	pause
	goto restart
)
cls
adb push "%bindir%tools\app_manager" "/data/local/tmp/" >nul 2>nul
call :get_appslist
set FZF_DEFAULT_OPTS=--with-nth=3.. --layout=reverse --header="SELECT PACKAGE:" --ansi --no-sort --cycle --exact
set app_list_enc=utf-8
:list_processing2
set pkg_name=
set pkg_label=
if %OS_version% LSS 7600 goto list_legacy
for /f "tokens=1-3* delims=	 " %%a in ('python "%bindir%tools\package_list.py" ^| fzf ^| python "%bindir%tools\utf8to.py"') DO (
	set "pkg_status=%%~a"
	set "pkg_user=%%~b"
	set "pkg_name=%%~c"
	set "pkg_label=%%~d"
)
if not defined pkg_name (
	call :restart "refresh_menu"
	goto adbpackagemanager
)
:app_ready
cls
set "pkg_info1={04}(!pkg_user!){# #}"
set pkg_info2=
if "!pkg_user!"=="SYSTEM" set "pkg_info1={02}(SYSTEM){# #}"
if "!pkg_user!"=="USER" set "pkg_info1={06}(USER){# #}"
if "!pkg_status!"=="DISABLED" set "pkg_info2={09}(DISABLED){# #}"
if "!pkg_status!"=="UNINSTALLED" set "pkg_info2={04}(UNINSTALLED){# #}"
cecho {!colG!}Package:{# #} !pkg_name! !pkg_info1! !pkg_info2!{\n}
if defined pkg_label (cecho {!colG!}Label:{# #} !pkg_label!{\n})
set pkg_verN=
set pkg_verC=
set pkg_InstTime=
set pkg_UpdTime=
set pkg_codePath=
set pkg_splits=
set pkg_dexoptPath=
if not "!pkg_user!"=="NOT_FOUND" (
	FOR /f "tokens=1* delims==" %%a IN ('adb shell dumpsys package !pkg_name! ^| python "%bindir%tools\dumpsys_filter.py"') DO (
		if "%%~a"=="versionName" set "pkg_verN=%%~b"
		if "%%~a"=="versionCode" set "pkg_verC=%%~b"
		if "%%~a"=="firstInstallTime" set "pkg_InstTime=%%~b"
		if "%%~a"=="lastUpdateTime" set "pkg_UpdTime=%%~b"
		if "%%~a"=="codePath" set "pkg_codePath=%%~b"
		if "%%~a"=="splits" set "pkg_splits=%%~b"
		if "%%~a"=="path" set "pkg_dexoptPath=%%~b"
	)
)
if defined pkg_verN (cecho {!colG!}Version:{# #} !pkg_verN! ^(!pkg_verC!^){\n})
if defined pkg_InstTime (cecho {!colG!}Install Time:{# #} !pkg_InstTime!{\n}{!colG!}Update Time:{# #} !pkg_UpdTime!{\n})
set pkg_path0=NOT_FOUND
if defined pkg_codePath (
	set "pkg_path0=!pkg_codePath!"
	if not "!pkg_codePath:~-3!"=="apk" (
		if defined pkg_dexoptPath (
			if "!pkg_dexoptPath:~-3!"=="apk" set "pkg_path0=!pkg_dexoptPath!"
		)
	)
)
if not "!pkg_path0!"=="NOT_FOUND" (cecho {!colG!}Path:{# #} !pkg_path0!{\n})
if defined pkg_splits (
	if not "!pkg_splits!"=="[base]" cecho {!colG!}Splits:{# #} !pkg_splits!{\n}
)
echo !bat_line!
echo   1  = Open Google Play
echo   2  = UNINSTALL package
echo   3  = UNINSTALL package ^(keep data^)
echo   4  = CLEAR package data
echo   5  = DISABLE package
echo   6  = ENABLE package
echo   7  = BACKUP package APK
echo   8  = STOP process
echo   9  = LOGCAT package
echo   10 = DUMPSYS package
if "!pkg_status!"=="UNINSTALLED" echo   11 = unDELETE package
echo   0  = !str_cancel!
:app_ready2
set INPUT3=
SET /P INPUT3=!str_makechoice! 
IF "!INPUT3!"=="0" (
	cls
	goto list_processing2
)
if "!INPUT3!"=="1" start https://play.google.com/store/apps/details?id=!pkg_name!
if "!INPUT3!"=="2" (
	set INPUT4=
	SET /P INPUT4=[*] Uninstall !pkg_name!: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		if "!pkg_user!"=="SYSTEM" (
			adb shell pm uninstall --user 0 !pkg_name!
		) else (
			adb uninstall !pkg_name!
		)
		if "!errorlevel!"=="0" call :get_appinfo
		pause
		goto app_ready
	)
)
if "!INPUT3!"=="3" (
	set INPUT4=
	SET /P INPUT4=[*] Uninstall !pkg_name! ^(keep data^): ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		if "!pkg_user!"=="SYSTEM" (
			adb shell pm uninstall -k --user 0 !pkg_name!
		) else (
			adb uninstall -k !pkg_name!
		)
		if "!errorlevel!"=="0" call :get_appinfo
		pause
		goto app_ready
	)
)
if "!INPUT3!"=="4" (
	set INPUT4=
	SET /P INPUT4=[*] Clear data !pkg_name!: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		adb shell pm clear !pkg_name!
		echo [*] !str_done!
	)
)
if "!INPUT3!"=="5" (
	set INPUT4=
	SET /P INPUT4=[*] Disable !pkg_name!: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		adb shell pm disable-user --user 0 !pkg_name!
		if "!errorlevel!"=="0" call :get_appinfo
		pause
		goto app_ready
	)
)
if "!INPUT3!"=="6" (
	set INPUT4=
	SET /P INPUT4=[*] Enable !pkg_name!: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		adb shell pm enable !pkg_name!
		if "!errorlevel!"=="0" call :get_appinfo
		pause
		goto app_ready
	)
)
if "!INPUT3!"=="7" (
	set INPUT4=
	SET /P INPUT4=[*] Backup to !pkg_name!.apk: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		set count2=-1
		FOR /f "tokens=1* delims=:" %%a IN ('adb shell pm path !pkg_name! ^| nhrt -set:\r -e -notitle') DO (
			set /A count2+=1
			set "pkg_path!count2!=%%b"
		)
		if !count2! GTR 0 (
			del /f /q "%bindir%temp\APKs" 2>nul
			md "%bindir%temp\APKs" 2>nul
			pushd "%bindir%temp\APKs"
			adb pull -a "!pkg_path0!"
			if not "!errorlevel!"=="0" (
				popd
				cecho [*] {!colR!}!str_error!{# #}{\n}
				goto app_ready2
			)
			FOR /L %%a IN (1,1,!count2!) DO adb pull -a "!pkg_path%%a!"
			popd
			del /f /q "!pkg_name!.apks" 2>nul
			7z a -tzip "!pkg_name!.apks" ".\%bindir%temp\APKs\*.apk" >nul 2>nul
			del /f /q "%bindir%temp\APKs" 2>nul
		) else (
			adb pull -a "!pkg_path0!" !pkg_name!.apk
		)
		echo [*] !str_done!
	)
)
if "!INPUT3!"=="8" (
	set INPUT4=
	SET /P INPUT4=[*] Stop process !pkg_name!: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		adb shell am force-stop !pkg_name!
		echo [*] !str_done!
	)
)
if "!INPUT3!"=="9" (
	set INPUT4=
	SET /P INPUT4=[*] LOGCAT !pkg_name!: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		call :get_date_time
		start cmd /c "mode 120,999& adb logcat -v time -T 1 | python "%bindir%tools\coloredlogcat\logcat_filter.py" -p !pkg_name! -o "logcat_!pkg_name!_!DATE2!_!TIME2!.txt""
		echo [*] !str_saved_to_file! "logcat_!pkg_name!_!DATE2!_!TIME2!.txt"
	)
)
if "!INPUT3!"=="10" (
	set INPUT4=
	SET /P INPUT4=[*] DUMPSYS !pkg_name!: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		call :get_date_time
		adb shell dumpsys package !pkg_name!>"dumpsys_!pkg_name!_!DATE2!_!TIME2!.txt"
		echo [*] !str_saved_to_file! "dumpsys_!pkg_name!_!DATE2!_!TIME2!.txt"
	)
)
if "!pkg_status!"=="UNINSTALLED" (
if "!INPUT3!"=="11" (
	set INPUT4=
	SET /P INPUT4=[*] UnDelete !pkg_name!: ^(1-!str_ON!^) 
	if "!INPUT4!"=="1" (
		adb shell pm install-existing !pkg_name!
		if "!errorlevel!"=="0" call :get_appinfo
		pause
		goto app_ready
	)
)
)
goto app_ready2
:get_appslist
type NUL > "%bindir%temp\apps-info.txt"
adb shell "export CLASSPATH=/data/local/tmp/app_manager; app_process / Main" 2>nul >>"%bindir%temp\apps-info.txt"
set apps_source=adb
set x=null
set /p x=<"%bindir%temp\apps-info.txt"
FOR /f "tokens=1,2 delims=: " %%a IN ("!x!") DO (
	if "%%a"=="USER" if not "%%~b"=="" set apps_source=apm
)
::set apps_source=adb
if "!apps_source!"=="apm" goto:eof
type NUL > %bindir%temp\apps_system.txt
type NUL > %bindir%temp\apps_user.txt
type NUL > %bindir%temp\apps_disabled.txt
type NUL > %bindir%temp\apps_deleted.txt
if not !INPUT!==6 (
	adb shell pm list packages -s -u 2>nul >%bindir%temp\apps_system.txt
)
if not !INPUT!==5 (
if not !INPUT!==8 (
	adb shell pm list packages -3 2>nul >%bindir%temp\apps_user.txt
)
)
if not !INPUT!==8 (
	adb shell pm list packages -d 2>nul >%bindir%temp\apps_disabled.txt
)
if not !INPUT!==6 (
if not !INPUT!==7 (
	type NUL > %bindir%temp\apps-system.txt
	adb shell pm list packages -s 2>nul >%bindir%temp\apps-system.txt
)
)
goto:eof
:get_appinfo
call :get_appslist
set pkg_filter_BAK=!pkg_filter!
set pkg_filter=!pkg_name!
for /f "tokens=1-3* delims=	 " %%a in ('python "%bindir%tools\package_list.py" ^| python "%bindir%tools\utf8to.py"') DO (
	set "pkg_status=%%~a"
	set "pkg_user=%%~b"
	set "pkg_name=%%~c"
	set "pkg_label=%%~d"
)
set pkg_filter=!pkg_filter_BAK!
goto:eof
:list_legacy
set "app_list_enc=cp%str_codepage%"
set count=0
for /f "tokens=1-3* delims=	 " %%a in ('python "%bindir%tools\package_list.py"') DO (
	set /A count+=1
	set "device_!count!=%%a"
	set "device__!count!=%%b"
	set "device___!count!=%%d"
	set "device!count!=%%c"
)
cecho {09}SELECT PACKAGE:{# #}{\n}
FOR /L %%a IN (1,1,!count!) DO (
	set color=08
	if "!device__%%a!"=="SYSTEM" set color=02
	if "!device__%%a!"=="USER" set color=06
	if "!device_%%a!"=="DISABLED" set color=09
	if "!device_%%a!"=="UNINSTALLED" set color=04
	cecho   %%a = {!color!}!device%%a!{# #} !device___%%a!{\n}
	set /A MOD=%%a %% 45
	if !MOD! equ 0 pause
)
echo   0 = !str_cancel!
:_list_legacy
set INPUT2=
SET /P INPUT2=!str_makechoice! 
if "!INPUT2!"=="0" (
	call :restart "refresh_menu"
	goto adbpackagemanager
)
if !INPUT2! GTR !count! (goto _list_legacy)
if !INPUT2! LSS 1 (goto _list_legacy)
set "pkg_status=!device_%INPUT2%!"
set "pkg_user=!device__%INPUT2%!"
set "pkg_name=!device%INPUT2%!"
set "pkg_label=!device___%INPUT2%!"
goto app_ready
:adbremount
adb get-state >nul
if not "!errorlevel!"=="0" (
	pause
	goto restart
)
if not "!scrcpy_serial!"=="!ANDROID_SERIAL!" (
	set scrcpy_changed=1
	call :scrcpy_check
) else (
	set scrcpy_changed=
)
if defined scrcpy_changed (
	FOR /L %%a IN (2,1,18) DO set scrP%%a=
	if defined scr_cmd_!scrcpy_device_! (
		set "scr_cmd_=!scr_cmd_%scrcpy_device_%!"
	) else (
		set "scr_cmd_=!scr_cmd!"
	)
)
set scrG2=*
set scrG3=h264
set scrG4=FULL
set "scrG5=8M "
set scrG6=MAX
set scrG7=*
set scrG8=opus
set scrG9=128K
set "scrG10=50  "
set "scrG11= "
set "scrG12= "
set "scrG13= "
set scrG14=*
set "scrG15= "
set "scrG16= "
set "scrG17= "
set "scrP=!scr_cmd_!"
set scrP18=
:nextP
for /f "tokens=1* delims= " %%a in ("!scrP!") DO (
	for /f "tokens=1* delims==" %%f in ("%%a") DO (
		if %%f==--no-video set scrP2=--no-video& set "scrG2= "& set "scrP=%%b"& goto nextP
		if %%f==--video-codec (
			if %%g==h265 set scrP3=--video-codec=h265& set scrG3=h265
			if %%g==av1 set scrP3=--video-codec=av1& set "scrG3=av1 "
			if %%g==vp8 set scrP3=--video-codec=vp8& set "scrG3=vp8 "
			if %%g==vp9 set scrP3=--video-codec=vp9& set "scrG3=vp9 "
			set "scrP=%%b"& goto nextP
		)
		if %%f==--max-size (
			if %%g==1920 set scrP4=--max-size=1920& set scrG4=1920
			if %%g==1280 set scrP4=--max-size=1280& set scrG4=1280
			if %%g==640 set scrP4=--max-size=640& set "scrG4=640 "
			set "scrP=%%b"& goto nextP
		)
		if %%f==--video-bit-rate (
			if %%g==16M set scrP5=--video-bit-rate=16M& set scrG5=16M
			if %%g==4M set scrP5=--video-bit-rate=4M& set "scrG5=4M "
			if %%g==2M set scrP5=--video-bit-rate=2M& set "scrG5=2M "
			set "scrP=%%b"& goto nextP
		)
		if %%f==--max-fps (
			if %%g==60 set scrP6=--max-fps=60& set "scrG6=60 "
			if %%g==30 set scrP6=--max-fps=30& set "scrG6=30 "
			set "scrP=%%b"& goto nextP
		)
		if %%f==--no-audio set scrP7=--no-audio& set "scrG7= "& set "scrP=%%b"& goto nextP
		if %%f==--audio-codec (
			if %%g==flac set scrP8=--audio-codec=flac& set scrG8=flac
			if %%g==aac set scrP8=--audio-codec=aac& set "scrG8=aac "
			set "scrP=%%b"& goto nextP
		)
		if %%f==--audio-bit-rate (
			if %%g==256K set scrP9=--audio-bit-rate=256K& set scrG9=256K
			if %%g==64K set scrP9=--audio-bit-rate=64K& set "scrG9=64K "
			set "scrP=%%b"& goto nextP
		)
		if %%f==--audio-buffer (
			if %%g==500 set scrP10=--audio-buffer=500& set "scrG10=500 "
			if %%g==2500 set scrP10=--audio-buffer=2500& set scrG10=2500
			set "scrP=%%b"& goto nextP
		)
		if %%f==--keep-active set scrP11=--keep-active& set scrG11=*& set "scrP=%%b"& goto nextP
		if %%f==--turn-screen-off set scrP12=--turn-screen-off& set scrG12=*& set "scrP=%%b"& goto nextP
		if %%f==--always-on-top set scrP13=--always-on-top& set scrG13=*& set "scrP=%%b"& goto nextP
		if %%f==--no-control set scrP14=--no-control& set "scrG14= "& set "scrP=%%b"& goto nextP
		if %%f==--show-touches set scrP15=--show-touches& set scrG15=*& set "scrP=%%b"& goto nextP
		if %%f==--record set "scrP16=--record=record.mp4"& set scrG16=*& set "scrP=%%b"& goto nextP
		if %%f==--pause-on-exit set "scrP17=--pause-on-exit --print-fps"& set scrG17=*& set "scrP=%%b"& goto nextP
		if %%f==--print-fps set "scrP=%%b"& goto nextP
		if "%%g"=="" (set "scrP18=!scrP18! %%f") else (set "scrP18=!scrP18! %%f=%%g")
	)
	set "scrP=%%b"
)
if defined scrP goto nextP
cls
cecho !scrcpy_color!                                     ___  ___ _ __ ___ _ __  _   _ {\n}                                    / __^|/ __^| '__/ __^| '_ \^| ^| ^| ^| 4{\n}                                    \__ \ (__^| ^| ^| (__^| ^|_) ^| ^|_^| ^|{\n}                                    ^|___/\___^|_^|  \___^| .__/ \__, ^|{\n}                                                      ^|_^|    ^|___/ {# #}{\n}!bat_line!{\n}!scrcpy_color!Device: !scrcpy_device!{# #} !scrcpy_d0! (!scrcpy_v!) (!scrcpy_a!){\n}
echo.
cecho   1  {06}START scrcpy{# #}{\n}{\n}  2  Video {!colY!}!scrG2!{# #}           3  Codec: {!colY!}!scrG3!{# #}       4  Max size: {!colY!}!scrG4!{# #}     5  Bitrate: {!colY!}!scrG5!{# #}    6  Max fps: {!colY!}!scrG6!{# #}{\n}{\n}  7  Audio {!colY!}!scrG7!{# #}           8  Codec: {!colY!}!scrG8!{# #}       9  Bitrate: {!colY!}!scrG9!{# #}      10 Buffer: {!colY!}!scrG10!{# #}{\n}{\n}  11 Keep active {!colY!}!scrG11!{# #}     12 Screen off {!colY!}!scrG12!{# #}      13 Always top {!colY!}!scrG13!{# #}{\n}{\n}  14 Control {!colY!}!scrG14!{# #}         15 Show touches {!colY!}!scrG15!{# #}    16 Record {!colY!}!scrG16!{# #}{\n}{\n}  00 Debug {!colY!}!scrG17!{# #}{\n}
if defined scrP17 (
	echo   scrcpy !scr_cmd_! !scr_cmd_add!
)
echo.
cecho   {09}Shortcuts:{# #}{\n}
echo   Switch fullscreen mode    Alt + f ^| F11
echo   Click on HOME             Alt + h ^| Middle-click
echo   Click on BACK             Alt + b ^| Right-click
echo   Click on APP_SWITCH       Alt + s
echo   Click on VOLUME_UP        Alt + UP
echo   Click on VOLUME_DOWN      Alt + DOWN
echo   Click on POWER            Alt + p
echo   Turn device screen off    Alt + o
echo   Turn device screen on     Alt + Shift + o
echo   Rotate device screen      Alt + r
echo.
echo   0  !str_cancel!
echo.
set INPUT=
SET /P INPUT=!str_makechoice! 
if not defined INPUT goto adbremount
if defined scrP16 (
	call :get_date_time
	if defined scrP2 (
		set scr_format=opus
		if "%scrP8%"=="--audio-codec=flac" set scr_format=flac
		if "%scrP8%"=="--audio-codec=aac" set scr_format=aac
	) else (
		set scr_format=mp4
	)
)
if defined scrP17 (set scr_launch=start) else (set scr_launch=ConH)
IF !INPUT!==1 (
	if defined scrP16 (
		!scr_launch! scrcpy !scr_cmd_:record.mp4=record_%DATE2%_%TIME2%.%scr_format%! !scr_cmd_add!
	) else (
		!scr_launch! scrcpy !scr_cmd_! !scr_cmd_add!
	)
	goto adbremount
)
IF !INPUT!==0 (
	chcp !str_codepage!>nul
	goto restart
)
IF !INPUT!==2 (
	if "!scrP2!"=="" (set scrP2=--no-video) else (set scrP2=)
)
IF !INPUT!==3 (
	if "%scrP3%"=="" set scrP3=--video-codec=h265
	if "%scrP3%"=="--video-codec=h265" set scrP3=--video-codec=av1
	if "%scrP3%"=="--video-codec=av1" set scrP3=--video-codec=vp8
	if "%scrP3%"=="--video-codec=vp8" set scrP3=--video-codec=vp9
	if "%scrP3%"=="--video-codec=vp9" set scrP3=
)
IF !INPUT!==4 (
	if "%scrP4%"=="" set scrP4=--max-size=640
	if "%scrP4%"=="--max-size=640" set scrP4=--max-size=1280
	if "%scrP4%"=="--max-size=1280" set scrP4=--max-size=1920
	if "%scrP4%"=="--max-size=1920" set scrP4=
)
IF !INPUT!==5 (
	if "%scrP5%"=="" set scrP5=--video-bit-rate=16M
	if "%scrP5%"=="--video-bit-rate=16M" set scrP5=--video-bit-rate=2M
	if "%scrP5%"=="--video-bit-rate=2M" set scrP5=--video-bit-rate=4M
	if "%scrP5%"=="--video-bit-rate=4M" set scrP5=
)
IF !INPUT!==6 (
	if "%scrP6%"=="" set scrP6=--max-fps=30
	if "%scrP6%"=="--max-fps=30" set scrP6=--max-fps=60
	if "%scrP6%"=="--max-fps=60" set scrP6=
)
IF !INPUT!==7 (
	if "!scrP7!"=="" (set scrP7=--no-audio) else (set scrP7=)
)
IF !INPUT!==8 (
	if "%scrP8%"=="" set scrP8=--audio-codec=flac
	if "%scrP8%"=="--audio-codec=flac" set scrP8=--audio-codec=aac
	if "%scrP8%"=="--audio-codec=aac" set scrP8=
)
IF !INPUT!==9 (
	if "%scrP9%"=="" set scrP9=--audio-bit-rate=256K
	if "%scrP9%"=="--audio-bit-rate=256K" set scrP9=--audio-bit-rate=64K
	if "%scrP9%"=="--audio-bit-rate=64K" set scrP9=
)
IF !INPUT!==10 (
	if "%scrP10%"=="" set scrP10=--audio-buffer=500
	if "%scrP10%"=="--audio-buffer=500" set scrP10=--audio-buffer=2500
	if "%scrP10%"=="--audio-buffer=2500" set scrP10=
)
IF !INPUT!==11 (
	if "!scrP11!"=="" (set scrP11=--keep-active) else (set scrP11=)
)
IF !INPUT!==12 (
	if "!scrP12!"=="" (set scrP12=--turn-screen-off) else (set scrP12=)
)
IF !INPUT!==13 (
	if "!scrP13!"=="" (set scrP13=--always-on-top) else (set scrP13=)
)
IF !INPUT!==14 (
	if "!scrP14!"=="" (set scrP14=--no-control) else (set scrP14=)
)
IF !INPUT!==15 (
	if "!scrP15!"=="" (set scrP15=--show-touches) else (set scrP15=)
)
IF !INPUT!==16 (
	if "!scrP16!"=="" (set "scrP16=--record=record.mp4") else (set scrP16=)
)
IF !INPUT!==00 (
	if "!scrP17!"=="" (set "scrP17=--pause-on-exit --print-fps") else (set scrP17=)
)
set scrP=
FOR /L %%a IN (2,1,18) DO (
	if defined scrP%%a set "scrP=!scrP! !scrP%%a!"
)
set "scr_cmd_=!scrP!"
set "scr_cmd_!scrcpy_device_!=!scr_cmd_!"
call :savesettings "scr_cmd_!scrcpy_device_!"
goto adbremount
:scrcpy_check
set scrcpy_serial=N
set scrcpy_device=ERROR
set scrcpy_d0=
set scrcpy_color={!colR!}
set scrcpy_v=
set scrcpy_a=
FOR /f "usebackq tokens=1-3* delims=:= " %%a IN (`scrcpy --list-displays --list-encoders 2^>^&1`) DO (
	if /I "%%a_%%b_%%c"=="[server]_INFO_Device" (
		set x=%%d
		if not "!x:~-1!"==")" set "x=!x:~0,-1!"
		set "scrcpy_serial=!ANDROID_SERIAL!"
		set "scrcpy_device=!x!"
		set scrcpy_color={!colG!}
	)
	if /I "%%a"=="--video-codec" (
		if defined scrcpy_v (
			if "!scrcpy_v!"=="!scrcpy_v:%%b=!" set "scrcpy_v=!scrcpy_v!,%%b"
		) else (
			set "scrcpy_v=%%b"
		)
	)
	if /I "%%a"=="--audio-codec" (
		if defined scrcpy_a (
			if "!scrcpy_a!"=="!scrcpy_a:%%b=!" set "scrcpy_a=!scrcpy_a!,%%b"
		) else (
			set "scrcpy_a=%%b"
		)
	)
	if /I "%%a_%%b"=="--display-id_0" (
		set x=%%c
		if not "!x:~-1!"==")" set "x=!x:~0,-1!"
		set "scrcpy_d0=!x!"
	)
	if /I "%%a_%%b_%%c"=="ERROR_Could_not" (
		set scrcpy_device=NOT FIND
		set scrcpy_color=
	)
	if /I "%%a_%%b"=="ERROR_Multiple" (
		set scrcpy_device=MULTIPLE
		set scrcpy_color=
	)
)
set "scrcpy_device_=!scrcpy_device:android=!"
set "scrcpy_device_=!scrcpy_device_: =!"
set "scrcpy_device_=!scrcpy_device_:[=!"
set "scrcpy_device_=!scrcpy_device_:]=!"
set "scrcpy_device_=!scrcpy_device_:(=!"
set "scrcpy_device_=!scrcpy_device_:)=!"
goto:eof
:adbfilemanager
echo   !str_push2!:
cecho {!colG!}  1 = !str_pushto!: !push_folder!{# #}{\n}
echo    2 = !str_singlefile!
echo    3 = !str_allfrom! _system
echo.
echo   !str_pull2!
cecho {!colG!}  4 = !str_pullfrom!: !pull_folder!{# #}{\n}
echo    5 =  !str_pushto! _system
echo.
echo    0 = !str_cancel!
:_adbfilemanager
set INPUT=
SET /P INPUT=!str_makechoice! 
:_adbfilemanager_quick
IF !INPUT!==1 (
	call :select_path "push_folder"
	call :restart "refresh_menu"
	goto adbfilemanager
)
IF !INPUT!==2 (
	set temp_name=
	for /f "delims=" %%a in ('FileToOpen "set temp_name=" ".\*.*" /multiselect') do %%a
	if defined temp_name (
		FOR %%F IN (!temp_name!) DO (
			adb push "%%~F" "!push_folder!"
		)
		pause
	)
	call :restart "refresh_menu"
	goto adbfilemanager
)
IF !INPUT!==3 (
	adb push _system\. "!push_folder!"
	pause
	call :restart "refresh_menu"
	goto adbfilemanager
)
IF !INPUT!==4 (
	call :select_path "pull_folder"
	call :restart "refresh_menu"
	goto adbfilemanager
)
IF !INPUT!==5 (
	adb pull -a "!pull_folder!" _system
	pause
	call :restart "refresh_menu"
	goto adbfilemanager
)
IF !INPUT!==0 (goto restart)
goto _adbfilemanager
:select_path
if %OS_version% GEQ 7600 chcp 65001>nul
set path_name=/sdcard/
::check ls output format: OLD toolbox "d /sdcard/CR" or NEW toybox "/sdcard//"
set ls_out=new
set ls_out_cr=0
FOR /f "usebackq delims=" %%a IN (`adb shell ls -dF /sdcard/ 2^>nul`) DO (
	set "x=%%a"
	if "!x:~0,10!"=="d /sdcard/" set ls_out=old
	if not "!x:~-1!"=="/" set ls_out_cr=1
)
:_select_path
cls
echo.
cecho ^| {!colG!}+{# #} Create folder ^| {!colG!}-{# #}  Delete folder ^| {!colG!}*{# #}  Copy file from..   ^| {!colG!}/{# #}  Copy folder to.. ^| {!colG!}?{# #}  Rename folder  ^|{\n}^| {!colG!}.{# #} Select folder ^| {!colG!}-#[ #]{# #} Delete #  ^| {!colG!}**{# #} Copy folder from.. ^| {!colG!}/#[ #]{# #} Copy # to..  ^| {!colG!}?#{# #} Rename #       ^|{\n}!bat_line!{\n}{!colG!}[*] !str_current_folder!: !path_name!{# #}{\n}
set count=1
set count2=1
::only folders with full path: adb shell ls -d !path_name_!*/
::folders and files with relative path: -F  append /dir *exe @sym |FIFO
FOR /f "usebackq delims=" %%a IN (`adb shell ls -aF \"!path_name!\"`) DO (
	set "x=%%a"
	if !ls_out_cr!==1 set "x=!x:~0,-1!"
	set skip=0
	if !ls_out!==old (
		if "!x:~0,2!"=="- " (
			set "x=!x:~2!"
		) else (
			if "!x:~0,2!"=="d " (
				set "x=!x:~2!/"
			) else (
				if "!x:~0,3!"=="l- " (
					set "x=!x:~3!@"
				) else (
					if "!x:~0,3!"=="ld " (
						set "x=!x:~3!/"
					) else (
						if "!x:~0,2!"=="c " (
							set "x=!x:~2!"
						) else (
							echo !x!
							set skip=1
						)
					)
				)
			)
		)
	)
	if "!x!"=="./" set skip=1
	if "!x!"=="../" set skip=1
	if not "!x!"=="!x::=!" (
		echo !x!
		set skip=1
	)
	if !skip!==0 (
		if "!x:~-1!"=="/" (
			set /A count+=1
			set "device!count!=!x!"
		) else (
			set /A count2+=1
			set "device_!count2!=!x!"
		)
	)
)
echo    1 = ..
set device1=
FOR /L %%a IN (2,1,!count!) DO (
	echo    %%a = !device%%a!
	set /A MOD=%%a %% 42
	if !MOD! equ 0 pause
)
FOR /L %%a IN (2,1,!count2!) DO (
	set /A count+=1
	set "device!count!=!device_%%a!"
	echo    !count! = !device_%%a!
	set /A MOD=!count! %% 42
	if !MOD! equ 0 pause
)
echo    0 = !str_cancel!
set INPUT2=
SET /P INPUT2=!str_makechoice! 
set "parent=!path_name!"
FOR /L %%P IN (1,1,260) DO (
	if "!path_name:~-%%P,1!"=="/" (
		if %%P neq 1 (
			set "parent=!path_name:~0,-%%P!/"
			goto path_ready
		)
	)
)
:path_ready
if "!INPUT2!"=="0" (
	chcp !str_codepage!>nul
	goto:eof
)
if "!INPUT2!"=="1" (
	set "path_name=!parent!"
	goto _select_path
)
if "!INPUT2:~0,1!"=="." (
	set "%~1=!path_name!"
	call :savesettings "%~1"
	chcp !str_codepage!>nul
	goto:eof
)
if "!INPUT2:~0,1!"=="+" (
	set INPUT3=
	if "!INPUT2!"=="+" (
		SET /P INPUT3=[*] Create folder ^(input name^): 
		if defined INPUT3 (
			adb shell mkdir \"!path_name!!INPUT3!\"
		)
	) else (
		SET /P INPUT3=[*] Create folder: "!INPUT2:~1%!" ^(1-!str_ON!^) 
		if "!INPUT3!"=="1" (
			adb shell mkdir \"!path_name!!INPUT2:~1%!\"
		)
	)
	goto _select_path
)
if "!INPUT2:~0,1!"=="-" (
	if "!INPUT2!"=="-" set INPUT2=-1
	FOR %%F IN (!INPUT2:~1!) DO (
		if %%~F GEQ 1 (
		if %%~F LEQ !count! (
			set "path_name2=!device%%~F!"
			if "!path_name2:~-1!"=="*" set "path_name2=!path_name2:~0,-1!"
			if "!path_name2:~-1!"=="@" set "path_name2=!path_name2:~0,-1!"
			set INPUT3=
			SET /P INPUT3=[*] Delete "!path_name!!path_name2!": ^(1-!str_ON!^) 
			if "!INPUT3!"=="1" (
				adb shell rm -r \"!path_name!!path_name2!\"
				if "%%~F"=="1" (
					set "path_name=!parent!"
					goto _select_path
				)
			)
		)
		)
	)
	goto _select_path
)
if "!INPUT2!"=="*" chcp !str_codepage!>nul
if "!INPUT2:~0,1!"=="*" (
	set temp_name=
	if "!INPUT2:~0,2!"=="**" (
		for /f "delims=" %%d in ('Wfolder "set temp_name=" . "!str_pushto! !path_name!"') do %%d
	) else (
		for /f "delims=" %%d in ('FileToOpen "set temp_name=" ".\*.*" "!str_pushto! !path_name!" /multiselect') do %%d
		if %OS_version% GEQ 7600 chcp 65001>nul
	)
	if defined temp_name (
		FOR %%F IN (!temp_name!) DO (
			adb push "%%~F" "!path_name!"
		)
		pause
	)
	goto _select_path
)
if "!INPUT2:~0,1!"=="/" (
	if "!INPUT2!"=="/" set INPUT2=/1
	set temp_name=
	for /f "delims=" %%d in ('Wfolder "set temp_name=" . "!str_pullfrom! !path_name!"') do %%d
	if defined temp_name (
		FOR %%F IN (!INPUT2:~1!) DO (
			set "path_name2=!device%%~F!"
			if "!path_name2:~-1!"=="*" set "path_name2=!path_name2:~0,-1!"
			if "!path_name2:~-1!"=="@" set "path_name2=!path_name2:~0,-1!"
			if %%~F GEQ 1 (
			if %%~F LEQ !count! (
				adb pull -a "!path_name!!path_name2!" !temp_name!
			)
			)
		)
		pause
	)
	goto _select_path
)
if "!INPUT2:~0,1!"=="?" (
	set INPUT3=
	if "!INPUT2!"=="?" (
		SET /P INPUT3=[*] Rename "!path_name!" ^(input name^): 
		if defined INPUT3 (
			adb shell mv \"!path_name!\" \"!parent!!INPUT3!\"
			set "path_name=!parent!!INPUT3!"
		)
	) else (
		if !INPUT2:~1! GEQ 1 (
		if !INPUT2:~1! LEQ !count! (
			set "path_name2=!device%INPUT2:~1%!"
			if "!path_name2:~-1!"=="*" set "path_name2=!path_name2:~0,-1!"
			if "!path_name2:~-1!"=="@" set "path_name2=!path_name2:~0,-1!"
			SET /P INPUT3=[*] Rename "!path_name!!path_name2!" ^(input name^): 
			if defined INPUT3 (
				adb shell mv \"!path_name!!path_name2!\" \"!path_name!!INPUT3!\"
			)
		)
		)
	)
	goto _select_path
)
set dragndrop=
if "!INPUT2:~1,2!"==":\" set dragndrop=1
if "!INPUT2:~2,2!"==":\" set dragndrop=1
if "!INPUT2:~0,2!"=="\\" set dragndrop=1
if "!INPUT2:~1,2!"=="\\" set dragndrop=1
if defined dragndrop (
	if exist !INPUT2! (
		set INPUT3=
		SET /P INPUT3=[*] !str_pullfrom! !INPUT2! to "!path_name!": ^(1-!str_ON!^) 
		if "!INPUT3!"=="1" (
			adb push !INPUT2! "!path_name!"
			pause
		)
	)
)
if !INPUT2! GTR !count! (goto _select_path)
if !INPUT2! LSS 1 (goto _select_path)
set "path_name2=!device%INPUT2%!"
if "!path_name2:~-1!"=="*" set "path_name2=!path_name2:~0,-1!"
if "!path_name2:~-1!"=="@" set "path_name2=!path_name2:~0,-1!"
if "!path_name2:~-1!"=="/" (
	set "path_name=!path_name!!path_name2!"
) else (
	if "%~1"=="pull_folder" (
		set "pull_folder=!path_name!!path_name2!"
		call :savesettings "pull_folder"
		chcp !str_codepage!>nul
		goto:eof
	)
)
goto _select_path
:adbscreenshot
adb shell screencap -p /data/local/tmp/screenshot.png
nircmd wait 1000
adb pull /data/local/tmp/screenshot.png
if exist screenshot.png (
	adb shell rm /data/local/tmp/screenshot.png
	call :get_date_time
	ren "screenshot.png" "screenshot_!DATE2!_!TIME2!.png" >nul
	echo [*] !str_screensavedto! "screenshot_!DATE2!_!TIME2!.png"
) else (
	cecho {!colR!}!str_error!{# #}{\n}
)
pause
goto restart
:screenrecord
echo n|start /wait cmd /c "mode 80,25& echo [*] !str_closetostop!& adb shell screenrecord --verbose /sdcard/screenrecord.mp4"
nircmd wait 3000
adb pull /sdcard/screenrecord.mp4
if exist screenrecord.mp4 (
	adb shell rm /sdcard/screenrecord.mp4
	call :get_date_time
	ren "screenrecord.mp4" "screenrecord_!DATE2!_!TIME2!.mp4" >nul
	echo [*] !str_scrrecsavedto! "screenrecord_!DATE2!_!TIME2!.mp4"
) else (
	cecho {!colR!}!str_error!{# #}{\n}
)
pause
goto restart
:adbshell
start cmd /c "mode 120,499& adb shell"
goto restart
:adblogs
cecho {!colG!}  Logcat:{# #} !str_toscreen!{\n}
echo    1 = Logcat
echo    2 = Logcat (!str_logcatr!)
echo    3 = Logcat (!str_logcate!)
echo    4 = Logcat (now)
echo    5 = Log priority: !logcat_level!
cecho {!colG!}  !str_bugreport!{# #}{\n}
echo    6 = !str_tofile!
echo.
echo    0 = !str_cancel!
:_adblogs
set INPUT=
SET /P INPUT=!str_makechoice! 
:_adblogs_quick
IF !INPUT!==1 (set opt1=& set opt2=& goto adblogcat)
IF !INPUT!==2 (set opt1=-b radio& set opt2=_radio& goto adblogcat)
IF !INPUT!==3 (set opt1=-b events& set opt2=_events& goto adblogcat)
IF !INPUT!==4 (set opt1=-T 1& set opt2=_now& goto adblogcat)
IF !INPUT!==5 (goto set_logcat_level)
IF !INPUT!==6 (goto adbbug)
IF !INPUT!==0 (goto restart)
goto _adblogs
:adblogcat
adb get-state >nul
if not "!errorlevel!"=="0" (
	pause
	goto restart
)
call :get_date_time
call :_adblogcat
pause
goto restart
:_adblogcat
::ANDROID_LOG_TAGS = *:V, *:D, *:I, *:W, *:E, *:F, *:S
start cmd /c "mode 120,999& adb logcat -v time !opt1! *:!logcat_level:~0,1! | python "%bindir%tools\coloredlogcat\logcat_filter.py" -o "logcat!opt2!_!DATE2!_!TIME2!.txt""
echo !str_saved_to_file! "logcat!opt2!_!DATE2!_!TIME2!.txt"
goto:eof
:adbbug
adb get-state >nul
if not "!errorlevel!"=="0" (
	pause
	goto restart
)
call :get_date_time
adb bugreport >"bugreport_!DATE2!_!TIME2!.txt"
sfk rep "bugreport_!DATE2!_!TIME2!.txt" -binary /0D0D/0D/ -quiet -yes >nul
echo !str_saved_to_file! "bugreport_!DATE2!_!TIME2!.txt"
pause
goto restart
:set_logcat_level
cecho    1 = {09}Verbose{# #}{\n}   2 = {0B}Debug{# #}{\n}   3 = {0A}Info{# #}{\n}   4 = {0E}Warn{# #}{\n}   5 = {0C}Error{# #}{\n}   6 = {04}Fatal{# #}{\n}   7 = Silent{\n}
:_logcat_level
set INPUT=
set /P INPUT=!str_makechoice! 
if !INPUT! GTR 7 (goto _logcat_level)
if !INPUT! LSS 1 (goto _logcat_level)
if !INPUT!==1 set logcat_level=Verbose
if !INPUT!==2 set logcat_level=Debug
if !INPUT!==3 set logcat_level=Info
if !INPUT!==4 set logcat_level=Warn
if !INPUT!==5 set logcat_level=Error
if !INPUT!==6 set logcat_level=Fatal
if !INPUT!==7 set logcat_level=Silent
call :savesettings "logcat_level"
goto restart
:adbinfo
adb get-state >nul
if not "!errorlevel!"=="0" (
	pause
	goto restart
)
set dev_gsmop=
set dev_gsmsop=
set dev_fp=
set dev_rel=
set dev_sdk=0
set dev_spb=
set dev_brand=
set dev_abi=
set dev_abilist=
set dev_mf=
set dev_mn=
set dev_model=
set dev_sn=
set dev_socmf=
set dev_socmodel=
FOR /f "tokens=1,3 delims=[]" %%a IN ('adb shell getprop ^| nhrt -set:\r -e -notitle') DO (
	if /I "%%~a"=="gsm.operator.alpha" set "dev_gsmop=%%~b"
	if /I "%%~a"=="gsm.sim.operator.alpha" set "dev_gsmsop=%%~b"
	if /I "%%~a"=="ro.build.fingerprint" set "dev_fp=%%~b"
	if /I "%%~a"=="ro.build.version.release" set "dev_rel=%%~b"
	if /I "%%~a"=="ro.build.version.sdk" set "dev_sdk=%%~b"
	if /I "%%~a"=="ro.build.version.security_patch" set "dev_spb=%%~b"
	if /I "%%~a"=="ro.product.brand" set "dev_brand=%%~b"
	if /I "%%~a"=="ro.product.cpu.abi" set "dev_abi=%%~b"
	if /I "%%~a"=="ro.product.cpu.abilist" set "dev_abilist=%%~b"
	if /I "%%~a"=="ro.product.manufacturer" set "dev_mf=%%~b"
	if /I "%%~a"=="ro.product.marketname" set "dev_mn=%%~b"
	if /I "%%~a"=="ro.product.model" set "dev_model=%%~b"
	if /I "%%~a"=="ro.serialno" set "dev_sn=%%~b"
	if /I "%%~a"=="ro.soc.manufacturer" set "dev_socmf=%%~b"
	if /I "%%~a"=="ro.soc.model" set "dev_socmodel=%%~b"
)
set dev_ramtotal=
FOR /f "tokens=1,2 delims=: " %%a IN ('adb shell cat /proc/meminfo ^| nhrt -set:\r -e -notitle') DO (
	if /I "%%~a"=="MemTotal" set "dev_ramtotal=%%~b"
)
set dev_romsize=
set dev_romused=
set dev_romfree=
FOR /f "delims=" %%a IN ('adb shell df -h /data ^| nhrt -set:\r -e -notitle') DO (
	set x=%%a
	if not "!x!"=="!x:/data=!" (
		FOR /f "tokens=2,3,4 delims= " %%b IN ("!x!") DO (
			set "dev_romsize=%%~b"
			set "dev_romused=%%~c"
			set "dev_romfree=%%~d"
		)
	)
)
set dev_btlvl=
set dev_btsc=100
set dev_bttemp=
FOR /f "tokens=1,2 delims=: " %%a IN ('adb shell dumpsys battery ^| nhrt -set:\r -e -notitle') DO (
	if /I "%%~a"=="level" set "dev_btlvl=%%~b"
	if /I "%%~a"=="scale" set "dev_btsc=%%~b"
	if /I "%%~a"=="temperature" set "dev_bttemp=%%~b"
)
if defined dev_mf cecho   {06}Manufacturer{# #}          : !dev_mf!{\n}
if defined dev_mn cecho   {06}Name{# #}                  : !dev_mn!{\n}
if defined dev_brand (
	if not "!dev_brand!"=="!dev_mf!" cecho   {06}Brand{# #}                 : !dev_brand!{\n}
)
if defined dev_model (
	if not "!dev_model!"=="!dev_mf!" cecho   {06}Model{# #}                 : !dev_model!{\n}
)
if defined dev_rel cecho   {06}Android{# #}               : !dev_rel! ^(SDK !dev_sdk!^){\n}
if defined dev_romsize cecho   {06}ROM ^(/data^){# #}           : !dev_romsize! ^(!dev_romfree! free^){\n}
if defined dev_ramtotal (
	set /a "dev_ram1=dev_ramtotal / 1048576"
	set /a "dev_ram2=dev_ramtotal %% 1048576"
	cecho   {06}RAM{# #}                   : !dev_ram1!.!dev_ram2:~0,3! GB{\n}
)
if defined dev_socmf cecho   {06}SoC manufacturer{# #}      : !dev_socmf!{\n}
if defined dev_socmodel cecho   {06}SoC model{# #}             : !dev_socmodel!{\n}
if defined dev_abilist (
	cecho   {06}Arch{# #}                  : !dev_abilist!{\n}
) else (
	if defined dev_abi cecho   {06}Arch{# #}                  : !dev_abi!{\n}
)
if defined dev_btlvl (
	set /a "dev_btlvl=dev_btlvl * 100 / dev_btsc"
	cecho   {06}Battery level{# #}         : !dev_btlvl! %%{\n}
)
if defined dev_bttemp cecho   {06}Battery temperature{# #}   : !dev_bttemp:~0,-1!.!dev_bttemp:~-1! °C{\n}
if defined dev_gsmsop (
	cecho   {06}SIM Operator{# #}          : !dev_gsmsop!{\n}
) else (
	if defined dev_gsmop cecho   {06}GSM Operator{# #}          : !dev_gsmop!{\n}
)
if defined dev_sn cecho   {06}SerialNO{# #}              : !dev_sn!{\n}
if defined dev_spb cecho   {06}Security patch{# #}        : !dev_spb!{\n}
if defined dev_fp cecho   {06}Build fingerprint{# #}     : !dev_fp!{\n}
echo.
::start cmd /c "mode 81,26& adb shell top"
echo   1 = Start htop
echo   0 = !str_cancel!
:_adbinfo
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (
	if "!dev_abi!"=="!dev_abi:arm64=!" (set "htop_binary=htop-arm32") else (set "htop_binary=htop-arm64")
	for /f "tokens=4,5 delims= " %%a in ('adb shell ls -l /data/local/tmp/!htop_binary! 2^>nul') DO (
		if "%%a"=="shell" (set "htop_binary_size=%%b") else (set "htop_binary_size=%%a")
	)
	if not "!htop_binary_size!"=="860992" (
	if not "!htop_binary_size!"=="620316" (
		adb push "%bindir%tools\!htop_binary!" "/data/local/tmp/"
		adb shell chmod 755 /data/local/tmp/!htop_binary!
	)
	)
	start cmd /c "mode 105,40& adb shell -t /data/local/tmp/!htop_binary!"
)
IF !INPUT!==0 (goto restart)
goto _adbinfo
:adbreboot
cecho {!colG!}  !str_reboot2!{# #}{\n}
echo    1 = !str_reboot3!
echo    2 = !str_rebootto! recovery
echo    3 = !str_rebootto! bootloader
echo.
echo    0 = !str_cancel!
:_adbreboot
set INPUT=
SET /P INPUT=!str_makechoice! 
:_adbreboot_quick
IF !INPUT!==1 (goto rebootnormal)
IF !INPUT!==2 (goto rebootrecovery)
IF !INPUT!==3 (goto rebootbootloader)
IF !INPUT!==0 (goto restart)
goto _adbreboot
:rebootrecovery
echo !str_rebootto! recovery...
adb reboot recovery
goto restart
:rebootbootloader
echo !str_rebootto! bootloader...
adb reboot bootloader
goto restart
:rebootnormal
echo !str_reboot3!...
adb reboot
goto restart
:adbexit
set ANDROID_SERIAL=
set scrcpy_serial=N
set adb_mode=off
adb kill-server
cecho {!colG!}!str_done!{# #}{\n}
pause
goto restart
:about
cls
COLOR 07
call :empty_line 21
cecho               {0A}####{#}    #   ##### #   # #   #        {0A}#{#}   ##### #   # {0A}#####{#}  ###   ###  #####{\n}
cecho                {09}#{#}     # #    #   #   #  # #        {09}# #{#}  #   # #  #    {09}#{#}   #   # #   #  #  #{\n}
cecho                {0E}####{#} #####   #    ####   #        {0E}#####{#} #   # ###     {0E}#{#}   #   # #   #  #  #{\n}
cecho                {0B}#  #{#} #   #   #       #  # #       {0B}#   #{#} #   # #  #    {0B}#{#}   #   # #   #  #  #{\n}
cecho               {0D}#####{#} #   #   #       # #   #      {0D}#   #{#} #   # #   #   {0D}#{#}    ###   ###  #   #{\n}
call :empty_line 21
start nircmd speak text "Batch ApkTool"
pause
COLOR %colB%
goto restart
:empty_line
FOR /L %%a IN (1,1,%~1) DO echo.
goto:eof
