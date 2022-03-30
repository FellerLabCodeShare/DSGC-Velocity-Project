function [ctSort,ctDSI,hzSort,hzDSI,ctPD,hzPD] = processRDKs(dTable,indx,rawData,summaryData,offWindow)
%Function to process the data indexed by current clamp data table inputs

%% Check inputs
if nargin < 5 || isempty(offWindow)
    offWindow = false; % extraneous for now, save to potentially include ds bars at a later date
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
[d,stimDirs,spCts,spTms] = fetchData(dTable,indx);
tWidth = size(d,1) * 1e-4;

% Estimate instantaneous frequency in desginated window
[peakHz,ifr] = estInstFreq(spTms,tWidth);

% Sort outputs by stim speed
ctSort = quickSort(spCts,stimDirs);
hzSort = quickSort(peakHz,stimDirs);

%% Plot data if requested

if rawData % show raw traces sorted by stim speed
    plotDirTraces(d,stimDirs,1,10000);
    plotDirTraces(ifr,stimDirs,1,10000);
    figure;
    plot(d,'k');
end

if summaryData % show summary traces; don't normalize PDs in this case
    dirTuning(ctSort,stimDirs);
    dirTuning(hzSort,stimDirs);
else
    [~,ctPD,ctDSI] = dirTuning(ctSort,stimDirs,1);
    [~,hzPD,hzDSI] = dirTuning(hzSort,stimDirs,1);
    ctSort = normalizePDs(ctSort,ctPD);
    hzSort = normalizePDs(hzSort,hzPD);
end


end

function ySort = normalizePDs(xSort,xPD)
% Subroutine to normalize ctSort / hzSort matrices to 90 degrees, for
% relative comparison between cells tuned in different directions.

yPD = xPD - 90; % get deviation from 90 degrees
if (yPD < 0), yPD = yPD + 360; end

% Convert PD into a ctSort index
nDirs = 8; % if this assumption is incorrect then there are far bigger issues
incDirs = 360 / nDirs; % direction increments
prefIndx = -round(yPD / incDirs);

% Circularly permute ctSort to best align the PD w/ 90 degrees
ySort = circshift(xSort,prefIndx,1);


end