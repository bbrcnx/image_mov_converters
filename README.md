

2017 10 03

any_to_H264_mov_v001.cmd

将任意video文件拖拽到这个脚本上通过ffmpeg生成h264 mov文件。
但是颜色与nuke生成的mov会有少许差别，对颜色要求不高的镜头可以用这个脚本快速转换。


----

2017 06 23

dragndrop_LogC_to_Linear.cmd

通过拖拽将logc dpx序列帧文件转成 linear exr文件。


----
2017 06 10

nuke_convert_mov.cmd

目前主要是用nuke的方法，通过拖拽dpx序列帧到脚本上，生成带LUT的mov。

----
2017 06 10

ffmpeg_convert_mov.cmd

拖拽dpx序列帧到脚本上，通过ffmpeg生成带LUT的mov。因为转完的颜色与nuke生成的有微小差别所以没用这个。在对颜色要求不是特别高的情况下，可以稍加改动可以作为序列帧转mov的通用工具。
