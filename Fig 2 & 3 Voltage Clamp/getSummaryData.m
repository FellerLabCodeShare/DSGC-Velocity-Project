function [pCur,pDSI,qCur,qDSI,pAsym,qAsym,pBlank] = getSummaryData(dTableArray,offWindow)
% Function to sequentially process a set of dTable inputs

%% Check inputs

if nargin < 2 || isempty(offWindow)
    offWindow = false;
end

% Ensure supplied dTableArray is all of one data type
if numel(unique(dTableArray.RecordingType)) > 1 || numel(unique(dTableArray.Stim)) > 1
    error('dTableArray must be composed of a single stim and recording type.\n');
end

%% Collect summary data
nRecordings = size(dTableArray,1);

% Initialize summary data points
pCur = NaN(nRecordings,10);
pDSI = NaN(nRecordings,5);
qCur = NaN(nRecordings,10);
qDSI = NaN(nRecordings,5);
pBlank = NaN(nRecordings,1);

% Collect mean peak currents and total charge transfer for each recording
for i = 1:nRecordings
    [p,pDSI(i,:),q,qDSI(i,:),pHold] = processData(dTableArray,i,false,false,offWindow);
    pCur(i,:) = mean(p,2);
    qCur(i,:) = mean(q,2);
    pBlank(i) = mean(pHold);
end

if dTableArray.RecordingType == "v clamp inh"
    pAsym = pCur(:,5:-1:1) - pCur(:,6:10); % Calculate asymmetric current by
    % subtracting "pref" or "symmetric" IPSC from null current
    qAsym = qCur(:,5:-1:1) - qCur(:,6:10);
else
    pAsym = pCur(:,6:10) - pCur(:,5:-1:1); % Calculate asymmetric current by
    % subtracting "null" or "symmetric" EPSC from pref current
    qAsym = qCur(:,6:10) - qCur(:,5:-1:1);
end

end