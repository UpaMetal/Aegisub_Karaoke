# [kara-templater-V2.lua](../../../automation/autoload/kara-templater-V2.lua)  
**kara-templater-V2.lua**更改了Aegisub自带的逐行处理karaskel.preproc_line()与apply_line()逻辑为分块处理  
**因为是一次行处理所有行并存储，最终会存储一个较大的表，但是除非行数异常的多，否则也不会有什么问题**  
增添了四个新的aegisub变量，它们可以进行链式调用，比如`line.logic_next.prev.logic_prev`  
`line.prev`  - 当前行的物理结构的上一行(仅真正含有歌词字幕的dialogue行)，如果没有则为`nil`  
`line.next`  - 当前行的物理结构的上一行(仅真正含有歌词字幕的dialogue行)，如果没有则为`nil`  
`line.logic_prev` - 若当前的`line.prev`开始时间与结束时间与当前`line`相同，那么这个变量指`line.prev`，否则为`nil`  
`line.logic_next` - 若当前的`line.next`开始时间与结束时间与当前`line`相同，那么这个变量指`line.next`，否则为`nil`