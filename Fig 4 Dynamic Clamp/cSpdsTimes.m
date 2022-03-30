classdef cSpdsTimes
    %Class to define windows from which to draw data 'adj bar spds' type
    %stims for 'c clamp' type recording data.
    
    properties (Constant)
        % On window times for current SOS DMD setup
        onSOS = [0 2.5];
        ooSOS = [0 2.5];
        offSOS = [2.5 5];
        % On window times for old SOS DMD setup
        onOld = [1 3];
        ooOld = [1 3];
        offOld = [4.3 6];
    end
    
    methods (Static)
        
        function tm = CheckWindowTimes(dTable,indx,offWindow)
            % Function to check appropriate time windows for analysis for a
            % given cell type. Checks cell type, and then rig setup at time
            % of recording based on dTable entries. Returns ON window,
            % unless OFF window is specified in inputs.
            if nargin < 3 || isempty(offWindow)
                offWindow = false;
            end
            
            if nargin < 2 || isempty(indx)
                indx = 1;
            end
            
            % Determine window timing based on input type
            if offWindow
                % Use off window, regardless of cell type.
                % Check DMD setup at time of recording:
                if dTable.Rig(indx) == "SOS"
                    tm = cSpdsTimes.offSOS;
                elseif dTable.Rig(indx) == "pre-DMD SOS"
                    tm = cSpdsTimes.offOld;
                end
            else
                % Check cell type, and use appropriate on window
                if dTable.CellType(indx) == "ON"
                    % Use ON DSGC window
                    % Check DMD setup at time of recording:
                    if dTable.Rig(indx) == "SOS"
                        tm = cSpdsTimes.onSOS;
                    elseif dTable.Rig(indx) == "pre-DMD SOS"
                        tm = cSpdsTimes.onOld;
                    end
                elseif dTable.CellType(indx) == "ONOFF"
                    % Use OnOff DSGC on window
                    % Check DMD setup at time of recording:
                    if dTable.Rig(indx) == "SOS"
                        tm = cSpdsTimes.ooSOS;
                    elseif dTable.Rig(indx) == "pre-DMD SOS"
                        tm = cSpdsTimes.ooOld;
                    end
                end
            end
            % Return appropriate window "tm".
        end
        
    end
    
end