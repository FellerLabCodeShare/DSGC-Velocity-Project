function [ctSort,ctDSI,hzSort,hzDSI] = processData(dTable,indx,rawData,summaryData,offWindow)
%Function to process the data indexed by current clamp data table inputs

%% Check inputs
if nargin < 5 || isempty(offWindow)
    offWindow = false;
end

if nargin < 4 || isempty(summaryData)
    summaryData = false;
end

if nargin < 3 || isempty(rawData)
    rawData = false;
end

if nargin < 2 || isempty(indx)
    indx = 1;
end

%% Process data

% Load recording and stim data
[d,stimSpds,spCts,spTms] = fetchData(dTable,indx);

% Restrict analysis to designated window if bar data; ignore if gratings
if dTable.Stim(indx) == "adj bars spds"
    % Check analysis window based on cell type
    tmWindow = cSpdsTimes.CheckWindowTimes(dTable,indx,offWindow);
    
    % Count spikes within specified time window
    [spCts,spTms] = parseSpikeWindow(spTms,tmWindow);
else
    tmWindow = [0 size(d,1)*1e-4];
end

% Estimate instantaneous frequency in desginated window
[peakHz,ifr] = estInstFreq(spTms,tmWindow(2) - tmWindow(1));

% Sort outputs by stim speed
ctSort = quickSort(spCts,stimSpds);
hzSort = quickSort(peakHz,stimSpds);

%% Plot data if requested

if rawData % show raw traces sorted by stim speed
    tmIndx = (1+tmWindow(1)*1e4):(tmWindow(2)*1e4);
    plotDirTraces(d,stimSpds,1,10000);
    plotDirTraces(ifr,stimSpds,1,10000);
    figure;
    plot(d,'k');
    hold on
    plot(tmIndx,d(tmIndx,:),'g');
end

if summaryData
    velocityTuning(ctSort,stimSpds);
    velocityTuning(hzSort,stimSpds);
else
    [~,ctDSI] = velocityTuning(ctSort,stimSpds,1);
    [~,hzDSI] = velocityTuning(hzSort,stimSpds,1);
end
end