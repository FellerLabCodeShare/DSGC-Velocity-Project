function [spCts,ctDSI,spHz,hzDSI] = getSummaryData(dTableArray,offWindow)
% Function to process a batch of files from a set of dTables
% [spCts,ctDSI,spHz,hzDSI] = getSummaryData(dTableArray,offWindow)


%% Check inputs
if nargin < 2 || isempty(offWindow)
    offWindow = false;
end

% Ensure supplied dTableArray is all of one data type
% if numel(unique(dTableArray.RecordingType)) > 1 || numel(unique(dTableArray.Stim)) > 1
%     error('dTableArray must be composed of a single stim and recording type.\n');
% end

nVeloc = 10;
nSpds = 5;

%% Collect summary data
nCells = size(dTableArray,1);

% Collect velocity tuning data
% Initialize summary data points
spCts = NaN(nCells,nVeloc);
ctDSI = NaN(nCells,nSpds);
spHz = NaN(nCells,nVeloc);
hzDSI = NaN(nCells,nSpds);

% Collect spike count and peak firing rate data from each cell
for i = 1:nCells
    [ct,ctDSI(i,:),hz,hzDSI(i,:)] = processData(dTableArray,i,false,false,offWindow);
    spCts(i,:) = mean(ct,2);
    spHz(i,:) = mean(hz,2);
end


end