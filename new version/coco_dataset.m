clc; clear; close all;
% 加载图像路径和标签
dataTbl = readtable('image_labels.csv',TextType="String"); % 确保路径正确，且CSV中列名为'filename'和'label1', 'label2', ..., 'labelN'
imageFolder = '.\images\train-resized'; % 存放图像的文件夹路径

% 创建图像数据存储
imds = imageDatastore(fullfile(imageFolder, dataTbl.ImageFile), ...
    'ReadFcn', @(x)imresize(imread(x), inputSize(1:2)));
% 准备标签数据
numLabels = width(dataTbl) - 1; % 假设第一列是文件名，剩下的列是标签
labels = table2array(dataTbl(:, 2:end)); % 转换为数组

%le reseau resnet50 avec 80 classes
numClasses = 80;
net = imagePretrainedNetwork("resnet50",NumClasses=numClasses);

inputSize = net.Layers(1).InputSize;

% Geler uniquement les couches compatibles avec le facteur d'apprentissage
netlayers=net.Layers;
for i = 1:length(netlayers)
    % Vérifiez si la couche supporte 'WeightLearnRateFactor'
    if isprop(netlayers(i), 'WeightLearnRateFactor') && isprop(netlayers(i), 'BiasLearnRateFactor')
        % Geler les couches en définissant les facteurs à 0
        netlayers(i).WeightLearnRateFactor = 0;
        netlayers(i).BiasLearnRateFactor = 0;
    end
end

%les 80 categories
categoriesTrain = ["person" "bicycle" "car" "motorcycle" "airplane" "bus" "train" "truck" "boat" "traffic light" "fire hydrant" "stop sign" "parking meter" "bench" "bird" "cat" "dog" "horse" "sheep" "cow" "elephant" "bear" "zebra" "giraffe" "backpack" "umbrella" "handbag" "tie" "suitcase" "frisbee" "skis" "snowboard" "sports ball" "kite" "baseball bat" "baseball glove" "skateboard" "surfboard" "tennis racket" "bottle" "wine glass" "cup" "fork" "knife" "spoon" "bowl" "banana" "apple" "sandwich" "orange" "broccoli" "carrot" "hot dog" "pizza" "donut" "cake" "chair" "couch" "potted plant" "bed" "dining table" "toilet" "tv" "laptop" "mouse" "remote" "keyboard" "cell phone" "microwave" "oven" "toaster" "sink" "refrigerator" "book" "clock" "vase" "scissors" "teddy bear" "hair drier" "toothbrush"];

%toutes les images et tous les labels
numUniqueImages=65000;
dataTable = table(Size=[numUniqueImages 2], ...
    VariableTypes=["string" "double"], ...
    VariableNames=["File_Location" "Labels"]);

dataTable.File_Location = imds.Files;
dataTable.Labels = labels;

%dedier a augmentedImageDatastore
imageAugmenter = imageDataAugmenter( ...
    RandRotation=[-45,45], ...
    RandXReflection=true);

%les images et les labels pour entrainer
dataTableTrain = dataTable(1:52000, :);
dataTrain = augmentedImageDatastore(inputSize(1:2),dataTableTrain, ...
        ColorPreprocessing="gray2rgb", ...
        DataAugmentation=imageAugmenter);

encodedLabelTrain = dataTableTrain.Labels;
numObservations = dataTrain.NumObservations;

%les images et les labels pour tester
dataTableTest = dataTable(52001:65000, :);
dataVal = augmentedImageDatastore(inputSize(1:2),dataTableTest, ...
        ColorPreprocessing="gray2rgb", ...
        DataAugmentation=imageAugmenter);

encodedLabelVal = dataTableTest.Labels;
numObservationsPerClass = sum(encodedLabelTrain,1);

%View the number of labels for each class
figure;
bar(numObservationsPerClass);
ylabel('Number of Observations');
xticks(1:length(categoriesTrain)); % 设置每个条目一个标签
xticklabels(categoriesTrain);
xtickangle(45); % 可选，旋转标签以更好地展示

%View the average number of labels per image
numLabelsPerObservation = sum(encodedLabelTrain,2);
mean(numLabelsPerObservation)

figure
histogram(numLabelsPerObservation)
hold on
ylabel("Number of Observations")
xlabel("Number of Labels")
hold off

%view the network of resnet50
%analyzeNetwork(net);

%step success
disp("dataset success");




