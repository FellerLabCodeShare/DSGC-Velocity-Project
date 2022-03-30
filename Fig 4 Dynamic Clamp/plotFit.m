function hF = plotFit(yData,cType)
% Function to plot difference of gaussians fit of velocity tuning data

if nargin < 2 || isempty(cType) % Cell type, for plotting purposes
    cType = "default";
end

%% Prep data for fitting / plotting
xData = plotVals.pSpdsBars;
avgY = nanmean(yData,1);
semY = nanstd(yData,[],1) / sqrt(size(yData,1));

% Fit to difference of gaussians
fitFunc = @(b,x) b(1) * b(3) * sqrt(pi) / 2 * erf(x / b(3)) ...
                 - b(2) * b(4) * sqrt(pi) / 2 * erf(x / b(4));

% set initial conditions for fitting
beta0 = [.5 .5 10 25]; % initial conditions for fit % for ON


% Fit to function
beta = nlinfit(xData,avgY,fitFunc,beta0);
% beta = lsqcurvefit(fitFunc,beta0,xData,avgY,[0 0 0 0],[1 1 60 60]);

% Compute fit values for plotting
xPlot = plotVals.xRange(1):plotVals.xRange(2);
yPlot = fitFunc(beta,xPlot);

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
ylabel('Norm. Firing Rate');


end