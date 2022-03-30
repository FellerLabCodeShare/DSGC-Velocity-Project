%% Tools to make Figure 2

% Gather data 
% dTableExcOn = loadDataTables('ON','v clamp exc','adj bars spds','none');
% dTableExcOn = dTableExcOn(~dTableExcOn.Skeptical,:); %not worth it
% dTableExcOn = dTableExcOn(ismissing(dTableExcOn.Notes(:)),:); %remove a few contrast exps
% dTableExcOn = dTableExcOn(~(dTableExcOn.Genotype == "Hoxd10VGATChat"),:); % remove KOs
load('On Exc Table.mat');

% Can separate out OO into Hox and Trhr/Drd4 later, if desired
% dTableExcOther = loadDataTables('ONOFF','v clamp exc','adj bars spds','none'); 
% dTableExcOther = dTableExcOther(~dTableExcOther.Skeptical,:);
% dTableExcOther = dTableExcOther(~(dTableExcOther.Genotype == "Hoxd10VGATChat"),:); % remove KOs
% dTableInhOther(dTableInhOther.CellID == "201005004",:) = []; % weird cell, need for strychnine datasetbut not worth analysis here
load('OnOff Exc Table.mat');

% dTableInhHoxOO = loadDataTables('ONOFF','v clamp inh','adj bars spds','none','Hoxd10');
% dTableOther = dTableOO(~(dTableOO.Genotype == 'Hoxd10' | dTableOO.Genotype == 'Hoxd10Chat' | ...
% dTableOO.Genotype == 'Hoxd10ChatPSAM' | dTableOO.Genotype == 'Hoxd10VGAT'),:)


%% Validate data
%Paper example cells:
%ONOFF; indx = 15
%ON; indx = 14; 12 looks good but tiny OFF; Used 13

dTable = dTableExcOn;
indx = 12;

processData(dTable,indx,true,true);

%% Process data

% Get Summary Data
[pExcOn,pExcOnDSI,qExcOn,qExcOnDSI,pExcOnAsym,qExcOnAsym] = getSummaryData(dTableExcOn);
% [pInhHox,pInhHoxDSI,qInhHox,qInhHoxDSI,pInhHoxAsym,qInhHoxAsym] = getSummaryData(dTableInhHoxOO);
[pExcOther,pExcOtherDSI,qExcOther,qExcOtherDSI,pExcOtherAsym,qExcOtherAsym] = getSummaryData(dTableExcOther);

% Calculate speed indices (symmetric)
onExcSymSpdIndx = spdIndx(pExcOn(:,10),pExcOn(:,6));
otherExcSymSpdIndx = spdIndx(pExcOther(:,10),pExcOther(:,6));

% Calculate speed indices (asymmetric)
onExcAsymSpdIndx = spdIndx(pExcOnAsym(:,5),pExcOnAsym(:,1));
otherExcAsymSpdIndx = spdIndx(pExcOtherAsym(:,5),pExcOtherAsym(:,1));

% Normalize
pExcOnSymNorm = pExcOn(:,5:-1:1) ./ max(pExcOn,[],2);
pExcOnAsymNorm = pExcOnAsym ./ max(pExcOn,[],2);

pExcOtherSymNorm = pExcOther(:,5:-1:1) ./ max(pExcOther,[],2);
pExcOtherAsymNorm = pExcOtherAsym ./ max(pExcOther,[],2);

rectifyDSI = true;
if rectifyDSI % Set minimum DSI value as 0
    qExcOtherDSI(qExcOtherDSI < 0) = 0;
    qExcOnDSI(qExcOnDSI < 0) = 0;
    pExcOtherDSI(pExcOtherDSI < 0) = 0;
    pExcOnDSI(pExcOnDSI < 0) = 0;
end

%% Plot Fits
% Exponential fits (w/ offset)
hF1 = plotFit(pExcOnSymNorm,'ON');
hF2 = plotFit(pExcOtherSymNorm,'default');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))
ylim([0 1]);

% Overlaid averages
hF1 = plotAvg(pExcOnAsymNorm,'ON');
hF2 = plotAvg(pExcOtherAsymNorm,'default');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))
ylim([0 1]);

%% Plot data (Extended Figures)
% Establish plotting flags
isPref = "pref";
isNull = "null";
isCharge = true;
isCur = false;
doNorm = true;
noNorm = false;

% Plot DSI
plotDSI(pExcOnDSI,'ON')
ylim([-.1 1]);
plotDSI(pExcOtherDSI,'default')
ylim([-.1 1]);

% Plot normalized currents

% Plot
hF1 = plotCurrents(pExcOn,isPref,isCur,'ON',false);
%don't flip sign of asymmetric current
hF2 = plotCurrents(pExcOnAsym,"none",isCur,'ON',false);

set(hF1.Children(1),'YLim',[-50 350],'YTick',[-50 0 100 200 300]);
linkprop([hF1.Children(1), hF2.Children(1)],{'YTick','YLim'});

hF3 = plotCurrents(pExcOther,isPref,isCur,'default',false);
%don't flip sign of asymmetric current
hF4 = plotCurrents(pExcOtherAsym,"none",isCur,'default',false);

set(hF3.Children(1),'YLim',[-100 800],'YTick',[-100 0:200:800]);
linkprop([hF3.Children(1), hF4.Children(1)],{'YTick','YLim'});

% Plot spd indx of symmetric and asymmetric
hF5 = plotSpdIndx(otherExcSymSpdIndx,otherExcAsymSpdIndx);
set(hF5.Children(1).Children(:),'Color',plotVals.defaultColor);
set(hF5.Children(1),'XTickLabel',{"Sym Exc","Asym Exc"})

% Plot spd indx of symmetric and asymmetric
hF6 = plotSpdIndx(onExcSymSpdIndx,onExcAsymSpdIndx);
set(hF6.Children(1).Children(:),'Color',plotVals.onColor);
set(hF6.Children(1),'XTickLabel',{"Sym Exc","Asym Exc"})

%% Ext Fig

% Show relationship between peak and charge transfer
plotScatter(qExcOther,pExcOther,false,'default')
plotScatter(qExcOn,pExcOn,false,'ON');

% Show Q vs P DSI relationship
plotScatter(qExcOtherDSI,pExcOtherDSI,true,'default');
plotScatter(qExcOnDSI,pExcOnDSI,true,'ON');


plotSpdIndx(otherExcSymSpdIndx,onExcSymSpdIndx);
ylim([-.5 .5])

% figure;
% plot(pExcOtherDSI,qExcOtherDSI,'ok')

% peak vs charge DSI plot
% figure;
% plot(-pInhOnDSI(:),-qInhOnDSI(:),'om','LineWidth',1.5);
% hold on
% plot(-pInhOtherDSI(:),-qInhOtherDSI(:),'ok','LineWidth',1.5);
