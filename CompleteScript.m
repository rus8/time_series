clear all;

% Retriving data from Yahoo
c=yahoo;
s = 'aapl'; %Apple Inc. (stock name of company)
from = '10/10/2006';
to = '10/10/2015';
rawData = fetch(c,s,'Adj Close',from,to);

rawData = sortrows(rawData); %Sorting rawData by Date in ascending order

% Filling missed dates with linear approximation (weekends, holidays)
[n,m]=size(rawData);
i=1;
Data(i,:) = rawData(i,:);
while (i<n)
    i = i+1;
    if (rawData(i,1) - rawData(i-1,1) > 1)
        DaySpace = rawData(i,1) - rawData(i-1,1) - 1;
        DivCoef = rawData(i,1) - rawData(i-1,1);
        for j=1:DaySpace
            Data = [Data; (rawData(i-1,1)+j) (rawData(i-1,2)+j*(rawData(i,2)-rawData(i-1,2))/DivCoef)];
        end
    end
    Data = [Data; rawData(i,:)];
end

% Filtering data
method = 'rloess'; %Possible methods: "moving", "lowess", "rlowess", "loess", "rloess"
span = 500; %Defines how many neighboring data samples are used to filter each sample
Price = smooth(Data(:,2),span,method);
% Special case for "sgolay" method (include "degree" parameter)
% degree = 3;
% Price = smooth(Data(:,2),span,'sgolay',degree);
figure('NumberTitle', 'off', 'Name', 'Filtering with "smooth" function');
plot(Data(:,1),Data(:,2),Data(:,1),Price);
legend('Original data','Filtered data','Location','northwest');

% Forecasting with Neural Network
DeltaPrice = (Price(2:end)-Price(1:end-1))';
basis = 0.85; %Part of origanal data that would be used for prediction (<1)
[n,DataSize]=size(DeltaPrice);
BasisSize = round(basis*DataSize); %Number of samples used for prediction
HorizonSize = DataSize - BasisSize; %Number of samples that are predicted

% Create a Nonlinear Autoregressive Network
DelayNumber = 100;
feedbackDelays = 1:DelayNumber;
hiddenLayerSize = [10 3 3];
net = narnet(feedbackDelays,hiddenLayerSize);
net.trainFcn = 'trainscg';
targetSeries = num2cell(DeltaPrice(1:BasisSize));
[inputs,inputStates,layerStates,targets] = preparets(net,{},{},targetSeries);

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
%[xc,xic,aic,tc] = preparets(netc,{},{},targetSeries);
%[yc xcf acf] = netc(xc,xic,aic);
%closedLoopPerformance = perform(netc,tc,yc);

% Prediction (using closed loop network)
xc2 =[targetSeries(end-DelayNumber-1:end) num2cell(NaN(1, HorizonSize))];
[xp xip aip] = preparets(netc,{},{},xc2);
yc2 = netc(xp,xip,aip);
DeltaPriceForecast = cell2mat(yc2);
DeltaPriceForecast = smooth(DeltaPriceForecast,round(HorizonSize/8),'rlowess')';
PriceForecast(1) = Price(BasisSize) + DeltaPriceForecast(1);
for i=2:HorizonSize
   PriceForecast(i) = PriceForecast(i-1) + DeltaPriceForecast(i);
end
PriceBasis(1) = Price(1);
PriceBasis(2) = Price(1) + NNAprox(1);
for i=2:BasisSize
    PriceBasis(i+1) = PriceBasis(i) + NNAprox(i);
end;

figure('NumberTitle', 'off', 'Name', 'Data prediction');
Dates = Data(:,1);
plot(Data(:,1),Data(:,2),Dates(1:BasisSize+1),PriceBasis)
hold on;
plot(Dates(end-HorizonSize+1:end),PriceForecast,'Color','g');
legend('Original data','Approximated Data','Forecasted data','Location','northwest');

