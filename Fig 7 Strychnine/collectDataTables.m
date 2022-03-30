function [dTablePre,dTablePost,dTableExc] = collectDataTables(cType)
% Function to collect strcyhnine data
fprintf('Loading strychnine Data\n');

% Identify cells that have been perfused w/ strychnine;
% Exc doesn't have before data, so load right away
if nargin < 1 || isempty(cType)
    dCells = loadDataTables('strychnine','v clamp inh');
    dTableExc = loadDataTables('v clamp exc','adj bars spds','strychnine');
else
    dCells = loadDataTables('strychnine','v clamp inh',cType);
    dTableExc = loadDataTables('v clamp exc','adj bars spds','strychnine',cType);
end

% Pick out strychnine cells, then sort out before and after data.
cellIDs = unique(dCells.CellID);
nCells = numel(cellIDs);

% Initialize output tables
dTablePre = table('Size',[nCells 15],'VariableTypes',varfun(@class,dTableExc,'OutputFormat','cell'));
dTablePre.Properties.VariableNames = dTableExc.Properties.VariableNames;
dTablePost = dTablePre;

% Load cells sequentially to ensure shared indexing
for i = 1:nCells
    dTablePre(i,:) = loadDataTables(cellIDs(i),'v clamp inh','adj bars spds','none');
    dTablePost(i,:) = loadDataTables(cellIDs(i),'v clamp inh','adj bars spds','strychnine');
end

end