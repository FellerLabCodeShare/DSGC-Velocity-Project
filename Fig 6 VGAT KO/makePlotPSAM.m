%% PSAM / VGATCHAT Data
% Collect data tables

dTableOnPre = loadDataTables('adj bars spds','v clamp inh','none','ON');
dTableOnPSEM = loadDataTables('adj bars spds','v clamp inh','PSEM','ON');
dTableOnPSEM = dTableOnPSEM(~dTableOnPSEM.Skeptical,:);
% dTableOnPSEM(dTableOnPSEM.CellID == "201211005",:) = []; %rehabilitate this cell later
% Sync up pre and post PSEM
dTableOnPre = dTableOnPre(ismember(dTableOnPre.CellID,dTableOnPSEM.CellID),:);

dTableOOPre = loadDataTables('adj bars spds','v clamp inh','none','ONOFF');
dTableOOPSEM = loadDataTables('adj bars spds','v clamp inh','PSEM','ONOFF');
dTableOOPSEM = dTableOOPSEM(~dTableOOPSEM.Skeptical,:); %check skeptical cells later
dTableOOPSEM(dTableOOPSEM.CellID == "200830001",:) = []; %rehabilitate this cell later
dTableOOPSEM(dTableOOPSEM.CellID == "201210001",:) = []; %rehabilitate this cell later
% Sync up pre and post PSEM
dTableOOPre = dTableOOPre(ismember(dTableOOPre.CellID,dTableOOPSEM.CellID),:);


%% Validate cells

dTable = dTableOOPSEM;
indx = 1;

processData(dTable,indx,true,true);

%% Process data

[pOOPre,pOOPreDSI,qOOPre,qOOPreDSI,pOOPreAsym,qOOPreAsym] = getSummaryData(dTableOOPre);
[pONPre,pONPreDSI,qONPre,qONPreDSI,pONPreAsym,qONPreAsym] = getSummaryData(dTableOnPre);

[pOOPost,pOOPostDSI,qOOPost,qOOPostDSI,pOOPostAsym,qOOPostAsym] = getSummaryData(dTableOOPSEM);
[pONPost,pONPostDSI,qONPost,qONPostDSI,pONPostAsym,qONPostAsym] = getSummaryData(dTableOnPSEM);


onPreSpd = spdIndx(pONPre(:,10),pONPre(:,6));
onPostSpd = spdIndx(pONPost(:,10),pONPost(:,6));

ooPreSpd = spdIndx(pOOPre(:,10),pOOPre(:,6));
ooPostSpd = spdIndx(pOOPost(:,10),pOOPost(:,6));

%% Plot ON data

isPref = "pref";
isNull = "null";
isCharge = true;
isCur = false;
doNorm = true;
noNorm = false;

hF1 = plotCurrents(pONPre,isPref,isCur,'default',noNorm);
hF2 = plotCurrents(pONPost,isPref,isCur,'Other',noNorm);
linkprop([hF1.Children(1),hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'YLim',[0 1200],'YTick',0:400:1600);

hF3 = plotCurrents(pONPreAsym,"none",isCur,'default',noNorm);
hF4 = plotCurrents(pONPostAsym,"none",isCur,'Other',noNorm);
linkprop([hF3.Children(1),hF4.Children(1)],{'YTick','YLim'});
set(hF3.Children(1),'YLim',[0 1200],'YTick',0:400:1600);

plotDSI(-pONPreDSI,'default')
plotDSI(-pONPostDSI,'Other')

hF5 = plotSpdIndx(onPreSpd,onPostSpd);
set(hF5.Children(1),'XTickLabel',{"Ctrl","PSEM"});
ylim([-.3 .5])


%% Plot ONOFF data

isPref = "pref";
isNull = "null";
isCharge = true;
isCur = false;
doNorm = true;
noNorm = false;

hF1 = plotCurrents(pOOPre,isPref,isCur,'default',noNorm);
hF2 = plotCurrents(pOOPost,isPref,isCur,'Other',noNorm);
linkprop([hF1.Children(1),hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'YLim',[0 1800],'YTick',0:400:1600);

hF3 = plotCurrents(pOOPreAsym,"none",isCur,'default',noNorm);
hF4 = plotCurrents(pOOPostAsym,"none",isCur,'Other',noNorm);
linkprop([hF3.Children(1),hF4.Children(1)],{'YTick','YLim'});
set(hF3.Children(1),'YLim',[0 1800],'YTick',0:400:1600);

plotDSI(-pOOPreDSI,'default')
plotDSI(-pOOPostDSI,'Other')

hF5 = plotSpdIndx(ooPreSpd,ooPostSpd);
set(hF5.Children(1),'XTickLabel',{"Ctrl","PSEM"});
ylim([-.3 .3])
