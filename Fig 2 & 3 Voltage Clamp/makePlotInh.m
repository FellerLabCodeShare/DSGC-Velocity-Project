%% Tools to make Figure 2

% Gather data 
% dTableInhOn = loadDataTables('ON','v clamp inh','adj bars spds','none');
% dTableInhOn = dTableInhOn(~dTableInhOn.Skeptical,:); %not worth it
% dTableInhOn = dTableInhOn(ismissing(dTableInhOn.Notes(:)),:); %remove a few contrast exps
% dTableInhOn = dTableInhOn(~(dTableInhOn.Genotype == "Hoxd10VGATChat"),:); % remove KOs
load('On Inh Table.mat');


% Can separate out OO into Hox and Trhr/Drd4 later, if desired
% dTableInhOther = loadDataTables('ONOFF','v clamp inh','adj bars spds','none'); 
% dTableInhOther = dTableInhOther(~dTableInhOther.Skeptical,:);
% dTableInhOther(dTableInhOther.CellID == "201005004",:) = []; % weird cell, need for strychnine datasetbut not worth analysis here
% dTableInhOther = dTableInhOther(~(dTableInhOther.Genotype == "Hoxd10VGATChat"),:); % remove KOs
load('OnOff Inh Table.mat');

%On #3, 7 not tuned
%On #10, #12, #30 messy

%% Validate data
%Paper example cells:
%ONOFF; indx = 22
%ON; indx = 16(27)

dTable = dTableInhOther;
indx = 16;

processData(dTable,indx,true,true);

%% Process data

% Get summary data
[pInhOn,pInhOnDSI,qInhOn,qInhOnDSI,pInhOnAsym,qInhOnAsym,pBlankOn] = getSummaryData(dTableInhOn);
% [pInhHox,pInhHoxDSI,qInhHox,qInhHoxDSI,pInhHoxAsym,qInhHoxAsym] = getSummaryData(dTableInhHoxOO);
[pInhOther,pInhOtherDSI,qInhOther,qInhOtherDSI,pInhOtherAsym,qInhOtherAsym,pBlankOther] = getSummaryData(dTableInhOther);

% Calculate speed indices (symmetric)
onInhSymSpdIndx = spdIndx(pInhOn(:,10),pInhOn(:,6));
otherInhSymSpdIndx = spdIndx(pInhOther(:,10),pInhOther(:,6));

% Calculate speed indices (asymmetric)
onInhAsymSpdIndx = spdIndx(pInhOnAsym(:,5),pInhOnAsym(:,1));
otherInhAsymSpdIndx = spdIndx(pInhOtherAsym(:,5),pInhOtherAsym(:,1));

% Normalize currents
pInhOnSymNorm = pInhOn(:,6:10) ./ max(pInhOn,[],2);
pInhOnAsymNorm = pInhOnAsym ./ max(pInhOn,[],2);

pInhOtherSymNorm = pInhOther(:,6:10) ./ max(pInhOther,[],2);
pInhOtherAsymNorm = pInhOtherAsym ./ max(pInhOther,[],2);

rectifyDSI = true;
if rectifyDSI % Only necessary for charge transfer
    qInhOtherDSI(qInhOtherDSI > 0) = 0;
    qInhOnDSI(qInhOnDSI > 0) = 0;
end

%% Plotting flags

isPref = "pref";
isNull = "null";
isCharge = true;
isCur = false;
doNorm = true;
noNorm = false;

%% Plot fits
% Exponential fits (w/ offset)
hF1 = plotFit(pInhOnSymNorm,'ON');
hF2 = plotFit(pInhOtherSymNorm,'default');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))
ylim([0 .8]);

% Histogram insets
plotSpdHist(otherInhSymSpdIndx,onInhSymSpdIndx)

% Overlaid averages
hF1 = plotAvg(pInhOnAsymNorm,'ON');
hF2 = plotAvg(pInhOtherAsymNorm,'default');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))
ylim([0 .8]);

%% Plot data (Main Figures)

% Flip DSI because null direction inh is greater
plotDSI(-pInhOnDSI,'ON')
plotDSI(-pInhOtherDSI,'default')

hF1 = plotCurrents(pInhOn,isPref,isCur,'ON',false);
hF2 = plotCurrents(pInhOnAsym,"none",isCur,'ON',false);

linkprop([hF1.Children(1), hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'Ylim',[0 2000],'YTick',0:500:2000);

hF3 = plotCurrents(pInhOther,isPref,isCur,'default',false);
hF4 = plotCurrents(pInhOtherAsym,"none",isCur,'default',false);

linkprop([hF3.Children(1), hF4.Children(1)],{'YTick','YLim'});
set(hF3.Children(1),'Ylim',[0 2000],'YTick',0:500:2000);

% Plot spd indx of symmetric and asymmetric
hF5 = plotSpdIndx(otherInhSymSpdIndx,otherInhAsymSpdIndx);
set(hF5.Children(1).Children(:),'Color',plotVals.defaultColor);
set(hF5.Children(1),'XTickLabel',{"Sym Inh","Asym Inh"})

% Plot spd indx of symmetric and asymmetric
hF6 = plotSpdIndx(onInhSymSpdIndx,onInhAsymSpdIndx);
set(hF6.Children(1).Children(:),'Color',plotVals.onColor);
set(hF6.Children(1),'XTickLabel',{"Sym Inh","Asym Inh"})

%% Statistical tests

%% Plot data (Extended Figures)

% Show relationship between peak and charge transfer
plotScatter(qInhOther,pInhOther,false,'default')
plotScatter(qInhOn,pInhOn,false,'ON');
xlim([0 2250]);
ylim([0 2250]);

% Show Q vs P DSI relationship
plotScatter(-qInhOtherDSI,-pInhOtherDSI,true,'default');
plotScatter(-qInhOnDSI,-pInhOnDSI,true,'ON');



% Compare cell types
plotSpdIndx(otherInhSymSpdIndx,onInhSymSpdIndx);
ylim([-.5 1])


% Plot peak vs charge transfer
% figure;
% plot(-pInhOtherDSI,-qInhOtherDSI,'ok')
% xlim([-.1 .8]);
% ylim([-.1 .8]);

%%% REMAINS TO BE DONE: %%%
% DO CHARGE VS PEAK DSI
% consider highlighting trhr vs hoxd10 ONOFF DSGCs

% peak vs charge DSI plot
% figure;
% plot(-pInhOnDSI(:),-qInhOnDSI(:),'om','LineWidth',1.5);
% hold on
% plot(-pInhOtherDSI(:),-qInhOtherDSI(:),'ok','LineWidth',1.5);
