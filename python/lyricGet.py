import re
import requests
from bs4 import BeautifulSoup
from pathlib import Path

def get_href_name():
    while True:
        user_input = input("please input the website href ")
        cleaned_input = user_input.strip()
        if not cleaned_input:
            print(" The input cannot be empty, please re-enter")
            continue
            
        if len(cleaned_input) > 500:
            print("The input is too long, maybe it has error")
            continue
            
        return cleaned_input

def search_href_name(href_name):
    headers = {
        'User-Agent':'Mozilla/5.0(Windows NT 10.0; Win64; x64)AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.'
    }
    search_url = f"{href_name}"
    try:
        response = requests.get(search_url, headers = headers, verify = False)
        response.encoding = 'utf-8'
        response.raise_for_status()
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"Failed to search:{e}")
        return None

def save_html(html, filename):
    try:
        # 获取桌面路径
        parts = filename.split("/")
        desktop_path = Path.home() / "Desktop"
        
        # 创建完整文件路径
        filepath = desktop_path / f"{parts[4]}.txt"
        
        # 写入文件（使用UTF-8编码）
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)
        
        print(f"The file has been saved to:{filepath}")
        return True
    except Exception as e:
        print(f"Failed to save file:{e}")
    return False

def process_lyrics(html):
    soup = BeautifulSoup(html, 'lxml')
    
    # 提取歌词正文
    hiragana_div = soup.find('div', class_='hiragana')
    
    if not hiragana_div:
        return "未找到歌词内容"

    # 预处理：移除不需要的标签
    for tag in hiragana_div.find_all(['script', 'style', 'a']):
        if tag.name != 'br':
            tag.decompose()

    # 处理所有ruby标签
    for ruby in hiragana_div.find_all('span', class_='ruby'):
        if len(ruby.find_all('rb')) != len(ruby.find_all('rt')):
            print(f"警告：rb/rt数量不匹配于 {ruby}")
        # 提取rb和rt内容
        replacements = []
        # 同时遍历rb和rt标签
        for rb_tag, rt_tag in zip(
            ruby.find_all('span', class_='rb'),
            ruby.find_all('span', class_='rt')
        ):
            rb = rb_tag.get_text(strip=True)
            rt = rt_tag.get_text(strip=True)
            replacements.append(f"{rb}（{rt}）")
        
        # 合并多个rb/rt对
        ruby.replace_with(''.join(replacements))

    # 处理换行标签
    for br in hiragana_div.find_all('br'):
        br.replace_with('\n')


     # 清理多余空白（但保留换行结构）
    clean_text = hiragana_div.get_text(separator='', strip=False)
    
    # 清理多余空白
    clean_text = re.sub(r'[ \t]+', ' ', clean_text)    # 合并空格
    clean_text = re.sub(r'\n{3,}', '\n\n', clean_text) # 段落间距
    clean_text = re.sub(r' ?\n ?', '\n', clean_text)   # 清理换行符前后空格
    
    return clean_text.strip()

def main():
    # 获取名称
    print("=== Utaten Lyrics Grabber ===")
    href_name = get_href_name()
    
    # 显示正在搜索的提示
    print(f"\n searching：{href_name}...")
    
    # 原有搜索逻辑保持不变
    if(search_html := search_href_name(href_name)) is None:
        return
    print(f"\n The search is complete")

    if(processed := process_lyrics(search_html)) is None:
        return
    save_html(processed, href_name)
    print(f"extract is succeed")
    

if __name__ == "__main__":
    main()

