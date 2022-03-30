function hF = plotPairedSpdIndx(ooSpd,onSpd,createFig)
%function to plot side by side paired scalar values with some jitter

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
onPlot = ooPlot + .5;

%% Plot

%Construct new figure if flagged
if createFig
    hF = figure;
else
    hF = gcf;
    hold on;
end

% Plot lines connecting pairs
for i = 1:nOO
    plot([ooPlot(i) (onPlot(i))],[ooSpd(i) onSpd(i)],'-','linewidth',1,'Color',[0 0 0 .4]);
    hold on
end

%ooSpd vals and mean
plot(ooPlot,ooSpd,'o','linewidth',1,'Color',plotVals.defaultColor);
plot([.9 1.1],[avgOO avgOO],'-','linewidth',2,'Color',plotVals.defaultColor)

%onSpd vals and mean
plot(onPlot,onSpd,'o','linewidth',1,'Color',plotVals.ooColor);
plot([1.4 1.6],[avgON avgON],'-','linewidth',2,'Color',plotVals.ooColor)

xlim([.7 1.8]);
ylim([-1 1]);

set(gca,'XTick',[1 1.5]);
set(gca,'XTickLabel',{"ONOFF","ON"},'FontSize',12);
set(gca,'YTick',[-1 -.67 -.33 0 .33 .67 1]);%linspace(-1,1,9));
set(gca,'Box','off');

end