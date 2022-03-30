function [vSort,vDSI] = subInh(dTable,indx,pIndx)
% Function to gather exc and inh conductances for a given cell, and then
% integrate conductances in a numerical model

if nargin < 3 || isempty(pIndx)
    pIndx = [];
    plotVoltage = false;
end

if nargin < 2 || isempty(indx)
    indx = 1;
end

isMean = true;
plotVoltage = true;%false;
plotSummary = true;%false;

%% Run data
% Identify cell's exc and inh recordings
[excTable,inhTable] = grabCell(dTable.CellID(indx));

% Load data and convert to conductances
excSort = grabConductance(excTable);
inhSort = grabConductance(inhTable);

% Compute mean conductance for each velocity if flagged
if isMean
    excSort = squeeze(nanmean(excSort,2));
    inhSort = squeeze(nanmean(inhSort,2));
else
    error('Non-mean conductance modelling not yet implemented.')
end

% Check analysis window based on cell type
[respWindow,~] = vSpdsTimes.CheckWindowTimes(dTable,indx);
respIndx = (1+respWindow(1)*1e4):(respWindow(2)/1e-4);

% Initialize model output
nPts = paramsModel.checkType(dTable,indx);
vTrace = NaN(nPts,10);

% Run parallel conductance model for each velocity
for i = 1:10
   vTrace(:,i) = runModel(excSort(:,i),inhSort(:,i));
end

% Calculate amplitudes
vSort = bsxfun(@minus,max(vTrace(respIndx,:)),paramsModel.eLeak); %take peak voltage, minus leak potential

% Calculate DSIs - show summary plots and resp window if requested
if plotSummary
    figure;
    plot(vTrace,'k','linewidth',1);
    hold on
    plot(respIndx,vTrace(respIndx,:),'g','linewidth',1);
    velocityTuning(vSort',paramsModel.stimSpds);
else
    [~,vDSI] = velocityTuning(vSort',paramsModel.stimSpds,1);
end

% Plot overlaid conductances and simulated voltage if flagged
if plotVoltage
    pIndx = 7;
    nIndx = 11 - pIndx;
    hF1 = plotCV(excSort(:,pIndx),inhSort(:,pIndx),vTrace(:,pIndx));
    hF2 = plotCV(excSort(:,nIndx),inhSort(:,nIndx),vTrace(:,nIndx));
    linkprop([hF1.Children.YAxis(1),hF2.Children.YAxis(1)],'Limits')
    linkprop([hF2.Children.YAxis(2),hF1.Children.YAxis(2)],'Limits')
end

end

function hF = plotCV(gExc,gInh,Vm)
% Subroutine to plot conductance and voltage ontop of one another

hF = figure;
yyaxis right
plot(gInh*1e9,'-','linewidth',2,'Color',[1 0 0 .4]);
hold on
plot(gExc*1e9,'-','linewidth',2,'Color',[0 .9 .5 .4]);
ylabel('Conductance (nS)');
yyaxis left
plot(Vm*1e3,'linewidth',2,'Color',[0 0 0 .7]);
ylabel('Voltage (mV)');
x = gca;
x.YAxis(1).Color = [0 0 0];
x.YAxis(2).Color = [0 0 0];

end