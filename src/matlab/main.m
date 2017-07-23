% Main script

% Reset memory
clear

% Initialize RNG to same state
rng('default');

% Load parameter file
params

% Load AIA data
aia = AIA('txt', aia_txt_file);

% Load training data from AIA data
% train = aia.tsst.xy_cell_t(1,1,1);


% clear aia
% 
% train = train(randperm(numel(train)));
% 
% figure(1);
% clf
% for i = 1:20
%     subplot(4,5,i);
%     imshow(train{i}, [0, 1]);
% end
% 
% hiddenSize1 = 500;
% 
% autoenc1 = trainAutoencoder(train,hiddenSize1, ...
%     'MaxEpochs',1000, ...
%     'L2WeightRegularization',0.004, ...
%     'SparsityRegularization',4, ...
%     'SparsityProportion',0.05, ...
%     'ScaleData', false, ...
%     'useGPU', true);
% 
% figure(2)
% clf
% plotWeights(autoenc1);
% 
% figure(3)
% clf
% for i = 1:20
%     subplot(4,5,i);
%     imshow(predict(autoenc1, train{i}), [0, 1]);
% end

