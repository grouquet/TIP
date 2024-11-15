%assess model performance
thresholdValue = 0.22;
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

%Plot the results
figure
tiledlayout("flow")
for i = 1:4
nexttile
plot(thresholdRange,metrics(i,:),"-*")
title(metricsName(i))
xlabel("Threshold")
ylabel("Score")
end


%Predict Using New Data with the images of test-resized, modified the names
%of variables
imageNames = [".\images\test-resized\000000000139.jpg" ".\images\test-resized\000000005037.jpg"];
figure
tiledlayout(1,2)
images_predict = [];
labels_predict = [];
scores_predict =[];

for i = 1:2
    img = imread(imageNames(i));
    img = imresize(img,inputSize(1:2));
    images_predict{i} = img;

    scoresImg = predict(trainedNet,single(img))';
    YPred =  categoriesTrain(scoresImg >= thresholdValue);

    nexttile
    imshow(img)
    title(YPred)

    labels_predict{i} = YPred;
    scores_predict{i} = scoresImg;
end

%Investigate Network Predictions
%imageIdx = 1;
%testImage = images{imageIdx};
%tbl = table(categoriesTrain',scores{imageIdx},VariableNames=["Class", "Score"]);
%disp(tbl)




























































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