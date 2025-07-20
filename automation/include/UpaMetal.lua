local Yutils = require 'Yutils'
local UpaMetal
UpaMetal = {
    -- 用于对与数学相关的东西做一些变化
    math = {
        -- 四舍五入
        round = function(n)
            if n >= 0 then
                return math.floor(n + 0.5)
            else
                return math.ceil(n - 0.5)
            end
        end,
        -- 正态分布随机数发生器,输入为想要生成的区间的最小值,最大值,方差(输入为nil则默认为[(最大值-最小值) / 6]^2),期望值(输入为nil则默认为(最大值+最小值) / 2),执行次数(超过执行次数若依旧没有落到指定区间的值则取离期望值较近的区间端点)
        random_Gaussian_distribution = function(min, max, variance, expectation, iterations)
            variance = variance or ((max - min) / 6)^2
            expectation = expectation or (min + max) / 2
            iterations = iterations or 1000
            local std = math.sqrt(variance)
            for _ = 1, iterations do
                local u1, u2 = math.random(), math.random()
                local z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
                local x = expectation + z * std
                local n = math.floor(x + 0.5)
                if n >= min and n <= max then
                    return n
                end
            end
            return (math.abs(expectation - min) < math.abs(expectation - max)) and min or max
        end
    },
    -- 用于更复杂的特定参数之类(通常包括aegisub的独特变量)的算法, 输入可以是更复杂的东西，输出通常也是一些number或string
    algorithm = {
        -- 根据给出的一次函数(水平方向)计算给出位置的对应时间,输入为区域的左边界x值,右边界x值,对应的时间tx1,tx2,期望得到对应t的x坐标
        linear_calculate_time_from_position = function (start_x_position, end_x_position, start_time, end_time, x_position)
            return start_time + (end_time - start_time) * (x_position - start_x_position) / (end_x_position - start_x_position)
        end,
        -- 返回当前syl的假名注音表，下标代表分别是第几个假名注音，对应的值为其持续时间，支持非首尾的负K值占位空串(会将负时间平摊到其相邻两个的假名上)
        get_furi_K_table_from_syl = function(syl)
            local furi_K_table = {}    
            local emptyFlag = false      
            for i = 1, #syl.furi do
                local s = syl.furi[i]        
                if(s.text_stripped == "" ) then            
                    emptyFlag = true     
                    furi_K_table[#furi_K_table] = furi_K_table[#furi_K_table] + s.duration / 2           
                    furi_K_table[#furi_K_table + 1] = s.duration / 2       
                else
                    if emptyFlag then                
                        furi_K_table[#furi_K_table] = furi_K_table[#furi_K_table] + s.duration                
                        emptyFlag = false           
                    else                
                        furi_K_table[#furi_K_table + 1] = s.duration            
                    end           
                end    
            end     
            return furi_K_table 
        end,
        --将行的开始时间与结束时间转换为帧，由于aegisub是以厘秒为单位，理论上此算法应只用于百帧以内的视频
        --开始帧和结束帧分别都是在此时间段内会被渲染的帧的范围区间[开始帧, 结束帧），也就是说[开始帧, 结束帧 - 1]是会被渲染的
        line_time_to_frame = function(line, frame_rate)   
            return math.max(math.ceil(line.start_time  * frame_rate / 1000  - 1), 0), math.ceil(line_end_time  * frame_rate / 1000) 
        end,
        -- 将时间转换为帧，当前时间属于第几帧的范围内
        time_to_frame = function(time, frame_rate)
            return math.max(math.ceil(line.start_time  * frame_rate / 1000  - 1), 0)
        end,
        -- 将帧转换为时间，要让此帧显示的最大开始时间
        frame_to_time = function(frame, frame_rate)
            return math.ceil(frame * 100 / frame_rate - 1) * 10
        end,

        -- 自动调整上下总行行距
        adjust_eff_margin = function(meta, line, spacing, overlapped_pixels)
            spacing = spacing or 30
            overlapped_pixels = overlapped_pixels or 20
            local l = line
            local topLine_width = 0
            local bottomLine_width = 0
            local left_eff_margin = 0
            local right_eff_margin = 0
            if l.halign == "left" and not l.logic_prev then
                left_eff_margin = l.left
                topLine_width = l.right
                while l.logic_next do
                    l = l.logic_next
                    l.left = l.prev.right + spacing
                    l.right = l.left + l.width
                    topLine_width = topLine_width + spacing + l.width
                end
                local lastl = l
                l = l.next
                if l then
                    if l.halign == "right" and not l.logic_prev then
                        while l.logic_next do
                            bottomLine_width = bottomLine_width + l.width + spacing
                            l = l.logic_next
                        end
                        bottomLine_width = bottomLine_width + l.width + l.eff_margin_r
                        right_eff_margin = l.eff_margin_r
                        local bottoml = l
                        while bottoml.logic_prev do
                            bottoml = bottoml.logic_prev
                            bottoml.right = bottoml.next.left - spacing
                            bottoml.left = bottoml.right - bottoml.width
                        end
                    end
                    if(bottomLine_width ~= 0) then
                        if(topLine_width + bottomLine_width < meta.res_x + overlapped_pixels) then
                            local adjust_dis = (meta.res_x + overlapped_pixels - topLine_width - bottomLine_width) / 2
                            l.left = l.left - adjust_dis
                            l.right = l.right - adjust_dis
                            while l.logic_prev do
                                l = l.logic_prev
                                l.left = l.left - adjust_dis
                                l.right = l.right - adjust_dis
                            end
                            l = l.prev
                            l.left = l.left + adjust_dis
                            l.right = l.right + adjust_dis
                            while l.logic_prev do
                                l = l.logic_prev
                                l.left = l.left + adjust_dis
                                l.right = l.right + adjust_dis
                            end
                        else
                            if topLine_width - left_eff_margin > meta.res_x - 10 then
                                _G.aegisub.log("上行存在超出屏幕外的文字,请手动调整相应行\n")
                            elseif topLine_width + left_eff_margin > meta.res_x then
                                local adjust_dis = left_eff_margin - (meta.res_x - topLine_width + left_eff_margin) / 2
                                lastl.left = lastl.left - adjust_dis
                                lastl.right = lastl.right - adjust_dis
                                while lastl.logic_prev do
                                    lastl = lastl.logic_prev
                                    lastl.left = lastl.left - adjust_dis
                                    lastl.right = lastl.right - adjust_dis
                                end
                            end

                            if bottomLine_width - right_eff_margin > meta.res_x - 10 then
                                _G.aegisub.log("下行存在超出屏幕外的文字,请手动调整相应行\n")
                            elseif bottomLine_width + right_eff_margin > meta.res_x then
                                local adjust_dis = right_eff_margin - (meta.res_x - bottomLine_width + right_eff_margin) / 2
                                l.left = l.left + adjust_dis
                                l.right = l.right + adjust_dis
                                while l.logic_prev do
                                    l = l.logic_prev
                                    l.left = l.left + adjust_dis
                                    l.right = l.right + adjust_dis
                                end
                            end
                        end
                    else
                        if topLine_width - left_eff_margin > meta.res_x - 10 then
                            _G.aegisub.log("上行存在超出屏幕外的文字,请手动调整相应行\n")
                        else
                            local adjust_dis = left_eff_margin - (meta.res_x - topLine_width + left_eff_margin) / 2
                            lastl.left = lastl.left - adjust_dis
                            lastl.right = lastl.right - adjust_dis
                            while lastl.logic_prev do
                                lastl = lastl.logic_prev
                                lastl.left = lastl.left - adjust_dis
                                lastl.right = lastl.right - adjust_dis
                            end
                        end
                    end
                else
                    if topLine_width - left_eff_margin > meta.res_x - 10 then
                        _G.aegisub.log("上行存在超出屏幕外的文字,请手动调整相应行\n")
                    else
                        local adjust_dis = left_eff_margin - (meta.res_x - topLine_width + left_eff_margin) / 2
                        lastl.left = lastl.left - adjust_dis
                        lastl.right = lastl.right - adjust_dis
                        while lastl.logic_prev do
                            lastl = lastl.logic_prev
                            lastl.left = lastl.left - adjust_dis
                            lastl.right = lastl.right - adjust_dis
                        end
                    end
                end
            end
        end
    },
    -- 输出一般是图形的绘图代码
    shape = {
        --将小数绘图代码转换为整数绘图代码
        decimal2Integer_of_drawing_coords = function(draw_string)
            local result = {}
            for token in draw_string:gmatch("%S+") do
                local num = tonumber(token)
                if num then
                    table.insert(result, tostring(UpaMetal.math.round(num)))
                else
                    table.insert(result, token)
                end
            end
            return table.concat(result, " ")
        end,
        -- 如果一行里的两个图形绘图路径时钟方向相同则取并集,否则取交集的补集
        -- 固定直径圆形,可指定路径方向,入为圆的直径,绘图时钟方向(输入为nil则默认为0-顺时针)
        circle = function(diameter, clockwise)
            clockwise = clockwise or 0
            local S = "m %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f "
            local a = diameter / 2
            local b = a * 4 / 3
            if clockwise == 0 then
                return string.format(S, -a, 0, -a, -b, a ,-b, a, 0, a, b, -a, b, -a, 0)
            elseif clockwise == 1 then
                return string.format(S, a, 0, a, -b, -a, -b, -a, 0, -a, b, a, b, a, 0)
            end
        end,
        -- 随机范围直径圆形,可指定路径方向,输入为想要生成区间直径的最小值,最大值,绘图时钟方向(输入为nil则默认为0-顺时针)
        random_circle = function (min, max, clockwise)
            clockwise = clockwise or 0
            local S = "m %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f b %.3f %.3f %.3f %.3f %.3f %.3f "
            local a = math.random(min / 2, max / 2)
            local b = a * 4 / 3
            if clockwise == 0 then
                return string.format(S, -a, 0, -a, -b, a, -b, a, 0, a, b, -a, b, -a, 0)
            elseif clockwise == 1 then
                return string.format(S, a, 0, a, -b, -a, -b, -a, 0, -a, b, a, b, a, 0)
            end
        end,
        -- 固定大小正三角形,可指定路径方向,输入为该正三角形外接圆直径,绘图时钟方向(输入为nil则默认为0-顺时针)
        regular_triangle = function(length, clockwise)
            clockwise = clockwise or 0
            local S = "m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f "
            local a = length / 2
            local b = a / 2 * 3^0.5
            local c = a / 2
            if clockwise == 0 then
                return string.format(S, -b, c, 0, -a, b, c, -b, c, -b, c)
            elseif clockwise == 1 then
                return string.format(S, b, c, 0, -a, -b, c, b, c, b, c)
            end
        end,
        -- 固定底高等腰三角形,可指定路径方向,输入为等腰三角形底边长,高,绘图时钟方向(输入为nil则默认为0-顺时针)
        isosceles_triangle = function (length, height, clockwise)
            clockwise = clockwise or 0
            local S = "m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f "
            local a = length / 2
            local b = height / 2
            if clockwise == 0 then
                return string.format(S, 0, -b / 2, a / 2, b / 2, -a / 2, b / 2, 0, -b / 2)
            elseif clockwise == 1 then
                return string.format(S, 0, -b / 2, -a / 2, b / 2, a / 2, b / 2, 0, -b / 2)
            end
        end,
        -- 固定边长正方形，可指定路径方向,输入为正方形边长,高,绘图时钟方向(输入为nil则默认为0-顺时针)
        square = function(length, clockwise)
            clockwise = clockwise or 0
            local S = "m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f "
            local a = length
            if clockwise == 0 then
                return string.format(S, -a / 2, -a / 2, a / 2, -a / 2, a / 2, a / 2, -a / 2, a / 2, -a / 2, -a / 2)
            elseif clockwise == 1 then
                return string.format(S, -a / 2, -a / 2, -a / 2, a / 2, a / 2, a / 2, a / 2, -a / 2, -a / 2, -a / 2)
            end
        end,
        -- 随机范围边长正方形,可指定路径方向,
        random_square = function(min, max, clockwise)
            clockwise = clockwise or 0
            local S = "m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f "
            local a = math.random(min, max)
            if clockwise == 0 then
                return string.format(S, -a / 2, -a / 2, a / 2, -a / 2, a / 2, a / 2, -a / 2, a / 2, -a / 2, -a / 2)
            elseif clockwise == 1 then
                return string.format(S, -a / 2, -a / 2, -a / 2, a / 2, a / 2, a / 2, a / 2, -a / 2, -a / 2, -a / 2)
            end
        end,
        -- 五线谱(五条细矩形), 输入为单条线长度，宽度，相邻两线的距离,绘图时钟方向(输入为nil则默认为0-顺时针)
        staff = function(length, width, distance, clockwise)
            local S = "m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f m %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f l %.3f %.3f "
            local a =  length / 2
            local b =  width / 2
            if clockwise == 0 then
                return string.format(S, -a, -b - 2 * distance, a, -b - 2 * distance, a, b - 2 * distance, -a, b - 2 * distance, -a, -b - 2 * distance, -a, -b - distance, a, -b - distance, a, b - distance, -a, b - distance, -a, -b - distance, -a, -b, a, -b, a, b, -a, b, -a, -b, -a, -b + distance, a, -b + distance, a, b + distance, -a, b + distance, -a, -b + distance, -a, -b + 2 * distance, a, -b + 2 * distance, a, b + 2 * distance, -a, b + 2 * distance, -a, -b + 2 * distance)
            elseif clockwise == 1 then
                return string.format(S, -a, -b - 2 * distance, -a, b - 2 * distance, a, b - 2 * distance, a, -b - 2 * distance, -a, -b - 2 * distance, -a, -b - distance, -a, b - distance, a, b - distance, a, -b - distance, -a, -b - distance, -a, -b, -a, b, a, b, a, -b, -a, -b, -a, -b + distance, -a, b + distance, a, b + distance, a, -b + distance, -a, -b + distance, -a, -b + 2 * distance, -a, b + 2 * distance, a, b + 2 * distance, a, -b + 2 * distance, -a, -b + 2 * distance)
            end
        end,
        note = function(x)-- 九个音符，可指定任意一个
            -- 高音谱号
            local shape_G_clef="m 3 -93 b -7 -93 -18 -68 -9 -38 b -24 -24 -41 -1 -37 14 b -32 44 -8 49 8 45 l 12 65 b 13 88 -10 89 -12 81 b -9 80 0 81 -3 67 b -6 57 -22 58 -23 74 b -20 96 17 94 15 67 l 11 44 b 20 38 29 30 27 12 b 24 4 14 -9 1 -6 l -3 -24 b 20 -41 18 -85 3 -93 m 6 -78 b 14 -77 9 -50 -6 -41 b -9 -58 -7 -78 6 -78 m 7 41 b -21 55 -51 10 -6 -21 l -2 -5 b -33 14 -8 36 -3 34 l -3 33 b -13 28 -16 12 0 7 m 10 40 l 2 7 b 21 4 27 31 10 40 " 
            -- 二分音符
            local shape_half_note="m -2 -85 l -2 51 b -11 44 -56 48 -51 85 b -48 106 -4 94 2 69 l 2 -85 m -46 86 b -50 72 -12 48 -4 56 b -2 75 -43 96 -46 86 "
            -- 四分音符
            local shape_quarter_note="m -2 -85 l -2 51 b -11 44 -56 48 -51 85 b -48 106 -4 94 2 69 l 2 -85 "
            -- 八分音符
            local shape_eighth_note="m -2 -87 l -2 47 b -24 35 -53 56 -49 75 b -41 98 -4 83 2 61 l 2 -40 b 27 -38 55 -5 28 43 l 30 43 b 39 26 54 1 36 -30 b 24 -43 2 -60 2 -87 "
            -- 两个八分音符相连
            local shape_two_eighth_notes="m -44 -60 l -44 43 b -54 35 -82 44 -81 65 b -72 85 -42 67 -41 52 l -41 -48 l 43 -63 l 43 28 b 30 20 5 31 6 50 b 13 67 43 54 46 38 l 46 -76 "
            -- 十六分音符
            local shape_sixteenth_note="m -2 -73 l -2 47 b -13 37 -48 50 -44 73 b -38 91 -2 83 2 58 l 2 -11 b 20 0 53 10 32 54 l 35 54 b 40 42 46 28 38 9 b 42 -3 42 -25 23 -41 b 13 -53 2 -57 2 -73 m 2 -44 b 17 -36 40 -21 36 5 b 25 -12 4 -19 2 -44 "
            -- 两个十六分音符相连
            local shape_two_sixteenth_notes="m -42 -53 l -42 50 b -52 42 -80 51 -79 72 b -70 92 -40 74 -39 59 l -39 -11 l 45 -26 l 45 34 b 29 27 8 38 8 55 b 16 73 45 61 48 45 l 48 -70 m -39 -24 l -39 -41 l 45 -56 l 45 -39 "
            -- 低音谱号
            local shape_D_clef="m 60.29 35.31 b 60.29 36.94 58.96 38.28 57.32 38.28 55.68 38.28 54.36 36.94 54.36 35.31 54.36 33.67 55.68 32.34 57.32 32.34 58.96 32.34 60.29 33.67 60.29 35.31 m 60.29 18.66 b 60.29 20.3 58.96 21.62 57.32 21.62 55.68 21.62 54.36 20.3 54.36 18.66 54.36 17.02 55.68 15.69 57.32 15.69 58.96 15.69 60.29 17.02 60.29 18.66 m 48.75 28.38 b 45.9 2.77 12.89 7.04 10.01 19.97 8.61 26.27 9.86 30.09 11.35 32.31 12.46 34.35 14.61 35.75 17.1 35.75 20.74 35.75 23.69 32.79 23.69 29.15 23.69 25.51 20.74 22.56 17.1 22.56 13.9 22.56 11.23 24.84 10.63 27.87 8.62 19.71 14.38 13.7 23.36 12.72 32.43 11.73 41 20.96 37.04 40.75 33.35 59.24 9.84 61.35 9.84 61.35 30.12 61.52 51.72 55.09 48.75 28.38 "
            -- 升记号
            local shape_pound_sign="m 30.64 38.53 l 19.55 42.41 19.55 35.16 30.64 31.29 m 41.72 27.41 l 41.72 19.3 34.05 21.99 34.05 13.12 30.64 13.12 30.64 23.19 19.55 27.07 19.55 13.12 16.14 13.12 16.14 28.26 7.61 31.25 7.61 39.34 16.14 36.36 16.14 43.6 7.61 46.59 7.61 54.69 16.14 51.71 16.14 60.88 19.55 60.88 19.55 50.51 30.64 46.63 30.64 60.88 34.05 60.88 34.05 45.44 41.72 42.75 41.72 34.66 34.05 37.34 34.05 30.09 "

            x = x or 4
            if x == 1 then
                return shape_G_clef
            elseif x == 2 then
                return shape_half_note
            elseif x == 3 then
                return shape_quarter_note
            elseif x == 4 then
                return shape_eighth_note
            elseif x == 5 then
                return shape_two_eighth_notes
            elseif x == 6 then
                return shape_sixteenth_note
            elseif x == 7 then
                return shape_two_sixteenth_notes
            elseif x == 8 then
                return shape_D_clef
            elseif x == 9 then
                return shape_pound_sign
            end
        end
    },
    -- 输出一般是特效代码的组合的string
    ass = {
        -- 根据syl的注音假名表生成分段的syl裁剪区,可实现分段匀速走字效果,输入为想要裁剪区域的左上角坐标,右下角坐标(y值若输入为nil则分别默认为0与视频分辨率y(比如1920*1080,则取1080)),时间偏移参数，通常为相较于line.start_timen的偏移
        -- 最后的输入为附加特效标签信息\t标签内与\t外附加特效标签信息,它必须是一个表,表中可以写入给每个分段之间添加的信息,例如syl有三个假名注音,那么你可以添加3个附加信息(多余的信息会被忽略),必须符合aegisub规范,除非你知道自己在做什么,否则请保持此项为nil
        -- 这里给出一个syl的左边缘和右边缘计算公式，但是可能会有误差，因此如果发现边框不能全部覆盖字可适当调整几个像素
        -- 通常情况下 syl_visual_left = line.left + syl.left - bord * (scale_x / 100) - math.max(0, -shadx) 
        -- 通常情况下 syl_visual_right = line.left + syl.right - (spacing - bord) * (scale_x / 100) + math.max(0, shadx)
        generate_syl_clip_from_furi_K_table = function(syl, meta, start_x_position, start_y_position, end_x_position, end_y_position, time_offset, extra_ass_tag_in, extra_ass_tag_out)
            local furi_K_table = UpaMetal.algorithm.get_furi_K_table_from_syl(syl)
            time_offset = time_offset or 0
            local tag_in = extra_ass_tag_in or {}
            local tag_out = extra_ass_tag_out or {}
            local top = start_y_position or 0
            local bottom = end_y_position or meta.res_y
            local n = #furi_K_table                  
            local left = start_x_position                  
            local right = end_x_position          
            if n == 0 then return string.format("\\t(%d, %d, \\clip(%.3f, %.3f, %.3f, %.3f)", syl.start_time, syl.end_time, left, top, right, bottom) .. (tag_in[i] or "") .. ")" .. (tag_out[i] or "") end            
            local result = ""               
            local width = right - left                                                
            local x_start = left                  
            local t_start = syl.start_time - time_offset                   
            for i = 1, n do                                        
                local k = furi_K_table[i]                                            
                local x_end = Yutils.math.round(x_start + i * width / n, 3)                                         
                local t_end = t_start + k                                            
                result = result .. string.format("\\t(%d, %d, \\clip(%.3f, %.3f, %.3f, %.3f)", t_start, t_end, left, top, x_end, bottom) .. (tag_in[i] or "") .. ")" .. (tag_out[i] or "")                               
                t_start = t_end                     
            end                      
            return result 
        end,
        -- AutoTag系列函数
        AutoTags = function(line, Intervalo, Dato1, Dato2)            
            local RESULTADO = ""     
            local SUERTE = 0     
            local CONTADOR = 0                               
            local count = math.ceil(line.duration / Intervalo)                 			
            local ARREGLO = {Dato1, Dato2}    			              
            for i = 1, count do               CONTADOR = i    	    	    		
                if Dato1 and Dato2 then     					
                    if  CONTADOR % 2 == 0 then    								
                        SUERTE = ARREGLO[1]    					
                    else    								
                        SUERTE = ARREGLO[2]    					
                    end	    		
                end     				    	
                RESULTADO = RESULTADO .."\\t(" ..(i - 1) * Intervalo .. "," .. i * Intervalo .. ",\\" .. SUERTE .. ")" .. "" --这里最后一次循环的结束时间会超出line.duration但会被aegisub优化掉，因此不做处理    			     
            end         		     
            return RESULTADO	  	    	               
        end,
        AutoTags1 = function(line, Intervalo, Dato1, Dato2, Pause)  
            local RESULTADO = ""  
            local SUERTE = 0  
            local CONTADOR = 0   
            local count = math.ceil(line.duration / (Intervalo + Pause))  
            local ARREGLO = {Dato1, Dato2}  
            for i = 1, count do  	
                CONTADOR = i  	
                if Dato1 and Dato2 then  		
                    if  CONTADOR % 2 == 0 then  		
                        SUERTE = ARREGLO[1]  		
                    else  		
                        SUERTE = ARREGLO[2]  		
                    end  	
                end  	
                RESULTADO = RESULTADO .."\\t(" .. (i - 1) * (Intervalo + Pause) .. "," .. i * Intervalo + Pause * (i - 1) .. ",\\" .. SUERTE .. ")" .. ""  
            end  
            return RESULTADO  
        end,
        AutoTags2 = function(line, Intervalo, Dato1, Dato2, Dealy)            
            local RESULTADO = ""     
            local SUERTE = 0     
            local CONTADOR = 0                                 
            local count = math.ceil(line.duration / Intervalo)                 			
            local ARREGLO = {Dato1, Dato2}    			              
            for i = 1, count do               
                CONTADOR = i    	    	    		
                if Dato1 and Dato2 then     					
                    if  CONTADOR % 2 == 0 then    								
                        SUERTE = ARREGLO[1]    					
                    else    								
                        SUERTE = ARREGLO[2]    					
                    end	    		
                end     				    	
                RESULTADO = RESULTADO .. "\\t(" ..(i - 1) * Intervalo + Dealy .. "," .. i * Intervalo+Dealy .. ",\\" .. SUERTE .. ")" .. ""     			     
            end         		     
            return RESULTADO	  	    	               
        end,
        AutoTags3 = function(line, Intervalo1, Intervalo2, Dato1, Dato2)  
            local RESULTADO = ""       	  
            local SUERTE = 0       	  
            local CONTADOR = 0       	                      	  
            local count = 2 * math.ceil(line.duration / (Intervalo1 + Intervalo2))  	  
            local d = math.ceil((Intervalo2 - Intervalo1) / count)  
            local t = {}  
            local ARREGLO = {Dato1,Dato2}    			                	  
            for i = 1, count do                 		  
                CONTADOR = i  
                t[1] = 0  
                t[i + 1] = t[i] + Intervalo1 + (i - 1) * d  
                if Dato1 and Dato2 then  	  
                    if  CONTADOR % 2 == 0 then    								  		  
                        SUERTE = ARREGLO[1]  	  
                    else    								  		  
                        SUERTE = ARREGLO[2]    					  	  
                    end  	  
                end     				    	  	  
                RESULTADO = RESULTADO .."\\t(" .. t[i] .. "," .. t[i + 1] .. ",\\" .. SUERTE .. ")" .. ""     			       	  
            end         		       	  
            return RESULTADO	  	    	                 	  
        end
    }
}

if ({...})[1] then
	_G.UpaMetal = UpaMetal
end

return UpaMetal