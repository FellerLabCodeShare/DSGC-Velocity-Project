function [vSort,vDSI] = processInhSym(dTable,indx,pIndx)
% Function to gather exc and inh conductances for a given cell, and then
% integrate conductances in a numerical model

if nargin < 3 || isempty(pIndx)
    pIndx = [];
    plotVoltage = false;
end

if nargin < 2 || isempty(indx)
    indx = 1;
end

% Plotting flags
plotVoltage = false;
plotSummary = false;

%% Load data, initialize

% Check analysis window based on cell type
[respWindow,~] = vSpdsTimes.CheckWindowTimes(dTable,indx);
respIndx = ((1+respWindow(1)*1e4):(respWindow(2)/1e-4)) + 1.5/paramsModel.dt; %Adjust respIndx

% Identify cell's exc and inh recordings
[excTable,inhTable] = grabCell(dTable.CellID(indx));

% Load data and convert to conductances
excSort = grabConductance(excTable);
inhSort = grabConductance(inhTable);

% Calculate mean conductance trace for each velocity
excSort = squeeze(nanmean(excSort,2));
inhSort = squeeze(nanmean(inhSort,2));

% Initialize model output, pad conductances
padTime = 1.5 / paramsModel.dt; % Add extra 1.5 sec of padding
nPts = paramsModel.checkType(dTable,indx) + padTime;
padExcSort = [repmat(mean(mean(excSort(50001:end,:))),padTime,10); excSort]; % Pad start of excSort w/ mean hold conductance
padInhSort = [repmat(mean(mean(inhSort(50001:end,:))),padTime,10); inhSort];
vTrace = NaN(nPts,10);

% Find offsets of mean conductances
ieOffset = findOffset(padExcSort,padInhSort,respIndx);

% Make inh symmetric by replacing null dir inh w/ pref dir inh, and adding
% back the proper spatial offset
symInhSort = [padInhSort(:,10:-1:6) padInhSort(:,6:10)];
newOffset = findOffset(padExcSort,symInhSort,respIndx);

% Difference between original and new offset gives index to shift by to
% restore original I E offsets
% shiftBy = newOffset - ieOffset;
shiftBy = ieOffset - newOffset;

%% Run data

% Run parallel conductance model for each velocity
% (pos circshift means later, neg circshift means arrives earlier)
for i = 1:10
    gInh = circshift(symInhSort(:,i),shiftBy(i));
    vTrace(:,i) = runModel(padExcSort(:,i),gInh);
end

% Calculate amplitudes
vSort = bsxfun(@minus,max(vTrace(respIndx,:)),paramsModel.eLeak); %take peak voltage, minus leak potential

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
    % Calculate DSI, no plotting
    [~,vDSI] = velocityTuning(vSort',paramsModel.stimSpds,1);

end

% Plot overlaid conductances and simulated voltage if flagged
if plotVoltage
    pIndx = 10;
    nIndx = 11 - pIndx;
    
    hF1 = plotCV(padExcSort(:,pIndx),circshift(symInhSort(:,pIndx),shiftBy(pIndx)),vTrace(:,pIndx));
    hF2 = plotCV(padExcSort(:,nIndx),circshift(symInhSort(:,nIndx),shiftBy(nIndx)),vTrace(:,nIndx));
    linkprop([hF1.Children.YAxis(1),hF2.Children.YAxis(1)],'Limits')
    linkprop([hF2.Children.YAxis(2),hF1.Children.YAxis(2)],'Limits')
end

end

function ieOffset = findOffset(gExc,gInh,respIndx)
% Subroutine to find the offset between exc and inh

% Use "time of peaks" method to calculate timing
[~,eTime] = max(gExc(respIndx,:));
[~,iTime] = max(gInh(respIndx,:));

% Take difference of I and E to find offset
ieOffset = iTime - eTime;

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