function dTable = collectDataTables()
% Function to collect dynamic clamp data

% Load cells that have been perfused w/ strychnine
fprintf('Loading dynamic clamp Data\n');
dCells = loadDataTables('dy clamp');
cellIDs = unique(dCells.CellID);
nCells = numel(cellIDs);
for i = 1:nCells
    loadDataTables(cellIDs(i),'adj bars spds');
end



end