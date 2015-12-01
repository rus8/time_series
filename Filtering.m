%Data filtering
load('aapl.mat'); %Load data from file
Dates = Data(:,1);


figure('NumberTitle', 'off', 'Name', 'Filtering with "smooth" function from Curve Fitting Toolbox')

span = 150;

%Moving average filtering
method = 'moving';
PriceMA = smooth(Data(:,2),span,method);
ax1 = subplot(3,2,1);
plot(ax1,Dates,Data(:,2),Dates,PriceMA)
title(['Moving average filtering with span = ', num2str(span)])
legend('Original','Filtered','Location','northwest')

%Savitzky-Golay filter
method = 'sgolay';
degree = 3;
PriceSgolay = smooth(Data(:,2),span,method,degree);
ax2 = subplot(3,2,2);
plot(ax2,Dates,Data(:,2),Dates,PriceSgolay)
title(['Savitzky-Golay filter with span = ', num2str(span),' and degree = ', num2str(degree)])
legend('Original','Filtered','Location','northwest')

%Local regression using weighted linear least squares and a 1st degree polynomial model
method = 'lowess';
PriceLowess = smooth(Data(:,2),span,method);
ax3 = subplot(3,2,3);
plot(ax3,Dates,Data(:,2),Dates,PriceLowess)
title(['Local regression (1st degree polynomial model) with span = ',  num2str(span)])
legend('Original','Filtered','Location','northwest')

%Robust local regression using weighted linear least squares and a 1st degree polynomial model
method = 'rlowess';
PriceRlowess = smooth(Data(:,2),span,method);
ax4 = subplot(3,2,4);
plot(ax4,Dates,Data(:,2),Dates,PriceRlowess)
title(['Robust local regression (1st degree polynomial model) with span = ',  num2str(span)])
legend('Original','Filtered','Location','northwest')

%Local regression using weighted linear least squares and a 2nd degree polynomial model
method = 'loess';
PriceLoess = smooth(Data(:,2),span,method);
ax5 = subplot(3,2,5);
plot(ax5,Dates,Data(:,2),Dates,PriceLoess)
title(['Local regression (2nd degree polynomial model) with span = ',  num2str(span)])
legend('Original','Filtered','Location','northwest')

%Robust local regression using weighted linear least squares and a 2nd degree polynomial model
method = 'rloess';
PriceRloess = smooth(Data(:,2),span,method);
ax6 = subplot(3,2,6);
plot(ax6,Dates,Data(:,2),Dates,PriceRloess)
title(['Robust local regression (2nd degree polynomial model) with span = ',  num2str(span)])
legend('Original','Filtered','Location','northwest')

% Function "smoothts" has bad perfomance in our case
%
% figure('NumberTitle', 'off', 'Name', 'Filtering with "smoothts" function from Financial Toolbox')
% 
% wsize = 9; %Window size
% stdev = 2;%0.65; %Standart deviation for Gaussian filter
% 
% %Box smoothing method
% method = 'b';
% FilteredData = smoothts(Data(:,2),method,wsize);
% ax7 = subplot(3,1,1);
% plot(ax7,Dates,Data(:,2),Dates,FilteredData)
% title(['Box smoothing method with window size = ',  num2str(wsize)])
% legend('Original','Filtered','Location','northwest')
% 
% %Gaussian smoothing method
% method = 'g';
% FilteredData = smoothts(Data(:,2),method,wsize,stdev);
% ax8 = subplot(3,1,2);
% plot(ax8,Dates,Data(:,2),Dates,FilteredData)
% title(['Gaussian smoothing method with window size = ',  num2str(wsize), ' and standart deviation = ', num2str(stdev)])
% legend('Original','Filtered','Location','northwest')
% 
% %Exponential smoothing method
% method = 'e';
% FilteredData = smoothts(Data(:,2),method,wsize);
% ax9 = subplot(3,1,3);
% plot(ax9,Dates,Data(:,2),Dates,FilteredData)
% title(['Exponential smoothing method with window size = ',  num2str(wsize)])
% legend('Original','Filtered','Location','northwest')
