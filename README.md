<p align = "center">
    <img src="./img/sunflower.png" weight="100" height="100"/>
</p>  

# Aegisub_Karaoke
本仓库旨在存放我个人使用Aegisub制作Karaoke时编写的相关文件

## 📂 项目结构    
Aegisub_Karaoke/  
├── [automation](automation/)/ # aegisub 自动化脚本目录    
│ ├── [autoload](automation/autoload/)/  
│ &nbsp;&nbsp;├── [kara-templater.lua](automation/autoload/kara-templater.lua) # 修改后的分块执行`karaskel.preproc_line()`与`apply_line()`的**kara-templater.lua**,对于任意`line`行,所有的`line`行都可以被调用   
│ &nbsp;&nbsp;└── [kara-templater-v1.lua](automation/autoload/kara-templater-v1.lua) # 修改后的滑动窗口式执行的**kara-templater.lua**,在`line`行只有`line.prev`和`line.next`生效,不可链式调用  
│ └── [include](automation/include/)/  
│ &nbsp;&nbsp;├── [UpaMetal.lua](automation/include/UpaMetal.lua) # 一些我个人汇总的函数库，来源与其他创作者或项目以及我自己编写的部分  
│ &nbsp;&nbsp;└── [utils-auto4.lua](automation/include/utils-auto4.lua) # 修改后的**utils-auto4.lua**代码, 引入了我自己的**UpaMetal.lua**  
├── [functionSet](functionSet/)/ # 存放单函数形式的lua文件  
├── [ass](ass/)/ # 存放ass字幕文件        
├── [docs](docs/)/ # 存放对应位置的文档  
├── [fonts](fonts/)/ # 存放一些修改后的字体     
└── [img](img/)/  # 一些图片    


## 🙏 鸣谢

特别感谢以下项目或开发者：

- [geometry](https://github.com/matsuzakasatou01/geometry)
- [多华宫与火火里](https://space.bilibili.com/346816900) # B站的一位UP主，其aegisub教学视频让我收获颇多