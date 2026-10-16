if "%bat_version%"=="" goto:eof
cls
echo.
cecho {!colG!}!bat_title!{# #}{\n}
echo !bat_page!
echo !bat_line!
echo.
cecho {!colG!}!str_plugin_name!{# #}{\n}
echo.
echo   1 - !str_menu_build!
echo   2 - !str_menu_build_smali!
echo   0 - !str_cancel!
echo.
:_make_choice
set INPUT=
SET /P INPUT=!str_makechoice! 
IF !INPUT!==1 (goto build_apktool)
IF !INPUT!==2 (goto build_smali)
IF !INPUT!==0 (goto:eof)
goto _make_choice
:build_apktool
cd /d "!rootdir!"
curl https://codeload.github.com/iBotPeaches/Apktool/zip/refs/heads/main -k -o Apktool.zip
if errorlevel 1 (
	cecho {!colR!}[*] !str_error_download!{# #}{\n}
	goto work_end
)

rd /s /q "Apktool-main" 2>nul
7z x -tzip "Apktool.zip" -aoa -sccWIN >nul
if not exist "Apktool-main" (
	cecho {!colR!}[*] !str_error_unzip!{# #}{\n}
	goto work_end
)

FOR /f "tokens=1 delims= " %%a IN ('sfk filetime -flat -noname "Apktool-main\gradlew.bat" 2^>nul') DO set FileDate=%%~a
nhrt -spt:"${version}" -t:"${version}-!FileDate!" "Apktool-main\brut.apktool\apktool-lib\src\main\resources\properties\apktool.properties" >nul

cd "Apktool-main"
call gradlew.bat build shadowJar proguard
cd /d "!rootdir!"

set apktool_count=0
FOR %%F IN ("Apktool-main\brut.apktool\apktool-cli\build\libs\apktool*.*.jar") DO (
	set /A apktool_count+=1
	set FileName=%%~nF
	set FileName=!FileName:-=_!
	set FileName=!FileName:_dirty=!
	COPY "%%~F" "bin\!FileName!_!FileDate!.jar" >nul
	cecho {!colG!}[*] !str_build_done1!{# #} !FileName!_!FileDate!.jar !str_build_done2!{\n}
)
if !apktool_count!==0 (
	cecho {!colR!}[*] !str_error_build!{# #}{\n}
)
goto work_end

:build_smali
cd /d "!rootdir!"
curl https://codeload.github.com/google/smali/zip/refs/heads/main -k -o smali.zip
if errorlevel 1 (
	cecho {!colR!}[*] !str_error_download!{# #}{\n}
	goto work_end
)

rd /s /q "smali-main" 2>nul
::7z x -tzip "smali.zip" -aoa -sccWIN >nul
sfk unzip "smali.zip" -force -yes >nul
if not exist "smali-main" (
	cecho {!colR!}[*] !str_error_unzip!{# #}{\n}
	goto work_end
)

::sfk list -hidden -quiet -quot -relnames -dir "smali-main\third_party" -sincedif "smali-main"
set symlink_count=0
for /f "delims=" %%a in ('sfk filter -quiet smali-main -hidden -head=1 -ls+../ 2^>nul') do (
	set "line_=%%~a"
	if "!line_:~-2!"==" :" (
		set /A symlink_count+=1
		set "symlink_file!symlink_count!=!line_:~0,-2!"
		set "symlink_temp=!line_:~0,-2!"
	) else (
		for /f "delims=" %%b in ('type "!symlink_temp!" ^| sfk filter -trim -rep "_../__" -rep "_/_\_" 2^>nul') do (
			set "real_file!symlink_count!=smali-main\%%~b"
		)
	)
)
FOR /L %%a IN (1,1,!symlink_count!) DO (
	COPY "!real_file%%a!" "!symlink_file%%a!" >nul
)

FOR /f "tokens=1 delims= " %%a IN ('sfk filetime -flat -noname "smali-main\gradlew.bat" 2^>nul') DO set FileDate=%%~a
nhrt -spt:"${version}" -t:"${version}-!FileDate!" "smali-main\smali\src\main\resources\smali.properties" >nul
nhrt -spt:"${version}" -t:"${version}-!FileDate!" "smali-main\baksmali\src\main\resources\baksmali.properties" >nul

cd "smali-main"
if !java_version! LEQ 16 (
	call gradlew.bat proguard
) else (
	call gradlew.bat smali:fatJar
	call gradlew.bat baksmali:fatJar
)
cd /d "!rootdir!"

set smali_count=0
FOR %%F IN ("smali-main\smali\build\libs\smali*fat*.jar" "smali-main\smali\build\libs\smali*small*.jar" "smali-main\baksmali\build\libs\baksmali*fat*.jar" "smali-main\baksmali\build\libs\baksmali*small*.jar") DO (
	set /A smali_count+=1
	set FileName=%%~nF
	set FileName=!FileName:-dev=!
	set FileName=!FileName:-small=!
	set FileName=!FileName:-fat=!
	COPY "%%~F" "bin\!FileName!_!FileDate!.jar" >nul
	cecho {!colG!}[*] !str_build_done1!{# #} !FileName!_!FileDate!.jar !str_build_done2!{\n}
)
if !smali_count!==0 (
	cecho {!colR!}[*] !str_error_build!{# #}{\n}
)

:work_end
del /f /q "Apktool.zip" "smali.zip" 2>nul
rd /s /q "Apktool-main" "smali-main" 2>nul
pause
