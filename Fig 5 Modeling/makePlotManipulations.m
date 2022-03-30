% Load data tables

% dTableOO = loadDataTables('v clamp exc','adj bars spds','none','ONOFF');
% dTableOO(10,:) = [];
% dTableOO = dTableOO(~dTableOO.Skeptical,:); %not worth it
% dTableOO = dTableOO(~(dTableOO.Genotype == "Hoxd10VGATChat"),:); % remove KOs
% 
% dTableON = loadDataTables('v clamp exc','adj bars spds','none','ON');
% dTableON = dTableON(~(dTableON.Genotype == "Hoxd10VGATChat"),:); % remove KOs
% dTableON = dTableON(ismissing(dTableON.Notes(:)),:); %remove a few contrast exps

load('Verified Data Tables.mat');

%% interesting example cells;
% indx = 6; complete loss of tuning w/ loss of spatial offset

%% Simulate conductances w/ manipulations

rectifyDSI = true;
rectifyValue = true;

nOO = size(dTableOO,1);

vCtrl = NaN(nOO,10);
dsiCtrl = NaN(nOO,5);

vOffsets = NaN(nOO,10);
dsiOffsets = NaN(nOO,5);
vExc = NaN(nOO,10);
dsiExc = NaN(nOO,5);
vInh = NaN(nOO,10);
dsiInh = NaN(nOO,5);


for i = 1:nOO
    [vCtrl(i,:),dsiCtrl(i,:)] = processData(dTableOO,i);
    [vOffsets(i,:),dsiOffsets(i,:)] = processNoOffsets(dTableOO,i);
    [vExc(i,:),dsiExc(i,:)] = processExcSym(dTableOO,i);
    [vInh(i,:),dsiInh(i,:)] = processInhSym(dTableOO,i);
end

% makes comparisons better
if rectifyDSI
   dsiOffsets(dsiOffsets<0) = 0; 
   dsiExc(dsiExc<0) = 0;
   dsiInh(dsiInh<0) = 0;
end

calcFraction = @(x) (dsiCtrl - x)./dsiCtrl;
offsetValue = calcFraction(dsiOffsets); %dsiCtrl - dsiOffsets;
excValue = calcFraction(dsiExc); %dsiCtrl - dsiExc;
inhValue = calcFraction(dsiInh); %dsiCtrl - dsiInh;

if rectifyValue
    % Check later why these specific trials are actually increasing DSI
   offsetValue(offsetValue < 0) = 0;
   excValue(excValue < 0) = 0;
   inhValue(inhValue < 0) = 0;
end

%% Plot Fractional Loss

hF1 = plotDSI(offsetValue);
title('Offset Fractional DSI Loss')
hF2 = plotDSI(excValue);
title('Exc Fractional DSI Loss')
hF3 = plotDSI(inhValue);
title('Inh Fractional DSI Loss')


%% Other Plots

isPref = "pref";
isNull = "null";

hF1 = plotVoltage(vCtrl * 1e3,isPref,"default");
hF2 = plotVoltage(vOffsets * 1e3,isPref,"default");

linkprop([hF1.Children(1), hF2.Children(1)],{'YTick','YLim'});
set(hF1.Children(1),'Ylim',[0 36],'YTick',0:6:36);

plotDSI(dsiCtrl,"default")

