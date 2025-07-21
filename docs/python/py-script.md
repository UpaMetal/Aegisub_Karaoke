# [python文件](../../python/)  
这些是一些python文件，是我在上古时期写的(当时还不会lua),后续可能会将一些转为lua的自动化脚本
- [lyricGet.py](../../python/lyricGet.py) 用于从utaten上获取歌词文件，输入是某个歌曲的链接，比如 https://utaten.com/lyric/jb50912204/  
- [lyricConvert.py](../../python/lyricConvert.py) 用于将上步转换的歌词转换成aegisub能识别的**光|<ひかり**的形式，但是目前还有BUG, 因为有时情况很复杂，有嵌套框号和奇怪的字符之内的，因为懒暂时还没有修复，不过又不是不能用  
- [timeConvert.py](../../python/timeConvert.py) 这位更是重量级，它可以重新调整字幕行的时间，按照某个规则实现字幕提早出现和延迟结束，还有很大修改空间，不过先这样吧  
- [timeConvertNarrow](../../python/timeConvertNarrow.py) 这位上上面那位的变种，将字幕行的时间都调整为互相接触的紧凑版，同样是按照某个规则来的   
