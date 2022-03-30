% Script to make Hoxd10.VGAT.Chat KO spike recording figures

% Load "ooSpikesKO" data table
load("ONOFF Spikes Data Table.mat");

% Load ON spike example
load("ON Depolarization Data Table.mat");

%% Example Cell
indx = 4;

processData(ooSpikesKO,indx,true,true)

% Example ON depolarization
processData(onDepolKO,1,true,true)

%% Process Data

[~,~,ooHzKO,ooDSIKO] = getSummaryData(ooSpikesKO);

koSpdIndx = spdIndx(ooHzKO(:,10),ooHzKO(:,6));

%% Plot Figures

% Plot spike velocity tuning
hF1 = plotSpikes(ooHzKO);
ylim([0 160]);
set(hF1.Children,'YTick',0:40:160);

% Plot DSI
plotDSI(ooDSIKO)

% Plot spd indx
plotSpdIndx(koSpdIndx,koSpdIndx)


