% 文件夹路径，包含类别描述文件 (.txt 文件)
folderPath = '.\images\labels\train'; % 替换为实际路径

% 示例类别名称 (根据你的 names 文件)
categoryNames = {'person', 'bicycle', 'car', 'motorcycle', 'airplane', ...
    'bus', 'train', 'truck', 'boat', 'traffic light', 'fire hydrant', ...
    'stop sign', 'parking meter', 'bench', 'bird', 'cat', 'dog', ...
    'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', ...
    'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', ...
    'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', ...
    'baseball glove', 'skateboard', 'surfboard', 'tennis racket', ...
    'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', ...
    'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot', ...
    'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch', 'potted plant', ...
    'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse', 'remote', ...
    'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink', ...
    'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear', ...
    'hair drier', 'toothbrush'};

% 获取所有文件信息
files = dir(fullfile(folderPath, '*.cls')); % 假设文件是 .txt
numCategories = length(categoryNames);     % 类别总数
numFiles = length(files);                  % 文件总数

% 初始化存储结构
fileNames = {files.name};                  % 文件名列表
labels = zeros(numFiles, numCategories);   % 逻辑标签矩阵初始化

% 遍历每个文件，解析类别编号
for i = 1:numFiles
    % 获取文件路径
    filePath = fullfile(folderPath, files(i).name);
    
    % 读取文件内容
    content = fileread(filePath); 
    
    % 提取类别数字（假设用空格分隔）
    classIndices = str2num(content); %#ok<ST2NM>
    
    % 将对应类别置为 1
    labels(i, classIndices + 1) = 1; % MATLAB 索引从 1 开始
end

% 提取图片文件名 (去掉 .txt 后缀，假设图片是 .jpg)
imageFileNames = replace(fileNames, '.cls', '.jpg');

% 转换为表格
labelsTable = array2table(labels, 'VariableNames', categoryNames);
labelsTable = addvars(labelsTable, imageFileNames', 'Before', 1, 'NewVariableNames', 'ImageFile');

% 保存为 CSV 文件
outputCSV = 'image_labels.csv';
writetable(labelsTable, outputCSV);
disp(['标签已保存至文件: ', outputCSV]);

% 验证逻辑：读取 CSV 文件并打印部分内容
disp('验证生成的标签:');
readTable = readtable(outputCSV);
disp(readTable(1:5, :)); % 打印前 5 行
