function hF = plotDSI(dsi,cType,createFig)
% Function to plot DSI data

if nargin < 3 || isempty(createFig)
    createFig = true;
end

if nargin < 2 || isempty(cType)
    cType = 'default';
end

% Compute summary statistics
[nCells,nSpds] = size(dsi);

avgDSI = nanmean(dsi,1);
semDSI = nanstd(dsi,[],1) / sqrt(nCells);

% Create figure, or plot ontop of current figure
if createFig
    hF = figure;
else
    hF = gcf;
    hold on
end

% Plot individual cells
plot(plotVals.pSpds,dsi','linewidth',1,'Color',plotVals.getColor(cType,true));
hold on

% Plot error bars
for i = 1:nSpds
    x = repmat(plotVals.pSpds(i),1,2);
    y = [avgDSI(i) - semDSI(i), avgDSI(i) + semDSI(i)];
    plot(x,y,'linewidth',2,'Color',plotVals.getColor(cType));
end

% Plot data set average
plot(plotVals.pSpds,avgDSI,'o-','MarkerSize',8,'linewidth',2,'Color',plotVals.getColor(cType));

% Figure labels and axis limits
xlabel('Speed (deg/s)');
ylabel('DSI');
ylim([0 1]);
xlim(plotVals.xRange);

set(gca,'YTick',-1:.2:1);
set(gca,'XTick',plotVals.xTicks);
set(gca,'Box','off');

end