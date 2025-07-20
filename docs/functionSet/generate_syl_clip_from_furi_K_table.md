# [generate_syl_clip_from_furi_K_table.lua](../../functionSet/generate_syl_clip_from_furi_K_table.lua)  
- 根据syl的注音假名表生成分段的syl裁剪区,可实现分段匀速走字效果,输入为想要裁剪区域的左上角坐标,右下角坐标(y值若输入为nil则分别默认为0与视频分辨率y(比如1920*1080,则取1080)),时间偏移参数，通常为相较于line.start_timen的偏移
- 最后的输入为附加特效标签信息\t标签内与\t外附加特效标签信息,它必须是一个表,表中可以写入给每个分段之间添加的信息,例如syl有三个假名注音,那么你可以添加3个附加信息(多余的信息会被忽略),必须符合aegisub规范,除非你知道自己在做什么,否则请保持此项为nil
- 这里给出一个syl的左边缘和右边缘计算公式，但是可能会有误差，因此如果发现边框不能全部覆盖字可适当调整几个像素
- 通常情况下 syl_visual_left = line.left + syl.left - bord * (scale_x / 100) - math.max(0, -shadx) 
- 通常情况下 syl_visual_right = line.left + syl.right - (spacing - bord) * (scale_x / 100) + math.max(0, shadx)
- 函数使用了Yutils.math.round, 如果你没有那么请自己构造一个保留三位小数的函数自行替换吧