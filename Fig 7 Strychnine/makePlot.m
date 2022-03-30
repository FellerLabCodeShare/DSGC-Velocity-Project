%% Strychnine data

% [dOOPre,dOOPost,dOOExc] = collectDataTables('ONOFF');
% [dONPre,dONPost,dONExc] = collectDataTables('ON');

% Load data tables; contains pre and post-strychnine inh data tables, as
% well as post strychnine exc data tables (exc not analyzed here).
load('On Strychnine Tables.mat');
load('OnOff Strychnine Tables.mat');

%% Validate cells
%Paper example cells:
%ON; indx = 2 % set(gcf.Children(11:end),'YLim',[-100 2000])
% processData(dONPre,indx,true,true);
% processData(dONPost,indx,true,true);
% set(gcf.Children(11:end),'YLim',[-100 2000])

dTable = dONPost;
indx = 2; %2, 3, 6, (8)

processData(dTable,indx,true,true);


%% Process data

[pOOPre,pOOPreDSI,qOOPre,qOOPreDSI,pOOPreAsym,qOOPreAsym] = getSummaryData(dOOPre);
[pONPre,pONPreDSI,qONPre,qONPreDSI,pONPreAsym,qONPreAsym] = getSummaryData(dONPre);

[pOOPost,pOOPostDSI,qOOPost,qOOPostDSI,pOOPostAsym,qOOPostAsym] = getSummaryData(dOOPost);
[pONPost,pONPostDSI,qONPost,qONPostDSI,pONPostAsym,qONPostAsym] = getSummaryData(dONPost);


onPreSpd = spdIndx(pONPre(:,10),pONPre(:,6));
onPostSpd = spdIndx(pONPost(:,10),pONPost(:,6));

ooPreSpd = spdIndx(pOOPre(:,10),pOOPre(:,6));
ooPostSpd = spdIndx(pOOPost(:,10),pOOPost(:,6));

% Normalize
preSymNorm = pONPre(:,6:10) ./ max(pONPre,[],2);
postSymNorm = pONPost(:,6:10) ./ max(pONPre,[],2);

preAsymNorm = pONPreAsym ./ max(pONPre,[],2);
postAsymNorm = pONPostAsym ./ max(pONPre,[],2);

%% Plot fits

hF1 = plotFit(preSymNorm,'default');
hF2 = plotFit(postSymNorm,'Other');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))
ylim([0 .8]);

% Plot averages
hF1 = plotAvg(preAsymNorm,'default');
hF2 = plotAvg(postAsymNorm,'Other');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))
ylim([0 .8]);

%% Plot ON data

isPref = "pref";
isNull = "null";
isCharge = true;
isCur = false;
doNorm = true;
noNorm = false;

hF1 = plotCurrents(pONPre,isPref,isCur,'default',noNorm);
hF2 = plotCurrents(pONPost,isPref,isCur,'ONOFF',noNorm);
linkprop([hF1.Children(1),hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'YLim',[0 1600],'YTick',0:400:1600);

hF3 = plotCurrents(pONPreAsym,"none",isCur,'default',noNorm);
hF4 = plotCurrents(pONPostAsym,"none",isCur,'ONOFF',noNorm);
linkprop([hF3.Children(1),hF4.Children(1)],{'YTick','YLim'});
set(hF3.Children(1),'YLim',[0 1600],'YTick',0:400:1600);

plotDSI(-pONPreDSI,'default')
plotDSI(-pONPostDSI,'ONOFF')

hF5 = plotPairedSpdIndx(onPreSpd,onPostSpd);
set(hF5.Children(1),'XTickLabel',{"Ctrl","Stryc"});
ylim([-.33 1])

%% Plot OO Data

plotDSI(-pOOPreDSI,'ONOFF')
plotDSI(-pOOPostDSI,'ONOFF')
plotCurrents(pOOPre,true,false,'ONOFF',false)
plotCurrents(pOOPost,true,false,'ONOFF',false);



%%%%%% RELEVANT TO PLOT:
%%%%%% PLOT DSI BEFORE AND AFTER (?)
%%%%%% AVG SYM (PREF) AND ASYM (NULL - PREF)
%%%%%% DIFF IN SYM, DIFF IN ASYM
%%%%%% (PREF) SPD INDX PRE AND POST

