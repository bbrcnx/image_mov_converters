@echo off
:: 2017_10_03 V1.0 王晓伟
:: 基于本地版本C:\project\dragndrop_convert_mov\ffmpeg_batch\convert_images_to_mov_v012_good_ffmpeg.cmd
:: 这个脚本通过拖拽将其他格式的mov转成H264的mov。
:: 通过ffmpeg转换的mov与nuke内转换的mov颜色会有细微差异，暂时不知道怎么解决，对颜色要求不高的镜头可以用这个转。
:: Todo:


setlocal EnableDelayedExpansion

::quality 数字越小，质量越高
set quality=8 

::这里没有指定输入的帧率
::set input_fps=24
::set output_fps=24
::set ff_filter="fps=24"
set ffmpeg_path="\\work\app_config\release\ffmpeg\bin\ffmpeg.exe" 

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 根据拖拽的文件夹得到ffmpeg需要的输入和输出文件路径


:: 获取拖拽到脚本上的包含路径的完整文件名
set input_file=%~f1
set input_file_noExt=%~dpn1
set input_folder=%~dp1
set time=%time::=%
set output_file=%input_file_noExt%_%time%.mov


echo input_file:%input_file%
echo input_file_noExt:%input_file_noExt%
echo input_folder:%input_folder%
echo time:%time%
echo output_file:%output_file%


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 开始转码并打开输出的文件夹

%ffmpeg_path%  -i %input_file% -c:v libx264 -crf %quality%  -bf 0 -g 1 -pix_fmt yuv420p  %output_file% && %SystemRoot%\explorer.exe %input_folder%

::转其他帧率的时候用下面的命令。
::%ffmpeg_path%  -i %input_file% -c:v libx264 -crf %quality%  -bf 0 -g 1 -pix_fmt yuv420p  -vf %ff_filter% %output_file% && %SystemRoot%\explorer.exe %input_folder%

:end
pause