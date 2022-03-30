%% Tools to make Figure 1

% Gather data; metadata contained in data table
load("Gratings Data Tables.mat");

%% Validate data
% Run individual cells with plotting turned on
% Example cells used:
% On: #2
% OnOff: #4 (2, 7 could be alternativeS?)
dTable = dTableOO;
indx = 4;

processData(dTable,indx,true,true);

%% Process data

nonans = true; % flag to additionally process any NaN speed tuning indices

% Sequentially process each data table entry, output summary values
[onCt,onCtDSI,onHz,onHzDSI] = getSummaryData(dTableOn);
[ooCt,ooCtDSI,ooHz,ooHzDSI] = getSummaryData(dTableOO);

% Calculate speed indices based on preferred direction spiking data
onSpd = spdIndx(onHz(:,14),onHz(:,8));
ooSpd = spdIndx(ooHz(:,14),ooHz(:,8));

% Ensure each cell has a speed index value
if nonans
    % Some DSGCs may not spike at neither the lowest nor highest velocity;
    % ensure a speed index is calculated for these cells by using the next
    % lowest pref dir speed.
    x = isnan(onSpd);
    onSpd(x) = spdIndx(onHz(x,14),onHz(x,9));
    x = isnan(ooSpd);
    ooSpd(x) = spdIndx(ooHz(x,14),ooHz(x,9));
end

%% Plot data

isPref = true;
isNull = false;
isHz = true;
isCt = false;

hF = plotSpikes(onHz,isPref,isHz,'ON',false);
hF.Children.YTick = 0:15:60;
hF = plotSpikes(ooHz,isPref,isHz,'default',false);
hF.Children.YTick = 0:20:100;

plotDSI(onHzDSI,'ON')
plotDSI(ooHzDSI,'default')

plotSpdIndx(ooSpd,onSpd)

% Check analysis window based on cell type
tmWindow = cSpdsTimes.CheckWindowTimes(dTable,indx,offWindow);

