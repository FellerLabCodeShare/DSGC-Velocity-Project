function [pSort,pDSI,qSort,qDSI] = processData(dTable,indx,showPP,showSummary,offWindow)
% Function to load and pre-process a file from the input data table

if nargin < 5 || isempty(offWindow) % Analyze OFF response; default is ON
    offWindow = false;
end
    
if nargin < 4 || isempty(showSummary) % Show summary plots
    showSummary = false;
end

if nargin < 3 || isempty(showPP) % Show pre-processing plots
    showPP = false;
end

if nargin < 2 || isempty(indx)
    indx = 1;
end

%% Check inputs and initialize

% Initialize flags for data processing / display
doFilter = true;
subtractHold = true;
medianHold = false;
windowCharge = true;

% Check recording type to initialize exc or inh flag
if dTable.RecordingType(indx) == "v clamp exc"
    isExc = true;
elseif dTable.RecordingType(indx) == "v clamp inh"
    isExc = false;
else
    error('Unrecognized data table recording type.')
end

% Initialize processing parameters
dt = 1e-4; %sampling interval, in microseconds
N = round((20e-3) / dt); %avg 20 ms filter coefficient

% Check analysis window based on cell type
[respWindow,holdWindow] = vSpdsTimes.CheckWindowTimes(dTable,indx,offWindow);
respIndx = (1+respWindow(1)*1e4):(respWindow(2)/dt);
holdIndx = (1+holdWindow(1)*1e4):(holdWindow(2)/dt);

%% Load and pre-process data

% Collect data and stim metadata
[d,stimSpds,~,~] = fetchData(dTable,indx);

% Use a 20ms rolling average filter if doFilter flag is set to true
if doFilter
%     avg20msFilter = ones(1,N)/N;
%     d = filter(avg20msFilter,1,d);
    d = lowpass(d,30,1/dt,'ImpulseResponse','iir','Steepness',.8);
end

% Subtract holding current, account for rig setup
if subtractHold
    avgHoldCurrent = mean(d(holdIndx,:));
    avgHoldCurrent = mean(avgHoldCurrent);
%     d(1:(N+1),:) = repmat(avgHoldCurrent,N+1,1); %Remove filtering artifact
    if medianHold
        % If flagged, use median hold for each trace; otherwise use each
        % trace's holding current
        avgHoldCurrent = median(d);
    end
    d = d - avgHoldCurrent; %Subtract holding current
end

% Calculate summary stats
if isExc %take min if exc, max if inh
    pCur = min(d(respIndx,:));
    d = -d;
else
    pCur = max(d(respIndx,:));
end
pSort = quickSort(pCur,stimSpds);

% Calculate Total Charge Transfer
if windowCharge %take charge transfer only in response window
%     qCur = sum(d(respIndx,:))*dt;
    qCur = max(cumsum(d(respIndx,:)))*dt;
else %otherwise take charge transfer from entire recording
    qCur = sum(d) * dt;
end
qSort = quickSort(qCur,stimSpds);

%%%%% INSERT TIMING ANALYSIS HERE %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Perform requested plotting
% Show all traces in one plot, with holding period highlighted in red

if showPP
    figure;
    plot(d,'k');
    hold on
    plot(holdIndx,d(holdIndx,:),'r');
    plot(respIndx,d(respIndx,:),'g');
    %     for i = 1:3
    %         figure;
    %         plot(d(:,(1+(i-1)*10):i*10),'k');
    %         hold on
    %         plot(holdIndx,d(holdIndx,:),'r');
    %     end
    
    % Show each trace sorted by the stim velocity
    plotDirTraces(d,stimSpds,1,10000);
end

%Show velocity tuning summary data
if showSummary
    [~,pDSI] = velocityTuning(pSort,stimSpds);
    [~,qDSI] = velocityTuning(qSort,stimSpds);
else
    [~,pDSI] = velocityTuning(pSort,stimSpds,1);
    [~,qDSI] = velocityTuning(qSort,stimSpds,1);
end

end
