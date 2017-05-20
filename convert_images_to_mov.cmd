@echo off
:: 2017_05_20 V1.1 王晓伟
:: 这个脚本通过拖拽序列帧所在文件夹将里面的序列帧转成mov。
:: 这个脚本要使用ffmpeg和rv 4.0以上版本
:: 因为ffmpeg转dpx颜色会有变化，所以利用rvio将dpx转成exr，在用ffmpeg转exr为mov
:: rvio也有转换mov功能但是要加上slate的需求开发时间太长。等后续ffmpeg修正bug后就不需要rvio了。

:: Todo:
:: 自动识别拖拽的是文件夹或文件。并执行相应的操作。
:: 如果文件夹内无文件，能自动提醒。
:: 如果文件名没有序列帧号能够提醒。
:: 输出的高必须是偶数，奇数无法输出的问题
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
set rvio_out_format=exr

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
set rvio_path="\\work\app_config\release\rv\RV-4.0.10-64\bin\rvio_hw.exe" 

:: FFMPEG程序路径
set ffmpeg_path="\\work\app_config\release\ffmpeg\bin\ffmpeg.exe" 
set ffprobe_path="\\work\app_config\release\ffmpeg\bin\ffprobe.exe"


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 根据拖拽的文件夹得到ffmpeg需要的输入和输出文件路径


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

::生成RVIO需要的文件名
set rvio_input_path=%input_dir%\%clean_name%.#.%ext%
set rvio_out_folder=%TEMP%\qqq_i_will_disappear_ppp
if not exist %rvio_out_folder% ( md %rvio_out_folder% )
set rvio_out_path=%TEMP%\qqq_i_will_disappear_ppp\%clean_name%.#.%rvio_out_format%
echo rvio_input_path:%rvio_input_path%
echo rvio_out_path:%rvio_out_path%

:: 生成ffmpeg需要的序列帧文件名
set ff_filename=%clean_name%.%%d.%rvio_out_format%
set ff_fullpath=%rvio_out_folder%\%clean_name%.%%d.%rvio_out_format%
set ff_full_out_path=%output_folder%%clean_name%.mov
echo ff_fullpath: %ff_fullpath%
echo ff_full_out_path:%ff_full_out_path%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::因为ffmpeg转dpx颜色会有少许变化，但转exr不会，所以暂时用rvio转换exr序列再用ffmpeg转exr 为mov

%rvio_path% %rvio_input_path% -v -o %rvio_out_path%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 读取输入素材的图片宽和高。 
:: 中间用一个临时文件存储得到的宽高值，然后再读取进来赋值。batch无法直接将一个程序的输出值传给另一个程序。
%ffprobe_path%  -v error -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 %fp_file_name% > %TEMP%\M0vyyyeah.tmp
%ffprobe_path%  -v error -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 %fp_file_name% >> %TEMP%\M0vyyyeah.tmp

<%TEMP%\M0vyyyeah.tmp (
  set /p i_width=
  set /p i_height=
)

::删除临时文件
del /Q %TEMP%\M0vyyyeah.tmp

echo i_width:%i_width%
echo i_height:%i_height%

:: 比对输出格式与输入格式的画幅比大小，如果输出的宽高比大于输入的宽高比，则需要crop输入的画面，如小于或等于则需要pad输入的画面。
:: 因为batch不支持小数的运算所以分别将输入与输出height分别乘以对方的width比大小，如果输入比输出大就crop，如果小或等于则pad。

set /a in_height_b=%i_height%*%out_width%
set /a out_height_b=%out_height%*%i_width%
echo in_height_b:%in_height_b%
echo out_height_b:%out_height_b%

:: 设置是否启用mask，lut，slate
:: lut
if %lut_on% NEQ 1 (set lut=)
:: mask
if %mask_on% NEQ 1 (set mask=) else (set mask=drawbox=x=-t:y=0.5*^(ih-iw/%mask_ratio%^)-t:w=iw+t*2:h=iw/%mask_ratio%+t*2:t=0.5*^(ih-iw/%mask_ratio%^):c=%mask_color%@%mask_opacity%,)
:: slate
if %slate_on% NEQ 1 (set mask=) else (set slate=drawtext=fontfile=%font%: text=%clean_name%:x=w/2-tw/2:y=%shot_top%: fontsize=%shot_font_size%: fontcolor=%font_color%@%font_opacity%,drawtext=fontfile=%font%: text=%company%:x=w/2-tw/2:y=%top%: fontsize=%other_font_size%: fontcolor=%font_color%@%font_opacity%,drawtext=fontfile=%font%: text=%project%:x=%left%:y=%top%: fontsize=%other_font_size%: fontcolor=%font_color%@%font_opacity%, drawtext=fontfile=%font%: text=^'%%{localtime}^':x=w-tw-%right%:y=%top%: fontsize=%other_font_size%: fontcolor=%font_color%@%font_opacity%,drawtext=fontfile=%font%:start_number=%start_frame%:text=^'%%{n}^':x=w-tw-%right%:y=h-%bottom%: fontsize=%shot_font_size%: fontcolor=%font_color%@%font_opacity%,)

:: ffmpeg filter是按顺序进行的，这点对自动缩放影响很大，先pad再scale和先scale再pad的最后输出的尺寸是不一样的。在这里scale要放在前面。
if %in_height_b% EQU %out_height_b% (set ff_filter="scale=%out_width%:-2,%lut% %mask% %slate% fps=%output_fps%") && goto :out2
if %in_height_b% LSS %out_height_b% (set ff_filter="scale=%out_width%:-2,pad=x=0:y=(oh-ih)/2:w=0:h=%out_height%:color=%pad_color%,%lut% %mask% %slate% fps=%output_fps%") && goto :out2
if %in_height_b% GTR %out_height_b% (set ff_filter="scale=%out_width%:-2,crop=%out_width%:%out_height%,%lut% %mask% %slate% fps=%output_fps%") && goto :out2

:out2


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 开始转码并打开输出的文件夹

%ffmpeg_path% -y -framerate %input_fps% -start_number %start_frame% -i %ff_fullpath% -c:v libx264 -crf %quality%  -bf 0 -g 1 -pix_fmt yuv420p  -vf %ff_filter% %ff_full_out_path% && %SystemRoot%\explorer.exe %output_folder%

if exist %rvio_out_folder% ( rmdir /S /Q %rvio_out_folder% )
:end
pause
