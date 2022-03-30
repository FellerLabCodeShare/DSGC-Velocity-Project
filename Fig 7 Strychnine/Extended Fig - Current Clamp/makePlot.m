% Load c clamp data

% [dOOPre,dOOPost] = collectDataTables('ONOFF');
% [dONPre,dONPost] = collectDataTables('ON');

% dTableOn = loadDataTables('c clamp','ON','strychnine')

onBarsPost = loadDataTables('c clamp','ON','strychnine','adj bars spds');
onGratesPost = loadDataTables('c clamp','ON','strychnine','wide grates spds');

listCells = onBarsPost.CellID;
postIndx = [1 3 4];
onBarsPre = [];
onGratesPre = [];
for i = postIndx % bad way to do this
    dTable = loadDataTables('c clamp','none','adj bars spds',listCells(i));
    onBarsPre = [onBarsPre; dTable];
    dTable = loadDataTables('c clamp','none','wide grates spds',listCells(i));
    onGratesPre = [onGratesPre; dTable];
end

%% Example cell
% Use cell #1 as example cell

processData(onGratesPre,1,true,true)
processData(onGratesPost,1,true,true)

%% Process data

[~,~,preBars,preBarsDSI] = getSummaryData(onBarsPre);
[~,~,preGrates,preGratesDSI] = getSummaryData(onGratesPre);
[~,~,postBars,postBarsDSI] = getSummaryData(onBarsPost);
[~,~,postGrates,postGratesDSI] = getSummaryData(onGratesPost);

% % Calculate speed indices based on preferred direction spiking data
% preSpd = spdIndx(preGrates(:,14),preGrates(:,8));
% postSpd = spdIndx(postGrates(:,14),postGrates(:,8));
% 
% % Ensure each cell has a speed index value
% nonans = true;
% if nonans
%     % Some DSGCs may not spike at neither the lowest nor highest velocity;
%     % ensure a speed index is calculated for these cells by using the next
%     % lowest pref dir speed.
%     x = isnan(preSpd);
%     preSpd(x) = spdIndx(preGrates(x,14),preGrates(x,9));
%     x = isnan(postSpd);
%     postSpd(x) = spdIndx(postGrates(x,14),postGrates(x,9));
% end


%% Plot data

% Velocity tuning curves
plotSpikes(preGrates)
plotSpikes(postGrates)
ylim([0 40]);

% Plot 40 deg/s
hF = plotSpdIndx(onHz(:,13),postGrates(:,13));
% hF = plotPairedSpdIndx(preGrates(:,13),postGrates(postIndx,13));
% plot([1.4 1.6],[mean(postGrates(:,13)) mean(postGrates(:,13))],'-r','linewidth',2)
% plot(1.5,postGrates([2 5],13),'or','linewidth',1);
ylim([0 20]);
hF.Children(1).YTick = 0:5:20;
ylabel('Hz')


% % Plot 40 deg/s
% hF = plotPairedSpdIndx(preGrates(:,13),postGrates(postIndx,13));
% plot([1.4 1.6],[mean(postGrates(:,13)) mean(postGrates(:,13))],'-r','linewidth',2)
% plot(1.5,postGrates([2 5],13),'or','linewidth',1);
% ylim([0 20]);
% hF.Children(1).YTick = 0:5:20;
% ylabel('Hz')

% Plot DSI
plotDSI(postGratesDSI)





