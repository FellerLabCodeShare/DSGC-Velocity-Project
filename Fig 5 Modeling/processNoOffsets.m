function [vSort,vDSI] = processNoOffsets(dTable,indx,pIndx)
% Function to gather exc and inh conductances for a given cell, and then
% integrate conductances in a numerical model

if nargin < 3 || isempty(pIndx)
    pIndx = [];
    plotVoltage = false;
end

if nargin < 2 || isempty(indx)
    indx = 1;
end

% Flag for how to eliminate offsets
changePref = false; % set pref to match null offsets if true
                    % otherwise, set null to match pref offsets if false

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

% Determine how 
if changePref
    % Set pref offsets to match those of null; keep null unchanged
    shiftBy = [zeros(1,5), ieOffset(5:-1:1) - ieOffset(6:10)];
else
    % Set null offsets to match those of pref; keep pref unchanged
    shiftBy = [ieOffset(10:-1:6) - ieOffset(1:5), zeros(1,5)];
end

%% Run data

% Run parallel conductance model for each velocity
% (pos circshift means later, neg circshift means arrives earlier)
for i = 1:10
    gInh = circshift(padInhSort(:,i),shiftBy(i));
    vTrace(:,i) = runModel(padExcSort(:,i),gInh);
end

% Calculate amplitudes
vSort = bsxfun(@minus,max(vTrace(respIndx,:)),paramsModel.eLeak); %take peak voltage, minus leak potential

% Calculate DSIs - show summary plots and resp window if requested
if plotSummary
    % Plot response window
    figure;    plot(vTrace,'k','linewidth',1);

    hold on
    plot(respIndx,vTrace(respIndx,:),'g','linewidth',1);
    % Plot velocity tuning
    velocityTuning(vSort',paramsModel.stimSpds);
else
    % Calculate DSI, no plotting
    [~,vDSI] = velocityTuning(vSort',paramsModel.stimSpds,1);

end

% Plot overlaid conductances and simulated voltage if flagged
if plotVoltage
    pIndx = 10;
    nIndx = 11 - pIndx;
    
    hF1 = plotCV(padExcSort(:,pIndx),circshift(padInhSort(:,pIndx),shiftBy(pIndx)),vTrace(:,pIndx));
    title('PD');
    hF2 = plotCV(padExcSort(:,nIndx),circshift(padInhSort(:,nIndx),shiftBy(nIndx)),vTrace(:,nIndx));
    title('ND');
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