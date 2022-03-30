function hF = plotAvg(yData,cType)
% Function to plot velocity tuning data, with velocity average 

if nargin < 2 || isempty(cType) % Cell type, for plotting purposes
    cType = "default";
end

%% Prep data for fitting / plotting
xData = plotVals.pSpdsBars;
avgY = nanmean(yData,1);
semY = nanstd(yData,[],1) / sqrt(size(yData,1));

% Compute fit values for plotting
if cType == "ON"
    xPlot = [4 20];
    yPlot = [mean(avgY(1:3)) mean(avgY(1:3))];
else
    xPlot = [plotVals.xRange(1) plotVals.xRange(2)];
    yPlot = [mean(avgY) mean(avgY)];
end

%% Create figure
hF = figure;
plot(xPlot,yPlot,'linewidth',2,'Color',plotVals.getColor(cType))
hold on

% Plot error bars
for i = 1:size(xData,2)
    xBar = repmat(xData(i),1,2);
    yBar = [avgY(i) - semY(i), avgY(i) + semY(i)];
    plot(xBar,yBar,'linewidth',2,'Color',plotVals.getColor(cType));
end

% Plot data set average
plot(xData,avgY,'o','MarkerSize',6,'linewidth',2,'Color',...
    plotVals.getColor(cType),'MarkerFaceColor',plotVals.getColor(cType));

% Set axis parameters
xlim(plotVals.xRange);
ylim([0 1])
set(gca,'XTick',plotVals.xTicks);
set(gca,'YTick',-1:.2:1);
set(gca,'Box','off');
xlabel('Speed (deg/s)');
ylabel('DS Index');


end