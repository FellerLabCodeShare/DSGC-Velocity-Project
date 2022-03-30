function [spCts,ctDSI,spHz,hzDSI,ctPDs,hzPDs] = getSummaryData(dTableArray,offWindow)
% Function to process a batch of files from a set of dTables
% [spCts,ctDSI,spHz,hzDSI] = getSummaryData(dTableArray,offWindow)


%% Check inputs
if nargin < 2 || isempty(offWindow)
    offWindow = false;
end

% Ensure supplied dTableArray is all of one data type
if numel(unique(dTableArray.RecordingType)) > 1 || numel(unique(dTableArray.Stim)) > 1
    error('dTableArray must be composed of a single stim and recording type.\n');
end

% Ascertain stim type for correct processing
if dTableArray.Stim == "adj bars spds"
    nVeloc = 10;
    nSpds = 5;
    isRDKs = false;
elseif dTableArray.Stim == "wide grates spds"
    nVeloc = 14;
    nSpds = 7;
    isRDKs = false;
elseif dTableArray.Stim == "rdks"
    nDirs = 8;
    isRDKs = true;
else
    error('Unrecognized stim input.')
end

%% Collect summary data
nCells = size(dTableArray,1);

% Process either velocity (bars, gratings) or direction (RDKs) data
if ~isRDKs
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
    
    % No need to provide PDs if velocity stims
    ctPDs = [];
    hzPDs = [];
    
else
    % Collect directional tuning data
    spCts = NaN(nCells,nDirs);
    ctDSI = NaN(nCells,1);
    spHz = NaN(nCells,nDirs);
    hzDSI = NaN(nCells,1);
    ctPDs = NaN(nCells,1);
    hzPDs = NaN(nCells,1);
    
    % Collect spike count and peak firing rate data from each cell
    for i = 1:nCells
        [ct,ctDSI(i,:),hz,hzDSI(i,:),ctPDs(i),hzPDs(i)] = processRDKs(dTableArray,i,false,false);
        spCts(i,:) = mean(ct,2);
        spHz(i,:) = mean(hz,2);
    end
    
end

end