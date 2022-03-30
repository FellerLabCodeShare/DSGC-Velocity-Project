function dTable = collectDataTables(isPSAM)
% Function to collect PSAM or Hoxd10VGATChat data

if nargin < 1 || isPSAM %Default load PSAM data
    isPSAM = true;
end

% Check input
if isPSAM
    
    % Load cells that have been perfused w/ PSEM
    fprintf('Loading PSAM Data\n');
    dCells = loadDataTables('PSEM');
    cellIDs = unique(dCells.CellID);
    nCells = numel(cellIDs);
    for i = 1:nCells
        loadDataTables(cellIDs(i),'adj bars spds');
    end
    
    
    
else
    % Load Hoxd10VGATChat Cells
    fprintf('Loading Hoxd10VGATChat Data\n');
    dTable = loadDataTables('Hoxd10VGATChat','adj bars spds');
end


end