@echo off
:: 2017_05_19 V0.1 王晓伟
:: 这个脚本通过拖拽序列帧所在文件夹将里面的序列帧转成mov。
:: Todo:
:: 自动识别拖拽的是文件夹或文件。并执行相应的操作。
:: 如果文件夹内无文件，能自动提醒。
:: 如果文件名没有序列帧号能够提醒。
:: 输出的高必须是偶数，奇数无法输出的问题
:: 自动覆盖mov
:: 加写common的地方

setlocal EnableDelayedExpansion

set out_width=1920
set out_height=1080
set quality=10
set mask_ratio=2.35
set mask_opacity=1
set mask_color=black
set lut=lut3d='s\:/generic_elements/lut/AlexaV3_K1S1_LogC2Video_Rec709_EE_nuke3d.cube',
set input_fps=24
set output_fps=24
set pad_color=black

:: 遮幅，slate，LUT的开关
set slate_on=1
set lut_on=1
set mask_on=1

:: Slate设置
set project=肇事者
set company=长空一画
set font=C\\:/Windows/Fonts/simhei.ttf
set font_color=white
set font_opacity=0.8
set shot_font_size=36
set other_font_size=26
set left=50
set right=50
set top=90
set shot_top=30
set bottom=90

:: RV程序路径
set rvio_path="c:/Program Files/Tweak/RV-4.0.10-64/bin/rvio_hw.exe" 
set rvls_path="c:/Program Files/Tweak/RV-4.0.10-64/bin/rvls.exe"


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 根据拖拽的文件夹得到RV需要的输入和输出文件路径


:: 获取拖拽到脚本上的包含路径的完整文件名
set input_dir=%~f1
set input_up_folder=%~dp1
set output_folder=%input_up_folder%mov\
if not exist %output_folder% ( md %output_folder% )
::goto :end

echo input_dir:%input_dir%
echo input_up_folder:%input_up_folder%
echo output_folder:%output_folder%

:: 获取路径内按名字排序的第一个文件名
for /f "usebackq" %%a in (`dir /O:N /A:-H /B "%input_dir%"`) do (
set fullfilename=%%a
goto out1
)
:out1
echo fullfilename:%fullfilename%

set fp_file_name=%input_dir%\%fullfilename%
echo fp_file_name: %fp_file_name%

:: 以"."为分界将文件名分开，把第一个和第二个给变量name 和frame。
:: 后续需要识别如果没有序列帧的情况。
for /f "usebackq tokens=1,2 delims=." %%b in ('%fullfilename%') do (@set clean_name=%%b& @set start_frame=%%c)
echo start_frame: %start_frame%

:: 以"."为分界把文件名分开取第三段的扩展名。
:: 这个方法很笨，如果文件只有两部分就会出错。
for /f "usebackq tokens=3 delims=." %%e in ('%fullfilename%') do (set ext=%%e)

:: 生成ffmpeg需要的序列帧文件名
set ff_filename=%clean_name%.#.%ext%
set ff_fullpath=%input_dir%\%clean_name%.#.%ext%
set ff_full_out_path=%output_folder%%clean_name%.mov
echo ff_fullpath: %ff_fullpath%
echo ff_full_out_path:%ff_full_out_path%

%rvio_path% %ff_fullpath% -v -o %ff_full_out_path%  -outres %out_width% %out_height%
pause
