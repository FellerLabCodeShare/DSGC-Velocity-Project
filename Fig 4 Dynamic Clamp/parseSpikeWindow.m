function [parseCts,parseTms] = parseSpikeWindow(spTms,tmWindow)
% Function to separate out spikes within a specified time window. 

% Initialize variables
nTrials = numel(spTms);
parseTms = cell(nTrials,1);
parseCts = NaN(nTrials,1);

% For each trial, parse spikes within specified time window
for i = 1:nTrials
    % Check spike times later than tmWindow(1) but earlier than tmWindow(2)
    parseTms{i} = spTms{i}((spTms{i} > tmWindow(1)) & (spTms{i} < tmWindow(2)));
    parseCts(i) = numel(parseTms{i});
end

end