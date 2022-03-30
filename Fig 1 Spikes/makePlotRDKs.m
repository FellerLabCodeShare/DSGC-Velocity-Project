%% Tools to make Figure 1

% Gathr data (revise this - dyclamp not yet added, replace with static list)
%%%% check 190306 analysis %%%%
dTableOn = loadDataTables('ON','c clamp','rdks','none');
dTableOn = dTableOn(~dTableOn.Skeptical,:);

dTableOO = loadDataTables('ONOFF','c clamp','rdks','none');
dTableOO = dTableOO(~dTableOO.Skeptical,:);

%% Validate data
% Run individual cells with plotting turned on
dTable = dTableOn;
indx = 3;
% Example Cell:
% Used ON #3

processRDKs(dTable,indx,true,true);

%% Process data

[onCt,onCtDSI,onHz,onHzDSI,onCtPDs,onHzPDs] = getSummaryData(dTableOn);
[ooCt,ooCtDSI,ooHz,ooHzDSI,ooCtPDs,ooHzPDs] = getSummaryData(dTableOO);

%% Plot data


% Plot mean 
dirTuning(onHz',(0:45:315)')
hA = gca;
set(hA.Children(3:13),'Color',plotVals.getColor('ON',true),'linewidth',1.5);
set(hA.Children(1:2),'Color',plotVals.getColor('ON'),'linewidth',2.5);
hA.ThetaTick = 0:90:270;
hA.RTick = hA.RLim(end);
hA.RTickLabel = {sprintf('%i Hz',hA.RLim(end))};
hA.RAxisLocation = 135;
title('');

% Plot DSI (sort of a lame plot)
hF = plotSpdIndx(onHzDSI,onHzDSI);
xlim([1.2 1.8])
ylim([0 1])
hF.Children.YTick = 0:.25:1;


% export_fig 'RDK Hz Means' -transparent -native
