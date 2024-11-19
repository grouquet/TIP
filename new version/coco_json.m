imageTestFolder = '.\images\test-resized';
categoriesTrain = ["person" "bicycle" "car" "motorcycle" "airplane" "bus" "train" "truck" "boat" "traffic light" "fire hydrant" "stop sign" "parking meter" "bench" "bird" "cat" "dog" "horse" "sheep" "cow" "elephant" "bear" "zebra" "giraffe" "backpack" "umbrella" "handbag" "tie" "suitcase" "frisbee" "skis" "snowboard" "sports ball" "kite" "baseball bat" "baseball glove" "skateboard" "surfboard" "tennis racket" "bottle" "wine glass" "cup" "fork" "knife" "spoon" "bowl" "banana" "apple" "sandwich" "orange" "broccoli" "carrot" "hot dog" "pizza" "donut" "cake" "chair" "couch" "potted plant" "bed" "dining table" "toilet" "tv" "laptop" "mouse" "remote" "keyboard" "cell phone" "microwave" "oven" "toaster" "sink" "refrigerator" "book" "clock" "vase" "scissors" "teddy bear" "hair drier" "toothbrush"];

% create a table contains the path of test iamges 
filePattern = fullfile(imageTestFolder, '*.jpg'); 
jpgFiles = dir(filePattern);
imageTestFiles = jpgFiles;
numTestFiles = length(imageTestFiles);
fileTestPaths = strings(numTestFiles, 1);

for k = 1:numTestFiles
    fileTestPaths(k) = fullfile(imageTestFolder, imageTestFiles(k).name);
end

imageTestTable = table(fileTestPaths, 'VariableNames', {'ImageTestPaths'});
disp("imageTestFiles successfully created");


%assess model performance
thresholdValue = 0.3;
scores = minibatchpredict(trainedNet,dataVal);
YPred = double(scores >= thresholdValue);

%F1 score
FScore = F1Score(encodedLabelVal,YPred);
%disp("**********************************************************");
%disp("F1 score:");
%disp(FScore);

%Jaccard Index
jaccardScore = jaccardIndex(encodedLabelVal,YPred);
%disp("**********************************************************");
%disp("Jaccard Index:");
%disp(jaccardScore);

%Confusion Matrix
figure
tiledlayout("flow")
for i = 1:numClasses
    nexttile
    confusionchart(encodedLabelVal(:,i),YPred(:,i));
    title(categoriesTrain(i))
end

%Investigate Threshold Value
% 调查阈值如何影响模型评估指标。计算不同阈值的 F1 分数和 Jaccard 指数。此外，使用支持函数 performanceMetrics 计算不同阈值的精度和召回率。
thresholdRange = 0.1:0.1:0.9;

metricsName = ["F1-score","Jaccard Index","Precision","Recall"];
metrics = zeros(4,length(thresholdRange));

for i = 1:length(thresholdRange)
  
    YPred = double(scores >= thresholdRange(i));

    metrics(1,i) = F1Score(encodedLabelVal,YPred);
    metrics(2,i) = jaccardIndex(encodedLabelVal,YPred);

    [precision, recall] = performanceMetrics(encodedLabelVal,YPred);
    metrics(3,i) = precision;
    metrics(4,i) = recall;
end

%Predict Using New Data with the images of test-resized, modified the names
%of variables
imageNames = imageTestTable.ImageTestPaths;
%imageNames = [".\images\test-resized\000000042889.jpg" ".\images\test-resized\000000000139.jpg"];
%figure
%tiledlayout(1,2)
images_predict = [];
labels_predict = [];
scores_predict =[];
numTestImages=4952;
dataTestTable = table(Size=[0 2], ...
    VariableTypes=["string" "cell"], ...
    VariableNames=["Filename" "Labels"]);

for i = 1:numTestImages
    img = imread(string(imageNames(i,1)));
    %img = imread(imageNames(i));
    img = imresize(img,inputSize(1:2));
    
    if size(img, 3) == 1
    % 将灰度图像复制到三个通道
        img = repmat(img, [1, 1, 3]);
    end
    
    images_predict{i} = img;

    scoresImg = predict(trainedNet,single(img))';
    YPred =  categoriesTrain(scoresImg >= thresholdValue);

    %nexttile
    %imshow(img)
    %title(YPred)

    labels_predict{i} = YPred;
    scores_predict{i} = scoresImg;

    % 定义文件路径
    fullTestFilePath = imageNames(i,1);
    %fullTestFilePath = imageNames(i);
    % 使用 fileparts 分离路径、文件名和扩展名
    [~, testFilename, ~] = fileparts(fullTestFilePath);
    
    disp(imageTestTable(i,1));
    

    strtestFilename = string(testFilename);
    strlabels_predict = labels_predict{i};
    disp(strtestFilename);
    disp(YPred);
    % 预分配一个与 YPred 同样大小的字符串数组
    YPredIndices = strings(size(YPred));

    % 循环转换每个类名为其索引
    for k = 1:length(YPred)
        index = find(categoriesTrain == YPred(k)) - 1;  % 找到索引并转换为从0开始
        YPredIndices(k) = num2str(index);  % 转换为字符串类型的数字
    end

    newRow = table({strtestFilename}, {YPredIndices}, 'VariableNames', ["Filename" "Labels"]);
    dataTestTable = [dataTestTable; newRow];
end

% 将数据编码为 JSON 格式
jsonStr = jsonencode(dataTestTable, 'PrettyPrint', true);

% 指定保存 JSON 的文件名
filename = 'output.json';

% 打开文件并写入 JSON 数据
fid = fopen(filename, 'w');
fprintf(fid, '%s', jsonStr);
fclose(fid);


disp('JSON file has been written.');






































%la fonction pour calculer F1 score
function score = F1Score(T,Y)
% TP: True Positive
% FP: False Positive
% TN: True Negative
% FN: False Negative

TP = sum(T .* Y,"all");
FP = sum(Y,"all")-TP;

TN = sum(~T .* ~Y,"all");
FN = sum(~Y,"all")-TN;

score = TP/(TP + 0.5*(FP+FN));
end

%la fonction pour calculer jaccardIndex
function score = jaccardIndex(T,Y)

intersection = sum((T.*Y));

union = T+Y;
union(union < 0) = 0;
union(union > 1) = 1;
union = sum(union);

% Ensure the accuracy is 1 for instances where a sample does not belong to any class
% and the prediction is correct. For example, T = [0 0 0 0] and Y = [0 0 0 0].
noClassIdx = union == 0;
intersection(noClassIdx) = 1;
union(noClassIdx) = 1;

score = mean(intersection./union);
end

%la fonction pour calculer precision and recall
function [precision, recall] = performanceMetrics(T,Y)
% TP: True Positive
% FP: False Positive
% TN: True Negative
% FN: False Negative

TP = sum(T .* Y,"all");
FP = sum(Y,"all")-TP;

TN = sum(~T .* ~Y,"all");
FN = sum(~Y,"all")-TN;

precision = TP/(TP+FP);
recall = TP/(TP+FN);
end