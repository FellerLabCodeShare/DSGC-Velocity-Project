function [excTable,inhTable] = grabCell(cellID)
% Function to grab exc and inh conductances from a given cell
dTableCell = loadDataTables(cellID,'adj bars spds','none');

% Parse out inh
x = find(dTableCell.RecordingType == "v clamp inh");
if isempty(x)
    error('Could not locate inhibition recording for this cell.');
else
    inhTable = dTableCell(x(1),:);
end

% Parse out exc
x = find(dTableCell.RecordingType == "v clamp exc");
if isempty(x)
    error('Could not locate excitation recording for this cell.');
else
    excTable = dTableCell(x(1),:);
end

end