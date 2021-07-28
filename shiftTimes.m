function [vSort,vDSI] = shiftTimes(dTable,indx,pIndx)
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
% For plotting purposes
shiftIndx = 3;

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
respIndx = ((1+respWindow(1)*1e4):(respWindow(2)/1e-4)) + 1.5/paramsModel.dt; %Adjust respIndx

% Initialize model output, pad conductances
nPts = paramsModel.checkType(dTable,indx) + (1.5 / paramsModel.dt); % Add one second of padding
padExcSort = [repmat(mean(mean(excSort(50001:end,:))),15000,10); excSort]; % Pad start of excSort w/ mean hold conductance
padInhSort = [repmat(mean(mean(inhSort(50001:end,:))),15000,10); inhSort];
vTrace = NaN(nPts,10,9);

shiftSpatial = -200:50:200;%-60:15:60; % spatial shift, in microns
stimSpds = [-1800 -1200 -600 -300 -150 150 300 600 1200 1800];
stimSpds = [inf   inf   inf  inf   inf 150 300 600 1200 1800]; % shift PD inh earlier
stimSpds = [-1800 -1200 -600 -300 -150 inf inf inf inf  inf ]; % shift ND inh later
%note negative velocity of null directions; positive circshift means later,
%negative circshift means inh arrives earlier.
%Should worry about "adding" spatial shifts (positive values) causing
%coincidence with OFF response

% Run parallel conductance model for each velocity
for j = 1:numel(shiftSpatial)
    % Shift inh on each loop
    for i = 1:10
        shiftTemporal = round((shiftSpatial(j) / stimSpds(i)) / paramsModel.dt);
        gInh = circshift(padInhSort(:,i),shiftTemporal);
        vTrace(:,i,j) = runModel(padExcSort(:,i),gInh);
    end
end
% Calculate amplitudes
vSort = bsxfun(@minus,max(vTrace(respIndx,:,:)),paramsModel.eLeak); %take peak voltage, minus leak potential

% Calculate DSIs - show summary plots and resp window if requested
if plotSummary
    figure;
    plot(squeeze(vTrace(:,:,shiftIndx)),'k','linewidth',1);
    hold on
    plot(respIndx,vTrace(respIndx,:,shiftIndx),'g','linewidth',1);
    velocityTuning(squeeze(vSort(:,:,shiftIndx))',paramsModel.stimSpds);
    % Plot DSI change w/ shifts
    vDSI = NaN(5,numel(shiftSpatial));
    for j = 1:numel(shiftSpatial)
        [~,vDSI(:,j)] = velocityTuning(squeeze(vSort(:,:,j))',paramsModel.stimSpds,1);
    end
    figure;
    plot(shiftSpatial,vDSI,'linewidth',2);
    legend(num2str([150 300 600 1200 1800]'))
else
    vDSI = NaN(5,numel(shiftSpatial));
    for j = 1:numel(shiftSpatial)
        [~,vDSI(:,j)] = velocityTuning(squeeze(vSort(:,:,j))',paramsModel.stimSpds,1);
    end
end

% Plot overlaid conductances and simulated voltage if flagged
if plotVoltage
    pIndx = 10;
    nIndx = 11 - pIndx;
    
    pShift = round((shiftSpatial(shiftIndx) / stimSpds(pIndx)) / paramsModel.dt);
    nShift = round((shiftSpatial(shiftIndx) / stimSpds(nIndx)) / paramsModel.dt);

    hF1 = plotCV(padExcSort(:,pIndx),circshift(padInhSort(:,pIndx),pShift),vTrace(:,pIndx,shiftIndx));
    title(sprintf('%i um Shift (PD)',shiftSpatial(shiftIndx)));
    hF2 = plotCV(padExcSort(:,nIndx),circshift(padInhSort(:,nIndx),nShift),vTrace(:,nIndx,shiftIndx));
    title(sprintf('%i um Shift (ND)',shiftSpatial(shiftIndx)));
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