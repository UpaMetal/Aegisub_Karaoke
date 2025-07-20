function generate_syl_clip_from_furi_K_table(start_x_position, start_y_position, end_x_position, end_y_position, time_offset, extra_ass_tag_in, extra_ass_tag_out)
    local furi_K_table = get_furi_K_table_from_syl(syl)
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
end