function hF = plotSpdIndx(ooSpd,onSpd,createFig)
%function to plot side by side scalar values with some jitter

if nargin < 3 || isempty(createFig)
    createFig = true;
end

% Jitter width
jitterVar = .05;

%Get parameters
nOO = numel(ooSpd);
nON = numel(onSpd);
avgOO = nanmean(ooSpd);
avgON = nanmean(onSpd);

% Create jitter
ooPlot = ones(1,nOO) + randn(1,nOO)*jitterVar;
onPlot = 1.5*ones(1,nON) + randn(1,nON)*jitterVar;

%% Plot

%Construct new figure if flagged
if createFig
    hF = figure;
else
    hF = gcf;
    hold on;
end

%ooSpd vals and mean
plot(ooPlot,ooSpd,'o','linewidth',1,'Color',plotVals.defaultColor);
hold on
plot([.9 1.1],[avgOO avgOO],'-','linewidth',2,'Color',plotVals.defaultColor)

%onSpd vals and mean
plot(onPlot,onSpd,'o','linewidth',1,'Color',plotVals.onColor);
plot([1.4 1.6],[avgON avgON],'-','linewidth',2,'Color',plotVals.onColor)

xlim([.7 1.8]);
ylim([-1 1]);

set(gca,'XTick',[1 1.5]);
set(gca,'XTickLabel',{"ONOFF","ON"},'FontSize',12);
set(gca,'YTick',[-1 -.67 -.33 0 .33 .67 1]);%linspace(-1,1,9));
set(gca,'Box','off');

end