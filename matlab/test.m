% Load the training data into memory
[xTrainImages,tTrain] = digitTrainCellArrayData;

figure(1);
clf
for i = 1:20
    subplot(4,5,i);
    imshow(xTrainImages{i});
end

% for i = 1:5000
%    xTrainImages{i} = single(xTrainImages{i});
% end

% Display some of the training images


rng('default');

hiddenSize1 = 400;

autoenc1 = trainAutoencoder(xTrainImages,hiddenSize1, ...
    'MaxEpochs',100, ...
    'L2WeightRegularization',0.004, ...
    'SparsityRegularization',4, ...
    'SparsityProportion',0.15, ...
    'ScaleData', false, ...
    'useGPU', false);

figure(2)
plotWeights(autoenc1);

figure(3)
clf
for i = 1:20
    subplot(4,5,i);
    imshow(predict(autoenc1, xTrainImages{i}));
end