:: ColorPicker v1.1
:: Автор: bursoft
:: Плагин позволяет настроить цвета основных элементов интерфейса Batch ApkTool
if "%bat_version%"=="" goto:eof

bg cursor 0
set colB0=%colB:~0,1%
set colB1=%colB:~1,1%
set colR1=%colR:~1,1%
set colG1=%colG:~1,1%
set trans_value_temp=%trans_value%
set /A trans_set=-(%trans_value_temp% - 255) / 3
set "color_selector={00}    {10}    {20}    {30}    {40}    {50}    {60}    {70}    {80}    {90}    {A0}    {B0}    {C0}    {D0}    {E0}    {F0}    "
cls

:begin
bg locate 0 0
set trans=
FOR /L %%a IN (0,1,63) DO (
	if %%a==!trans_set! (set "trans=!trans!{%colB1%%colB1%} {%colB0%%colB1%}") else (set "trans=!trans!-")
)
cecho {%colB0%%colG1%}{\n}%bat_title%{%colB0%%colB1%}{\n}%bat_page%{\n}%bat_line%{\n}{\n}%str_title%{\n}{\n}  %str_sampleB1% ^| %color_selector%{%colB0%%colB1%} ^|{\n}                                   ^| %color_selector%{%colB0%%colB1%} ^|{\n}{\n}  {%colB0%%colR1%}%str_sampleR1%{%colB0%%colB1%} ^| %color_selector%{%colB0%%colB1%} ^|{\n}                                   ^| %color_selector%{%colB0%%colB1%} ^|{\n}{\n}  {%colB0%%colG1%}%str_sampleG1%{%colB0%%colB1%} ^| %color_selector%{%colB0%%colB1%} ^|{\n}                                   ^| %color_selector%{%colB0%%colB1%} ^|{\n}{\n}  %str_sampleB0% ^| %color_selector%{%colB0%%colB1%} ^|{\n}                                   ^| %color_selector%{%colB0%%colB1%} ^|{\n}{\n}  %str_transXXX% ^| %trans% ^|{\n}{\n}{\n}                   {F0}       OK       {%colB0%%colB1%}         {F0}%str_buttonD%{%colB0%%colB1%}         {F0}%str_buttonC%{%colB0%%colB1%}

:read
bg mouse >nul 2>nul
set /A "mouseRow=%ErrorLevel% >> 0x10 , mouseCol=%ErrorLevel% & 0xFFFF"
::bg print "%mouseRow%-%mouseCol% "

If %mouseRow%==19 (
	if %mouseCol% GEQ 37 (if %mouseCol% LEQ 100 (
		set /A trans_set=%mouseCol% - 37
		set /A trans_value_temp=255 - 3 * !trans_set!
		nircmd win trans ititle "BAT by BurSoft" !trans_value_temp!
		goto begin
	))
)

If %mouseRow%==22 (
	if %mouseCol% GEQ 19 (if %mouseCol% LEQ 34 (
		set colB=%colB0%%colB1%
		set colG=%colB0%%colG1%
		set colR=%colB0%%colR1%
		set trans_value=%trans_value_temp%
		if not exist "%bindir%settings.ini" type nul >"%bindir%settings.ini"
		inifile "%bindir%settings.ini" [global_settings] "colB=!colB!"
		inifile "%bindir%settings.ini" [global_settings] "colG=!colG!"
		inifile "%bindir%settings.ini" [global_settings] "colR=!colR!"
		inifile "%bindir%settings.ini" [global_settings] "trans_value=!trans_value!"
		bg cursor 1
		goto:eof
	))
	if %mouseCol% GEQ 44 (if %mouseCol% LEQ 59 (
		if %colB0%%colB1%%colR1%%colG1%%trans_set%==07CA0 (goto read)
		set colB0=0
		set colB1=7
		set colR1=C
		set colG1=A
		COLOR !colB0!!colB1!
		set trans_set=0
		set trans_value_temp=255
		nircmd win trans ititle "BAT by BurSoft" !trans_value_temp!
		goto begin
	))
	if %mouseCol% GEQ 69 (if %mouseCol% LEQ 84 (
		nircmd win trans ititle "BAT by BurSoft" !trans_value!
		bg cursor 1
		goto:eof
	))
)

if %mouseRow% GEQ 7 (if %mouseRow% LEQ 8 (
	set _code=B1
	goto select_color
))
if %mouseRow% GEQ 10 (if %mouseRow% LEQ 11 (
	set _code=R1
	goto select_color
))
if %mouseRow% GEQ 13 (if %mouseRow% LEQ 14 (
	set _code=G1
	goto select_color
))
if %mouseRow% GEQ 16 (if %mouseRow% LEQ 17 (
	set _code=B0
	goto select_color
))
goto :read

:select_color
if %mouseCol% GEQ 37 (if %mouseCol% LEQ 40 (
	set _color=0
	goto set_color
))
if %mouseCol% GEQ 41 (if %mouseCol% LEQ 44 (
	set _color=1
	goto set_color
))
if %mouseCol% GEQ 45 (if %mouseCol% LEQ 48 (
	set _color=2
	goto set_color
))
if %mouseCol% GEQ 49 (if %mouseCol% LEQ 52 (
	set _color=3
	goto set_color
))
if %mouseCol% GEQ 53 (if %mouseCol% LEQ 56 (
	set _color=4
	goto set_color
))
if %mouseCol% GEQ 57 (if %mouseCol% LEQ 60 (
	set _color=5
	goto set_color
))
if %mouseCol% GEQ 61 (if %mouseCol% LEQ 64 (
	set _color=6
	goto set_color
))
if %mouseCol% GEQ 65 (if %mouseCol% LEQ 68 (
	set _color=7
	goto set_color
))
if %mouseCol% GEQ 69 (if %mouseCol% LEQ 72 (
	set _color=8
	goto set_color
))
if %mouseCol% GEQ 73 (if %mouseCol% LEQ 76 (
	set _color=9
	goto set_color
))
if %mouseCol% GEQ 77 (if %mouseCol% LEQ 80 (
	set _color=A
	goto set_color
))
if %mouseCol% GEQ 81 (if %mouseCol% LEQ 84 (
	set _color=B
	goto set_color
))
if %mouseCol% GEQ 85 (if %mouseCol% LEQ 88 (
	set _color=C
	goto set_color
))
if %mouseCol% GEQ 89 (if %mouseCol% LEQ 92 (
	set _color=D
	goto set_color
))
if %mouseCol% GEQ 93 (if %mouseCol% LEQ 96 (
	set _color=E
	goto set_color
))
if %mouseCol% GEQ 97 (if %mouseCol% LEQ 100 (
	set _color=F
	goto set_color
))
goto :read

:set_color
if %_code%==B0 (if %_color%==%colB1% (goto read))
if %_code%==B1 (if %_color%==%colB0% (goto read))
if !col%_code%!==%_color% (goto read)
set col%_code%=%_color%
if %_code%==B0 (COLOR %colB0%%colB1%)
goto begin
