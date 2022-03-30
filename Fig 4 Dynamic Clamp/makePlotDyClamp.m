%% Dynamic Clamp Data

% dTableOO = loadDataTables('ONOFF','gOO');
% dTableOn = loadDataTables('ON','gOO');
dTableOO = loadDataTables('ONOFF','dy clamp');
dTableON = loadDataTables('ON','dy clamp');

% Remove ON attempts
rmGON = (dTableOO.Stim == "gON") | (dTableOO.Stim == "gON 210120") | ...
    (dTableOO.Stim == "gON 210520");
dTableOO(rmGON,:) = [];
rmGON = (dTableON.Stim == "gON") | (dTableON.Stim == "gON 210120") | ...
    (dTableON.Stim == "gON 210520");
dTableON(rmGON,:) = [];

%% Validate cell
% Run individual cells with plotting turned on
% Example Cells:
% OnOff: Used 3 (not great)
% On: Use 5 (alternate: 7)
% (new On: used 3  (7 looks nice too) (excluded population conductances))
% (new OO: used 5)

dTable = dTableOO;
indx = 16;

processData(dTable,indx,true,true);

%% Process data

rectifyDSI = true; % flag to prevent DSIs from being negative

% Sequentially process each data table entry, output summary values
[onCt,onCtDSI,onHz,onHzDSI] = getSummaryData(dTableON);
[ooCt,ooCtDSI,ooHz,ooHzDSI] = getSummaryData(dTableOO);

% Consider larger null direction spiking as noise, rectify DSIs to be 0 minimum
if rectifyDSI
    onHzDSI(onHzDSI < 0) = 0;
    ooHzDSI(ooHzDSI < 0) = 0;
    fprintf('Rectifying spike DSIs.\n');
end

% Calculate speed indices based on preferred direction spiking
onSpd = spdIndx(onHz(:,10),onHz(:,6));
ooSpd = spdIndx(ooHz(:,10),ooHz(:,6));

% Normalize spikes
onHzNorm = onHz(:,6:10) ./ max(onHz,[],2);
ooHzNorm = ooHz(:,6:10) ./ max(ooHz,[],2);

%% Plot data

isPref = true;
isNull = false;
isHz = true;
isCt = false;


hF1 = plotSpikes(onHz,isPref,isHz,'ON',false);
hF2 = plotSpikes(ooHz,isPref,isHz,'default',false);

linkprop([hF1.Children(1),hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'YLim',[0 130],'YTick',0:40:120);

hF3 = plotDSI(onHzDSI,'ON');
hF4 = plotDSI(ooHzDSI,'default');

linkprop([hF3.Children(1),hF4.Children(1)],{'YTick','YLim'});
set(hF3.Children(1),'YLim',[0 1],'YTick',0:.2:1);

plotSpdIndx(ooSpd,onSpd)

%% Plot fits
% Only use individual cell conductances
excludeOn = ((dTableON.Stim == "gOO") & (dTableON.Rig == "pre-DMD SOS")) | dTableON.Stim == "gOO 210520";
excludeOO = ((dTableOO.Stim == "gOO") & (dTableOO.Rig == "pre-DMD SOS")) | dTableOO.Stim == "gOO 210520";
% Only use new calibration trials
% excludeOn = ((dTableON.Stim == "gOO"));
% excludeOO = ((dTableOO.Stim == "gOO"));


hF1 = plotFit(onHzNorm(~excludeOn,:),'ON');
hF2 = plotFit(ooHzNorm(~excludeOO,:),'default');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))


hF3 = plotAvg(onHzDSI(~excludeOn,:),'ON');
hF4 = plotAvg(ooHzDSI(~excludeOO,:),'default');

copyobj(allchild(hF3.Children(1)),hF4.Children(1));
set(hF3.Children(1),'YLim',[0 1],'YTick',0:.2:1);

plotSpdIndx(ooSpd(~excludeOO),onSpd(~excludeOn))