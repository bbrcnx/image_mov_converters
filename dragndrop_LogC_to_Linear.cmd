@echo off
::2017_06_23 V001 王晓伟
::这个脚本通过拖拽序列帧所在文件夹到这个脚本上，通过nuke将alexaLogC序列帧转成Linear Exr序列帧。
::脚本必须是utf-8编码，否则nuke内slate和overlay的中文会出问题
::斜杠和反斜杠非常重要，直接对windows的操作是反斜杠，给nuke的要正斜杠，尽量分清楚否则会出现各种不可预料的错误。

setlocal EnableDelayedExpansion


set nuke_path="C:/Program Files/Nuke10.5v2/nuke10.5.exe"  
set nuke_script="C:/project/util_dragndrop_LogC_to_Linear/util_dragndrop_LogC_to_Linear_v002.nk"


::获取拖拽到脚本上的包含路径的完整文件名
set input_dir=%~f1
set input_up_folder=%~dp1

::把反斜杠换成正斜杠

::set "input_up_folder=%input_up_folder:\=/%"

set output_folder=%input_up_folder%exr
if not exist %output_folder% ( md %output_folder% )


::获取路径内按名字排序的第一个文件名
for /f "usebackq" %%a in (`dir /O:N /A:-H /B "%input_dir%"`) do (
set input_filename=%%a
goto out1
)
:out1

set input_full_path=%input_dir%/%input_filename%


::以"."为分界将文件名分开，把第一个和第二个给变量name 和frame。
::后续需要识别如果没有序列帧的情况。
for /f "usebackq tokens=1,2 delims=." %%b in ('%input_filename%') do (@set clean_name=%%b& @set start_frame=%%c)


::以"."为分界把文件名分开取第三段的扩展名。
::这个方法很笨，如果文件只有两部分就会出错。
for /f "usebackq tokens=3 delims=." %%e in ('%input_filename%') do (set ext=%%e)


::生成nuke需要的序列帧文件名
set ff_filename=%clean_name%.%%d.exr
set ff_input_fullpath=%input_dir%/%clean_name%.%%d.%ext%
set out_temp_folder=%TEMP%\qqq_i_will_disappear_ppp\exr

if not exist %out_temp_folder% ( md %out_temp_folder% )

set "out_temp_folder=%out_temp_folder:\=/%"
set out_temp_path=%out_temp_folder%/%clean_name%
set out_temp_path_ext=%out_temp_folder%/%ff_filename%
set ff_full_out_path=%output_folder%


::计算文件夹内一共有多少帧 /a-d-s-h 使隐藏文件和系统文件不被算在内。
for /f %%A in ('dir %input_dir% /a-d-s-h /b ^| find /v /c ""') do set cnt=%%A

set /a "end_frame=%start_frame%+%cnt%-1"


::获取当前时间
For /f "tokens=1-3 delims=/ " %%a in ('date /t') do (set mydate=%%a/%%b/%%c)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)
set "render_time="%mydate%  %mytime%""

echo output_folder=%output_folder%

%nuke_path%  -t -xi %nuke_script% %ff_input_fullpath% %out_temp_path_ext% %start_frame%-%end_frame%

set "out_temp_path_ext=%out_temp_path_ext:/=\%"
set "out_temp_folder=%out_temp_folder:/=\%"

copy /Y %out_temp_folder% %output_folder%

%SystemRoot%\explorer.exe %output_folder%

if exist %out_temp_folder% ( rmdir /S /Q %out_temp_folder% )

:end
pause
