function hF = plotSpikes(spikes,isPref,isHz,cType,isNorm,createFig)
% Function to plot peak currents / total charge transfer data

if nargin < 6 || isempty(createFig)
    createFig = true;
end

if nargin < 5 || isempty(isNorm)
    isNorm = false;
end

if nargin < 4 || isempty(cType)
    cType = 'default';
end

if nargin < 3 || isempty(isHz)
    isHz = false;
end

if nargin < 2 || isempty(isPref)
    isPref = true;
end

[nCells,nVeloc] = size(spikes);
nSpds = nVeloc / 2;

% Check if gratings or bars based on stim numbers
if nVeloc == 14
    pIndx = 8:14; %pref dir indices
    nIndx = 7:-1:1; %null dir indices
    plotSpds = plotVals.pSpdsGrates;
elseif nVeloc == 10
    pIndx = 6:10; %pref dir indices
    nIndx = 5:-1:1; %null dir indices
    plotSpds = plotVals.pSpdsBars;
else
    error('Unrecognized number of stimulus conditions.')
end
    

%% Create plot

% Normalize data to max value if specified
if isNorm
    spikes = spikes ./ max(spikes,[],2);
end

% Plot either preferred or null direction
if isPref
    spikes = spikes(:,pIndx);
else
    % Reverse index for null since speeds are indexed from "most negative"
    spikes = spikes(:,nIndx);
end

% Compute summary statistics
avgDSI = nanmean(spikes,1);
semDSI = nanstd(spikes,[],1) / sqrt(nCells);

% Create figure, or plot ontop of current figure
if createFig
    hF = figure;
else
    hF = gcf;
    hold on
end

% Plot individual cells
plot(plotSpds,spikes','linewidth',1,'Color',plotVals.getColor(cType,true));
hold on

% Plot error bars
for i = 1:nSpds
    x = repmat(plotSpds(i),1,2);
    y = [avgDSI(i) - semDSI(i), avgDSI(i) + semDSI(i)];
    plot(x,y,'linewidth',2,'Color',plotVals.getColor(cType));
end

% Plot data set average
plot(plotSpds,avgDSI,'o-','MarkerSize',8,'linewidth',2,'Color',plotVals.getColor(cType));

%% Figure labels and axis limits
if isHz
    ylabel('Peak Firing Rate (Hz)');
    %     ylim(plotVals.hzLim);
    %     set(gca,'YTick',plotVals.hzTick);
else
    ylabel('Spike Count');
    %     ylim(plotVals.spLim);
    %     set(gca,'YTick',plotVals.spTick);
end

xlabel('Speed (deg/s)');
xlim(plotVals.xRange);
set(gca,'XTick',plotVals.xTicks);
set(gca,'Box','off');

if isNorm
    ylim([0 1]);
    set(gca,'YTick',-1:.2:1);
    if isHz
        ylabel('Normalized Firing Rate');
    else
        ylabel('Normalized Spike Count');
    end
end


end