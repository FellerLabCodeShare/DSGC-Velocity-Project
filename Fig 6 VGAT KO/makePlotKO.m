%% Hoxd10VGATChat 
dTableKOs = collectDataTables(false);

% Separate out into On and OnOff, then exc & inh
% dTableOn = dTableKOs(dTableKOs.CellType == 'ON',:);
% dTableOnExc = dTableOn(dTableOn.RecordingType == 'v clamp exc',:);
% dTableOnInh = dTableOn(dTableOn.RecordingType == 'v clamp inh',:);
% 
% dTableOO = dTableKOs(dTableKOs.CellType == 'ONOFF',:);
% dTableOOExc = dTableOO(dTableOO.RecordingType == 'v clamp exc',:);
% dTableOOInh = dTableOO(dTableOO.RecordingType == 'v clamp inh',:);

load("KO Data Tables.mat");

%% Validate Cells
% OO #6, #12 still somewhat tuned
% Example: 5? 1? 7? (8)
% Used #8

% ON
% Example: 2, 3, (4), 6, 9x, 10, 11

dTable = dTableOOInh;
indx = 7;

processData(dTable,indx,true,true);

%% Process data

[pExcOn,pExcOnDSI,qExcOn,qExcOnDSI,pExcOnAsym,qExcOnAsym] = getSummaryData(dTableOnExc);
[pInhOn,pInhOnDSI,qInhOn,qInhOnDSI,pInhOnAsym,qInhOnAsym] = getSummaryData(dTableOnInh);

pInhOnSpd = spdIndx(pInhOn(:,10),pInhOn(:,6));


[pExcOO,pExcOODSI,qExcOO,qExcOODSI,pExcOOAsym,qExcOOAsym] = getSummaryData(dTableOOExc);
[pInhOO,pInhOODSI,qInhOO,qInhOODSI,pInhOOAsym,qInhOOAsym] = getSummaryData(dTableOOInh);

pInhOOSpd = spdIndx(pInhOO(:,10),pInhOO(:,6));
% pInhAsymOOSpd = spdIndx(pInhOO(:,5),pInhOO(:,1));

% Normalize
onSymNorm = pInhOn(:,6:10) ./ max(pInhOn,[],2);
ooSymNorm = pInhOO(:,6:10) ./ max(pInhOO,[],2);

onAsymNorm = pInhOnAsym ./ max(pInhOn,[],2);
ooAsymNorm = pInhOOAsym ./ max(pInhOO,[],2);


%% 

% Plot fits
hF1 = plotFit(ooSymNorm,"default");
hF2 = plotFit(onSymNorm,"ON");

copyobj(allchild(hF1.Children(1)),hF2.Children(1))
ylim([-.1 1]);

% Overlaid averages
hF1 = plotAvg(onAsymNorm,'ON');
hF2 = plotAvg(ooAsymNorm,'default');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))
ylim([-.1 1]);

%% Plot data On Data

isPref = "pref";
isNull = "null";
isCharge = true;
isCur = false;
doNorm = true;
noNorm = false;

hF1 = plotCurrents(pInhOn,isPref,isCur,'default',noNorm);
hF2 = plotCurrents(pInhOnAsym,"none",isCur,'Other',noNorm);
linkprop([hF1.Children(1),hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'YLim',[-300 2000],'YTick',[-250 0:500:2000]);

plotDSI(-pInhOnDSI,'Other')
ylim([-.2 1])

plotSpdIndx(pInhOnSpd,pInhOnSpd);


%% Plot OnOff data

hF1 = plotCurrents(pInhOO,isPref,isCur,'Other',noNorm);
hF2 = plotCurrents(pInhOOAsym,"none",isCur,'Other',noNorm);
linkprop([hF1.Children(1),hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'YLim',[-300 2000],'YTick',[-250 0:500:2000]);

plotDSI(-pInhOODSI,'Other')
ylim([-.2 1])

plotSpdIndx(pInhOOSpd,pInhOOSpd);


