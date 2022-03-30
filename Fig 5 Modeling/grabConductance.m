function dCondSort = grabConductance(dTable,indx)
% Function to grab traces from a specified data table and convert to
% conductances time series

if nargin < 2 || isempty(indx)
    indx = 1;
end

%% Check inputs and initialize

% Initialize flags for data processing / display
doFilter = true;
subtractHold = true;
rectifyConductances = true;

% Check recording type to initialize exc or inh flag
if dTable.RecordingType(indx) == "v clamp exc"
    dForce = paramsModel.eInh - paramsModel.eExc; % vHold - rev(Exc)
elseif dTable.RecordingType(indx) == "v clamp inh"
    dForce = paramsModel.eExc - paramsModel.eInh; % vHold - rev(Inh)
else
    error('Unrecognized data table recording type.')
end

% Initialize processing parameters
dt = paramsModel.dt; %sampling interval, in microseconds

% Check analysis window based on cell type
[~,holdWindow] = vSpdsTimes.CheckWindowTimes(dTable);
holdIndx = (1+holdWindow(1)*1e4):(holdWindow(2)/dt);

%% Load and process data

% Collect data and stim metadata
[d,stimSpds,~,~] = fetchData(dTable,indx);

% Lowpass filter w/ 30 Hz cutoff if doFilter flag is set to true
if doFilter
    d = lowpass(d,30,1/dt,'ImpulseResponse','iir','Steepness',.8);
end

% Subtract holding current, account for rig setup
if subtractHold
    avgHoldCurrent = mean(d(holdIndx,:));
    d = d - avgHoldCurrent; %Subtract holding current
end

% Convert to conductances
dCond = ((d * 1e-12) ./ dForce); %convert from pA to A, divide by driving force

% Set any negative conductances to zero
if rectifyConductances
    dCond(dCond < 0) = 0;
end

% Sort conductances by stim speed
dCondSort = quickSort(dCond,stimSpds);

end