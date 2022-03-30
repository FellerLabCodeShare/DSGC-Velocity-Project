function hF = plotCurrents(cur,isPref,isCharge,cType,isNorm,createFig)
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

if nargin < 3 || isempty(isCharge)
    isCharge = false;
end

if nargin < 2 || isempty(isPref)
    isPref = "none";
end

%% Create plot
% Normalize data to max value if specified
if isNorm
    cur = cur ./ max(cur,[],2);
end

% Plot either preferred or null direction
switch isPref
    case "pref"
        cur = cur(:,6:10);
    case "null"% Reverse index for null since speeds are indexed from "most negative"
        cur = cur(:,5:-1:1);
    case "none"
        cur = cur(:,1:5);
    otherwise
        error('Unrecognized isPref input. Use "pref", "null", or "none".');
end

% Compute summary statistics
[nCells,nSpds] = size(cur);

avgCur = nanmean(cur,1);
semCur = nanstd(cur,[],1);
% semCur = nanstd(cur,[],1) / sqrt(nCells); % standard error

% Create figure, or plot ontop of current figure
if createFig
    hF = figure;
else
    hF = gcf;
end

% Plot individual cells
plot(plotVals.pSpds,cur','linewidth',1,'Color',plotVals.getColor(cType,true));
hold on

% Plot error bars
for i = 1:nSpds
    x = repmat(plotVals.pSpds(i),1,2);
    y = [avgCur(i) - semCur(i), avgCur(i) + semCur(i)];
    plot(x,y,'linewidth',2,'Color',plotVals.getColor(cType));
end

% Plot data set average
plot(plotVals.pSpds,avgCur,'o-','MarkerSize',8,'linewidth',2,'Color',plotVals.getColor(cType));

%% Figure labels and axis limits
if isCharge
    ylabel('Total Charge Transfer (pC)');
    %     ylim(plotVals.qLim);
    %     set(gca,'YTick',plotVals.qTick);
else
    ylabel('Currents (pA)');
    %     ylim(plotVals.pLim);
    %     set(gca,'YTick',plotVals.pTick);
end

xlabel('Speed (deg/s)');
xlim(plotVals.xRange);
set(gca,'XTick',plotVals.xTicks);
set(gca,'Box','off');

if isNorm
    ylim([0 1]);
    set(gca,'YTick',-1:.2:1);
end


end