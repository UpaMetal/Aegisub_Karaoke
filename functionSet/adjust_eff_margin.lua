function adjust_line_property(l, adjust_dis)
    l.left = l.left + adjust_dis
    l.right = l.right + adjust_dis
    l.center = (l.left + l.right) / 2
    while l.logic_prev do
        l = l.logic_prev
        l.left = l.left + adjust_dis
        l.right = l.right + adjust_dis
        l.center = (l.left + l.right) / 2
    end
end
adjust_eff_margin = function(meta, line, spacing, overlapped_pixels, center)
    spacing = spacing or 30
    overlapped_pixels = overlapped_pixels or 40
    center = center or false
    local l = line
    local topLine_width = 0
    local bottomLine_width = 0
    local left_eff_margin = 0
    local right_eff_margin = 0
    if l.effect:match("[Kk]araoke") and l.halign == "left" and not l.logic_prev and line.actor ~= "cancel" then
        left_eff_margin = l.left
        topLine_width = l.right
        while l.logic_next do
            l = l.logic_next
            l.left = l.prev.right + spacing
            l.right = l.left + l.width
            l.center = (l.left + l.right) / 2
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
                    bottoml.center = (bottoml.left + bottoml.right) / 2
                end
            end
            if (bottomLine_width ~= 0) then
                if (topLine_width + bottomLine_width < meta.res_x + overlapped_pixels) then
                    local adjust_dis = (meta.res_x + overlapped_pixels - topLine_width - bottomLine_width) / 2
                    adjust_line_property(l, -adjust_dis)
                    l = l.prev
                    adjust_line_property(l, adjust_dis)
                else
                    if topLine_width - left_eff_margin > meta.res_x - 10 then
                        _G.aegisub.log("上行存在超出屏幕外的文字,请手动调整相应行 ")
                    elseif topLine_width + left_eff_margin > meta.res_x then
                        local adjust_dis = (meta.res_x - topLine_width + left_eff_margin) / 2 - left_eff_margin
                        adjust_line_property(lastl, adjust_dis)
                    end
                    if bottomLine_width - right_eff_margin > meta.res_x - 10 then
                        _G.aegisub.log("下行存在超出屏幕外的文字,请手动调整相应行 ")
                    elseif bottomLine_width + right_eff_margin > meta.res_x then
                        local adjust_dis = right_eff_margin - (meta.res_x - bottomLine_width + right_eff_margin) / 2
                        adjust_line_property(l, adjust_dis)
                    end
                end
            else
                if topLine_width - left_eff_margin > meta.res_x - 10 then
                    _G.aegisub.log("上行存在超出屏幕外的文字,请手动调整相应行 ")
                elseif center then
                    local adjust_dis = (meta.res_x - topLine_width + left_eff_margin) / 2 - left_eff_margin
                    adjust_line_property(lastl, adjust_dis)
                end
            end
        else
            if topLine_width - left_eff_margin > meta.res_x - 10 then
                _G.aegisub.log("上行存在超出屏幕外的文字,请手动调整相应行 ")
            elseif center then
                local adjust_dis = (meta.res_x - topLine_width + left_eff_margin) / 2 - left_eff_margin
                adjust_line_property(lastl, adjust_dis)
            end
        end
    end
end
