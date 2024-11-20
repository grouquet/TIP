import json

# 定义输入和输出 JSON 文件名
json_filename = 'output.json'  # 输入文件
new_json_filename = 'submission.json'  # 输出文件

# 读取 JSON 文件
try:
    with open(json_filename, 'r') as file:
        data = json.load(file)
except FileNotFoundError:
    print(f"Error: {json_filename} not found!")
    exit(1)
except json.JSONDecodeError as e:
    print(f"Error decoding JSON: {e}")
    exit(1)

# 初始化新的数据结构
new_data = {}

# 遍历原始数据并转换
for item in data:
    # 使用文件名作为新字典的键
    filename = item['Filename']
    
    # 确保 'Labels' 是一个列表
    labels = item['Labels'] if isinstance(item['Labels'], list) else [item['Labels']]
    
    # 将标签列表转换为整数列表
    try:
        labels = list(map(int, labels))
    except ValueError as e:
        print(f"Error converting labels to integers for file '{filename}': {e}")
        continue
    
    # 添加到新字典
    new_data[filename] = labels

# 将新的数据结构编码为 JSON 字符串
new_json_str = json.dumps(new_data, indent=4)

# 打印新的 JSON 字符串
print("Converted JSON data:")
print(new_json_str)

# 将新的 JSON 数据保存到文件
try:
    with open(new_json_filename, 'w') as file:
        file.write(new_json_str)
    print(f"New JSON file has been written to {new_json_filename}")
except IOError as e:
    print(f"Error writing to file {new_json_filename}: {e}")
