import os
from collections import deque

def seconds_to_time(seconds):
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    seconds_frac = seconds % 60
    return f"{hours}:{minutes:02d}:{seconds_frac:05.2f}"

def time_to_seconds(time_str):
    parts = time_str.split(':')
    hours = int(parts[0])
    minutes = int(parts[1])
    seconds_part = parts[2].split('.')
    seconds = int(seconds_part[0])
    hundredths = int(seconds_part[1])
    
    total = hours * 3600 + minutes * 60 + seconds + hundredths / 100
    return total

def process_file(input_path, output_path):
    window = deque(maxlen=3)
    line_number = 0
    temp1 = 0
    temp2 = 0
    temp4 = 0
    with open(input_path, 'r', encoding='utf-8') as fin, \
        open(output_path, 'w', encoding='utf-8') as fout:
        
        for line in fin:
            raw_line = line.rstrip('\r\n')
            is_dialogue = raw_line.startswith("Dialogue:") and (not raw_line.__contains__("0:00:00.00,0:00:00.00"))
            if not is_dialogue:
                fout.write(raw_line + '\n')
                continue
            line_number = line_number + 1
            fields = raw_line.split(',', 9)
            start_sec = time_to_seconds(fields[1].strip())
            end_sec = time_to_seconds(fields[2].strip())
            parsed_data = {
                'raw': raw_line,
                'start': start_sec,
                'end': end_sec,
                'fields': fields
            }
            window.append(parsed_data)

            if len(window) == 1:
                line2 = window[0]
                if line2['start'] < 1:
                    temp1 =  line2['start']
                elif line2['start'] > 1.5 and line2['start'] < 5:
                    temp1 = max(line2['start'] - 1, 1)
                else:
                    temp1 = 4
                line2['start'] = line2['start'] - temp1

            if len(window) == 2:
                line2 = window[0]
                line1 = window[1]
                temp2 = line1['start'] - line2['start']
                line1['start'] = line2['start']

            if len(window) == 3:
                line2 = window[0]
                line1 = window[1]
                line0 = window[2]
                gap = line0['start'] - line2['end']
                if gap < 0.5: #这种情况一般不会出现，如果存在再考虑
                    temp3 = 0
                    temp4 = gap
                elif gap >= 0.5 and gap < 0.7:
                    temp3 = gap - 0.5
                    temp4 = 0.5
                elif gap >= 0.7 and gap < 1.2:
                    temp3 = 0.2
                    temp4 = gap - 0.2
                elif gap >= 1.2 and gap < 1.4:
                    temp4 = gap - 1
                    temp3 = 1
                elif gap >= 1.4 and gap < 1.8:
                    temp4 = 0.4
                    temp3 = gap - 0.4
                elif gap >= 1.8 and gap < 4:
                    temp3 = 0.4
                    temp4 = gap - 0.8
                elif gap >= 4 and gap < 6.8:
                    temp3 = gap - 3.6
                    temp4 = 3.2
                elif gap >= 6.8 and gap < 8:
                    temp3 = 3.2
                    temp4 = 3.2
                elif gap >= 8 :
                    temp3 = (gap - 1.6) * 2.0 / 3.0
                    temp4 = (gap - 1.6) / 3.0

                line2['end'] = line2['end'] + temp3
                line0['start'] = line0['start'] - temp4
                if line_number % 2 == 1:
                    line2['fields'][1] = seconds_to_time(line2['start'])
                    line2['fields'][2] = seconds_to_time(line2['end'])
                    k_value1 = int(round(temp1 * 100))
                    k_value2 = int(round(temp3 * 100))
                    tag1 = f"{{\\k{k_value1}}}"
                    tag2 = f"{{\\k{k_value2}}}"
                    text = line2['fields'][9]
                    text = f"{tag1}{text}{tag2}"
                    line2['fields'][9] = text
                    line2['raw'] = ','.join(line2['fields'])
                    temp1 = temp4
                    fout.write(line2['raw'] + '\n')
                else:
                    line2['fields'][1] = seconds_to_time(line2['start'])
                    line2['fields'][2] = seconds_to_time(line2['end'])
                    k_value1 = int(round(temp2 * 100))
                    k_value2 = int(round(temp3 * 100))
                    tag1 = f"{{\\k{k_value1}}}"
                    tag2 = f"{{\\k{k_value2}}}"
                    text = line2['fields'][9]
                    text = f"{tag1}{text}{tag2}"
                    line2['fields'][9] = text
                    line2['raw'] = ','.join(line2['fields'])
                    temp2 = temp4
                    fout.write(line2['raw'] + '\n')
        if len(window) == 3:
            line_n_3 = window.popleft()
            line_n_2 = window.popleft()
            line_n_1 = window.popleft()
            k_value1 = int((temp2 if line_number % 2 == 1 else temp1) * 100)
            k_value2 = int((line_n_1['end'] + 0.50 - line_n_2['end']) * 100)
            line_n_2['fields'][1] = seconds_to_time(line_n_2['start'])
            line_n_2['fields'][2] = seconds_to_time(line_n_1['end'] + 0.5)
            tag1 = f"{{\\k{k_value1}}}"
            tag2 = f"{{\\k{k_value2}}}"
            text = line_n_2['fields'][9]
            text = f"{tag1}{text}{tag2}"
            line_n_2['fields'][9] = text
            line_n_2['raw'] = ','.join(line_n_2['fields'])
            fout.write(line_n_2['raw'] + '\n')
            k_value1 = int(round((temp1 if line_number % 2 == 1 else temp2) * 100))
            k_value2 = 50
            line_n_1['fields'][1] = seconds_to_time(line_n_1['start'])
            line_n_1['fields'][2] = seconds_to_time(line_n_1['end'] + 0.5)
            tag1 = f"{{\\k{k_value1}}}"
            tag2 = f"{{\\k{k_value2}}}"
            text = line_n_1['fields'][9]
            text = f"{tag1}{text}{tag2}"
            line_n_1['fields'][9] = text
            line_n_1['raw'] = ','.join(line_n_1['fields'])
            fout.write(line_n_1['raw'] + '\n')
    
def main():
    input_path = input("please input the ass file: ").strip('" ')
    output_dir = os.path.dirname(input_path)
    base_name = os.path.basename(input_path)
    filename, ext = os.path.splitext(base_name)
    output_filename = f"{filename}-0{ext if ext else '.ass'}"
    output_path = os.path.join(output_dir, output_filename)


    process_file(input_path, output_path)
    print(f"process finish {output_path}")
    process_file

if __name__ == '__main__':
    main()



            

            



                
                
                


