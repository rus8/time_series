%clear all;
%Forecasting with different basis and prediction horizon
%load('filtered.mat'); %Load data from file

Price = PriceLoess';
DeltaPrice = Price(2:end)-Price(1:end-1);

basis = 0.5; %Part of origanal data that would be used for prediction (<1)
[n,DataSize]=size(DeltaPrice);
BasisSize = round(basis*DataSize);
HorizonSize = DataSize - BasisSize;

targetSeries = num2cell(DeltaPrice(1:BasisSize));

% Create a Nonlinear Autoregressive Network
DelayNumber = 100;
feedbackDelays = 1:DelayNumber;
hiddenLayerSize = [10 3 3];
net = narnet(feedbackDelays,hiddenLayerSize);
net.trainFcn = 'trainscg';
%net.layers{1}.transferFcn = 'logsig';
%net.layers{2}.transferFcn = 'logsig';

[inputs,inputStates,layerStates,targets] = ... 
    preparets(net,{},{},targetSeries);

% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
net = train(net,inputs,targets,inputStates,layerStates);

% Test the Network
outputs = net(inputs,inputStates,layerStates);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);
NNAprox = [DeltaPrice(1:DelayNumber) cell2mat(outputs)];

% Closed Loop Network Test
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
[xc,xic,aic,tc] = preparets(netc,{},{},targetSeries);
[yc xcf acf] = netc(xc,xic,aic);
closedLoopPerformance = perform(netc,tc,yc);

% Closed Loop Prediction
xc2 =[targetSeries(end-DelayNumber-1:end) num2cell(NaN(1, HorizonSize))]; %Defines prediction horizon length
[xp xip aip] = preparets(netc,{},{},xc2);
yc2 = netc(xp,xip,aip);
%yc2 = netc(xp, xcf, acf);
DeltaPriceForecast = cell2mat(yc2);
DeltaPriceForecast = smooth(DeltaPriceForecast,round(HorizonSize/4),'rlowess')';

PriceForecast(1) = Price(BasisSize) + DeltaPriceForecast(1);
for i=2:HorizonSize
   PriceForecast(i)= PriceForecast(i-1) + DeltaPriceForecast(1);
end

% plot([NNAprox DeltaPriceForecast])
% hold on;
% plot(DeltaPrice);

plot([Price(1:BasisSize) PriceForecast]);
hold on;
plot(Price);
