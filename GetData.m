%Getting data

%Retriving data from Yahoo
c=yahoo;
s = 'aapl'; %Apple Inc.
from = '10/10/2006';
to = '10/10/2015';
rawData = fetch(c,s,'Adj Close',from,to);

rawData = sortrows(rawData); %Sorting rawData by Date in ascending order

%Filling missed dates
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


    