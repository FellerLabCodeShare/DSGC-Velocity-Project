function [d,stimCond,spCts,spTms] = fetchData(dTable,indx)
% Function to load recording and stim data for a given dTable index
if nargin < 2 || isempty(indx)
    indx = 1;
end

% Load data
quickLoad(dTable.AcquisitionNumber(indx),dTable.Date(indx),true);

% Check recording type; get spikes if current clamp or cell attached
if (dTable.RecordingType(indx) == "c clamp") || ...
        (dTable.RecordingType(indx) == "dy clamp")
    quickSpikes(d,si,true);
elseif dTable.RecordingType(indx) == "c attach"
    quickSpikes(d,si,false);
else
    spCts = [];
    spTms = [];
end

% Check stim type; load stim info if appropriate
if (dTable.Stim(indx) == "ds bars fast") || ...
        (dTable.Stim(indx) == "ds bars slow") || ...
        (dTable.Stim(indx) == "rdks")
    % If a directional stimulus, use index 1
    quickStim(dTable.AcquisitionNumber(indx),dTable.Date(indx));
    stimCond = stimInfo(:,1);
elseif (dTable.Stim(indx) == "adj bars spds") || ...
        (dTable.Stim(indx) == "short bars spds")
    % If a speed stimulus, use index 2
    quickStim(dTable.AcquisitionNumber(indx),dTable.Date(indx));
    stimCond = stimInfo(:,2);
elseif (dTable.Stim(indx) == "wide grates spd"')
    % Gratings are speed stimuli, but require indexing of negative speeds
    quickStim(dTable.AcquisitionNumber(indx),dTable.Date(indx));
    stimCond = stimInfo(:,3); % temporal frequencies
    % Identify null direction based on spike counts (manually validated
    % this method on 2/22/21)
    dirIndx = stimInfo(:,1) >= 180;
    if sum(spCts(dirIndx)) > sum(spCts(~dirIndx)) % Flip the direction w/ fewer spikes
        stimCond(~dirIndx) = -stimCond(~dirIndx);
    else
        stimCond(dirIndx) = -stimCond(dirIndx);
    end
elseif (dTable.Stim(indx) == "gOO") || (dTable.Stim(indx) == "gON")
    % Dynamic Clamp conductance experiments load stim indexing from a
    % centralized file
    if dTable.Rig(indx) == "SOS" % 2nd iteration conductance traces
        sIndx = load('DyClampStim 210120.txt');
    else % 1st iteration conductance traces
        sIndx = load('DyClampStim 200115.txt');
    end
    % Re-derive stim velocities of original conductanes
    stimVals = [-1800 -1200 -600 -300 -150 150 300 600 1200 1800]; %in um/sec
    stimCond = stimVals(sIndx);
    
else
    fprintf('Found no stim files for this recording.');
    stimCond = [];
end

end