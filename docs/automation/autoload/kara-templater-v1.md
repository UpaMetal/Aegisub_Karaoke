# [kara-templater-v1.lua](../../../automation/autoload/kara-templater-v1.lua)
**kara-templater-v1.lua**更改了Aegisub自带的逐行处理karaskel.preproc_line()与apply_line()逻辑为滑动窗口式处理，即处理当前行时，只保留有当前行的上一行与下一行      
增添了两个新的aegisub变量，它们不能进行类似`line.prev.prev`的链式调用  
`line.prev`  - 当前行的物理结构的上一行(仅真正含有歌词字幕的dialogue行)，如果没有则为`nil`  
`line.next`  - 当前行的物理结构的上一行(仅真正含有歌词字幕的dialogue行)，如果没有则为`nil`  