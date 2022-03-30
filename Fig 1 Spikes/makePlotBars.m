%% Tools to make Figure 1

% Gather data (revise this - dyclamp not yet added, replace with static list)
%%%% check 190306 analysis %%%%
% dTableOn = loadDataTables('ON','c clamp','adj bars spds','none');
% dTableOn = dTableOn(~dTableOn.Skeptical,:);
% 
% dTableOO = loadDataTables('ONOFF','c clamp','adj bars spds','none');
% dTableOO = dTableOO(~dTableOO.Skeptical,:);

load("Bars Data Tables.mat");

%% Validate data
% Run individual cells with plotting turned on
dTable = dTableOO;
indx = 3;
% Example Cells:
% On: Used 17 (other options: 5, 10, 13, 16, 20)
% OnOff: Used 3 (another option: 7)

processData(dTable,indx,true,true);

%% Process data

rectifyDSI = true; % flag to prevent DSIs from being negative

% Sequentially process each data table entry, output summary values
[onCt,onCtDSI,onHz,onHzDSI] = getSummaryData(dTableOn);
[ooCt,ooCtDSI,ooHz,ooHzDSI] = getSummaryData(dTableOO);

% Consider null direction spikes as noise, rectify DSIs to be 0 minimum
if rectifyDSI
    onHzDSI(onHzDSI < 0) = 0;
    ooHzDSI(ooHzDSI < 0) = 0;
    fprintf('Rectifying spike DSIs.\n');
end

% Calculate speed indices based on preferred direction spiking data
onSpd = spdIndx(onHz(:,10),onHz(:,6));
ooSpd = spdIndx(ooHz(:,10),ooHz(:,6));

% Normalize spikes
onHzNorm = onHz(:,6:10) ./ max(onHz,[],2);
ooHzNorm = ooHz(:,6:10) ./ max(ooHz,[],2);

%% Create fit plots

% Exponential fits (w/ offset)
hF1 = plotFit(onHzNorm,'ON');
hF2 = plotFit(ooHzNorm,'default');

copyobj(allchild(hF1.Children(1)),hF2.Children(1))

% Histogram insets
plotSpdHist(ooSpd,onSpd)
plotSpdHist(onHzDSI(:,1),onHzDSI(:,5));

% Overlaid averages
hF1 = plotAvg(onHzDSI,'ON');
hF2 = plotAvg(ooHzDSI,'default');

% Plot DSI histogram
[~,topSpd] = max(onHz(:,6:10),[],2);
indx = sub2ind(size(onHzDSI),(1:size(onHzDSI,1))',topSpd);
% Used 0:.1:1 bins
plotSpdHist(mean(ooHzDSI,2),onHzDSI(indx))
xlim([0 1]);
ylim([0 .4])
set(gca,'YTick',0:.2:.4);
xlabel('DS Index');
% plotSpdHist(mean(ooHzDSI(indx),2),%onHzDSI(:,indx))

%% Extended figures

% Set plotting parameters
isPref = true;
isNull = false;
isHz = true;
isCt = false;

% Maximal 

% DSI Variance
figure;
plot(plotVals.pSpdsBars,nanvar(ooHzDSI),'linewidth',2,'Color',plotVals.getColor("default"))
hold on
plot(plotVals.pSpdsBars,nanvar(onHzDSI),'linewidth',2,'Color',plotVals.getColor("ON"))
xlim(plotVals.xRange)

copyobj(allchild(hF1.Children(1)),hF2.Children(1))

% Cell-wise Plots

hF = plotSpikes(onHz,isPref,isHz,'ON',false);
hF.Children.YTick = 0:15:75;
hF.Children.YLim = [0 75];
plotSpikes(ooHz,isPref,isHz,'default',false)

plotDSI(onHzDSI,'ON')
plotDSI(ooHzDSI,'default')

plotSpdIndx(ooSpd,onSpd)

% Check analysis window based on cell type
tmWindow = cSpdsTimes.CheckWindowTimes(dTable,indx,offWindow);

