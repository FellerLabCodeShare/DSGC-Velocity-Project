function hF = plotSpdHist(ooSpd,onSpd)
% Function to plot histograms of speed indices

% Set histogram bins
bins = linspace(-1,1,15);
% bins = -1:.2:1;

% Create plot
hF = figure;
histogram(ooSpd,bins,'Normalization','probability','FaceColor',plotVals.getColor("default"));
hold on
histogram(onSpd,bins,'Normalization','probability','FaceColor',plotVals.getColor("ON"));

% Set axis parameters
set(gca,'XTick',[-1 0 1]);%bins);
set(gca,'Box','off');
xlabel('Speed Index');
ylabel('Fraction');

end