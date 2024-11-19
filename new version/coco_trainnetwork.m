%add a sigmoid layer
newLayers = [
    fullyConnectedLayer(numLabels, 'Name', 'new_fc', 'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10)
    sigmoidLayer('Name', 'sigmoid')
];

%delete the softmax layer of the original network and connect the sigmoid
%layer to the network
changenetwork = true;
if changenetwork
    net = removeLayers(net, 'fc1000');
    net = removeLayers(net, 'fc1000_softmax');
    net = addLayers(net, newLayers);
    net = connectLayers(net, 'avg_pool', 'new_fc');
end
%view the actual network 
analyzeNetwork(net);

%reset GPU
gpuDevice(1)

%trainning options
options = trainingOptions("sgdm", ...
    InitialLearnRate=0.01, ...
    LearnRateSchedule='piecewise', ...
    LearnRateDropFactor=0.1, ... % 每次下降的因子
    LearnRateDropPeriod=5, ... % 每隔多少个周期调整一次
    MiniBatchSize=32, ...
    MaxEpochs=15, ...
    Verbose= false, ...
    ValidationData=dataVal, ...
    ValidationFrequency=40, ...
    ValidationPatience=Inf, ...
    Metrics="accuracy", ...
    Shuffle='every-epoch', ...
    Plots="training-progress");

%train network 
doTraining = true; %true:train    false: no train

if doTraining
    trainedNet = trainnet(dataTrain,net,"binary-crossentropy",options);
else
    filename = matlab.internal.examples.downloadSupportFile("nnet", ...
        "data/multilabelImageClassificationNetwork.zip");

    filepath = fileparts(filename);
    dataFolder = fullfile(filepath,"multilabelImageClassificationNetwork");
    unzip(filename,dataFolder);
    load(fullfile(dataFolder,"multilabelImageClassificationNetwork.mat"));
    trainedNet = dag2dlnetwork(trainedNet);
end

disp("trainning success");

% 指定模型保存的文件名
modelName = 'trainedMultiLabelresnet50.mat';

% 保存模型
save(modelName, 'net');
disp("saving success");

