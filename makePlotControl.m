%% Modelling

%getSummaryData
%handleModel
%grabCell
%grabConductance
%runModel
%processData

% "201203004" looks good for ONOFF

dTableOO = loadDataTables('v clamp exc','adj bars spds','none','ONOFF');
dTableOO(10,:) = [];
dTableOO = dTableOO(~dTableOO.Skeptical,:); %not worth it
dTableOO = dTableOO(~(dTableOO.Genotype == "Hoxd10VGATChat"),:); % remove KOs

dTableON = loadDataTables('v clamp exc','adj bars spds','none','ON');
dTableON = dTableON(~(dTableON.Genotype == "Hoxd10VGATChat"),:); % remove KOs
dTableON = dTableON(ismissing(dTableON.Notes(:)),:); %remove a few contrast exps

%% Example Cell
% from 'verified data tables'
% Used ONOFF example: 10, pIndx = 6
indx = 11;
processData(dTableOO,indx)

%%

% Consider lowpass filtering voltage output for more similar results?
nOO = size(dTableOO,1);

vOO = NaN(nOO,10);
dsiOO = NaN(nOO,5);

for i = 1:nOO
    [vOO(i,:),dsiOO(i,:)] = processData(dTableOO,i);
end

%% Plot

isPref = "pref";
isNull = "null";

hF1 = plotVoltage(vOO * 1e3,isPref,"default");
hF2 = plotVoltage(vOO * 1e3,isNull,"default");

linkprop([hF1.Children(1), hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'Ylim',[0 36],'YTick',0:6:36);

plotDSI(dsiOO,"default")


