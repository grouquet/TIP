%add a sigmoid layer
newLayers = [
    sigmoidLayer('Name', 'sigmoid')
];

%delete the softmax layer of the original network and connect the sigmoid
%layer to the network
net = removeLayers(net, 'fc1000_softmax');
net = addLayers(net, newLayers);
net = connectLayers(net, 'fc1000', 'sigmoid');

%view the actual network 
analyzeNetwork(net);

%reset GPU
gpuDevice(1)

%trainning options
options = trainingOptions("sgdm", ...
    InitialLearnRate=0.001, ...
    MiniBatchSize=32, ...
    MaxEpochs=1, ...
    Verbose= false, ...
    ValidationData=dataVal, ...
    ValidationFrequency=100, ...
    ValidationPatience=5, ...
    Metrics="accuracy", ...
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


