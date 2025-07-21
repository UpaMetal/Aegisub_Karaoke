import os
import re

def process_line(line):
    # 正则匹配所有带括号的部分,非贪婪匹配
    pattern = re.compile(r'(.+?)（(.+?)）')
    
    # 每次匹配并替换
    def replacer(match):
        kanji = match.group(1)  # 漢字
        kana = match.group(2)   # 假名
        if not kana:
            return kanji  # 没有假名的就原样返回
        # 将假名第一个字符标注为 |< 后续为 #|<
        result = kanji + '|<' + kana[0]
        for ch in kana[1:]:
            result += '#|<' + ch
        return result

    # 逐个替换所有匹配
    return pattern.sub(replacer, line)

def convert_file(input_path):
    # 生成输出文件名
    base, ext = os.path.splitext(input_path)
    output_path = base + '-kanade' + ext

    with open(input_path, 'r', encoding='utf-8') as f_in, \
         open(output_path, 'w', encoding='utf-8') as f_out:
        for line in f_in:
            line = line.rstrip('\n')  # 移除换行
            processed = process_line(line)
            f_out.write(processed + '\n')

if __name__ == '__main__':
    input_file = input("please input the lyric file").strip('" ')
    convert_file(input_file)
    print('convert success：', input_file.replace('.txt', '-kanade.txt'))
