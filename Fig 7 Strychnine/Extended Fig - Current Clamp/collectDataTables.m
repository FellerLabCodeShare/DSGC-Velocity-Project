function [dTablePre,dTablePost] = collectDataTables(cType)
% Function to collect strcyhnine data
fprintf('Loading strychnine Data\n');

% Identify cells that have been perfused w/ strychnine;
% Exc doesn't have before data, so load right away
if nargin < 1 || isempty(cType)
    dCells = loadDataTables('strychnine','c clamp');
else
    dCells = loadDataTables('strychnine','c clamp',cType);
end

% Pick out strychnine cells, then sort out before and after data.
cellIDs = unique(dCells.CellID);
nCells = numel(cellIDs);

% Initialize output tables
dTablePre = table('Size',[nCells 15],'VariableTypes',varfun(@class,dCells,'OutputFormat','cell'));
dTablePre.Properties.VariableNames = dCells.Properties.VariableNames;
dTablePost = dTablePre;

% Load cells sequentially to ensure shared indexing
for i = 1:nCells
    dTablePre(i,:) = loadDataTables(cellIDs(i),'c clamp','adj bars spds','none');
    dTablePost(i,:) = loadDataTables(cellIDs(i),'c clamp','adj bars spds','strychnine');
end

end