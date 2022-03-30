function [pDSI,pVec,permDSI,permVec] = calcPermTest(ctSort,stimDirs,nTries,showPlot)

if nargin < 4 || isempty(showPlot)
    showPlot = false;
end

if nargin < 3 || isempty(nTries)
    nTries = 1000;
end

[nDirs,nReps] = size(ctSort);
permDSI = NaN(nTries,1);
permVec = NaN(nTries,1);

[~,~,actualDSI,actualVec] = dirTuning(ctSort,stimDirs,1);

if nReps == 3
    for i = 1:nTries
        permIndx = [randperm(nDirs); (randperm(nDirs) + nDirs); (randperm(nDirs) + 2*nDirs)]';
        [~,~,permDSI(i),permVec(i)] = dirTuning(ctSort(permIndx),stimDirs,1);
    end
elseif nReps == 2
    for i = 1:nTries
        permIndx = [randperm(nDirs); (randperm(nDirs) + nDirs)]';
        [~,~,permDSI(i),permVec(i)] = dirTuning(ctSort(permIndx),stimDirs,1);
    end
else
    error('Unrecognized number of reps.')
end

pDSI = sum(actualDSI > permDSI) / nTries;
pVec = sum(actualVec > permVec) / nTries;

if showPlot
    hF = figure;
    hA = cdfplot(permDSI);
    hold on
    plot(actualDSI,pDSI,'or','markersize',7,'linewidth',1.4)
    plot([actualDSI,actualDSI],[0 pDSI],'--r','linewidth',.8);
    plot([hF.Children.XTick(1) actualDSI],[pDSI,pDSI],'--r','linewidth',.8);
    set(hA,'linewidth',1.4,'color','k');
    hF.Children.YTick = 0:.2:1;
    xlabel('DSI')
    ylabel('Cumulative Probability')
    titleStr = sprintf('DSI - Null Distribution (%3.1f%% on %i runs)',pDSI*100,nTries);
    title(titleStr)
    
    hF = figure;
    hA = cdfplot(permVec);
    hold on
    plot(actualVec,pVec,'or','markersize',7,'linewidth',1.4)
    plot([actualVec,actualVec],[0 pVec],'--r','linewidth',.8);
    plot([hF.Children.XTick(1) actualVec],[pVec,pVec],'--r','linewidth',.8);
    set(hA,'linewidth',1.4,'color','k');
    hF.Children.YTick = 0:.2:1;
    xlabel('Vec Sum')
    ylabel('Cumulative Probability')    
    titleStr = sprintf('Vec Sum - Null Distribution (%3.1f%% on %i runs)',pVec*100,nTries);
    title(titleStr)
end

end