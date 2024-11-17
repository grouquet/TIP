import json

json_filename = 'output.json'

# 读取 JSON 文件
with open(json_filename, 'r') as file:
    data = json.load(file)

new_data = {}

for item in data:
    # 使用文件名作为新字典的键
    filename = item['Filename']
    # 将标签列表转换为整数列表
    labels = list(map(int, item['Labels']))
    # 添加到新字典
    new_data[filename] = labels

# 将新的数据结构编码为 JSON 字符串
new_json_str = json.dumps(new_data, indent=4)

# 打印新的 JSON 字符串
print(new_json_str)

# 可选：将新的 JSON 数据保存到文件
new_json_filename = 'submission.json'
with open(new_json_filename, 'w') as file:
    file.write(new_json_str)

print(f"New JSON file has been written to {new_json_filename}")