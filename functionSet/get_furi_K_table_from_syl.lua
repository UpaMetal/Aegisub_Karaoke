function get_furi_K_table_from_syl()
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
end