%Data filtering
load('aapl.mat'); %Load data from file
Dates = Data(:,1);

span = 150;

%Moving average filtering
method = 'moving';
PriceMA = smooth(Data(:,2),span,method);
plot(Dates,Data(:,2),Dates,PriceMA)

hold on;

%Savitzky-Golay filter
method = 'sgolay';
degree = 3;
PriceSgolay = smooth(Data(:,2),span,method,degree);
plot(Dates,Data(:,2),Dates,PriceSgolay)

%Local regression using weighted linear least squares and a 1st degree polynomial model
method = 'lowess';
PriceLowess = smooth(Data(:,2),span,method);
plot(Dates,Data(:,2),Dates,PriceLowess)

%Robust local regression using weighted linear least squares and a 1st degree polynomial model
method = 'rlowess';
PriceRlowess = smooth(Data(:,2),span,method);
plot(Dates,Data(:,2),Dates,PriceRlowess)

%Local regression using weighted linear least squares and a 2nd degree polynomial model
method = 'loess';
PriceLoess = smooth(Data(:,2),span,method);
plot(Dates,Data(:,2),Dates,PriceLoess)

%Robust local regression using weighted linear least squares and a 2nd degree polynomial model
method = 'rloess';
PriceRloess = smooth(Data(:,2),span,method);
plot(Dates,Data(:,2),Dates,PriceRloess)