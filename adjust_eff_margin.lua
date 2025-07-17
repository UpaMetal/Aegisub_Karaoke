function adjust_eff_margin(spacing, overlapped_pixels)
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
                        _G.aegisub.log("上行存在几乎要超出屏幕的文字,已自动调整\n")
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
                        _G.aegisub.log("下行存在几乎要超出屏幕外的文字,已自动调整\n")
                    end
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
                    _G.aegisub.log("上行存在几乎要超出屏幕的文字,已自动调整\n")
                else
                    local adjust_dis = (meta.res_x - topLine_width) / 2
                    lastl.left = lastl.left + adjust_dis
                    lastl.right = lastl.right + adjust_dis
                    while lastl.logic_prev do
                        lastl = lastl.logic_prev
                        lastl.left = lastl.left + adjust_dis
                        lastl.right = lastl.right + adjust_dis
                    end
                end
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
                _G.aegisub.log("上行存在几乎要超出屏幕的文字,已自动调整\n")
            else
                local adjust_dis = (meta.res_x - topLine_width) / 2
                lastl.left = lastl.left + adjust_dis
                lastl.right = lastl.right + adjust_dis
                while lastl.logic_prev do
                    lastl = lastl.logic_prev
                    lastl.left = lastl.left + adjust_dis
                    lastl.right = lastl.right + adjust_dis
                end
            end
        end
    end
end