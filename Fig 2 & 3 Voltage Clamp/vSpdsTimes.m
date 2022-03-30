classdef vSpdsTimes
    %Class to define windows from which to draw data 'adj bar spds' type
    %stims for 'v clamp inh' or 'v clamp exc' type recording data.
    
    properties (Constant)
        % On window times for current SOS DMD setup
        onWindowSOS = [0 2.5];
        ooWindowSOS = [0 2.5];
        offWindowSOS = [2.5 5];
        % On window times for old SOS DMD setup
        onWindowOld = [1 3];
        ooWindowOld = [1 3];
        offWindowOld = [3 6];
        % Holding current window for present and old setup
        holdSOS = [5.5 6];
        holdOld = [0 .5];
    end
    
    methods (Static)
        
        function [tm,hold] = CheckWindowTimes(dTable,indx,offWindow)
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
                    tm = vSpdsTimes.offWindowSOS;
                elseif dTable.Rig(indx) == "pre-DMD SOS"
                    tm = vSpdsTimes.offWindowOld;
                end
            else
                % Check cell type, and use appropriate on window
                if dTable.CellType(indx) == "ON"
                    % Use ON DSGC window
                    % Check DMD setup at time of recording:
                    if dTable.Rig(indx) == "SOS"
                        tm = vSpdsTimes.onWindowSOS;
                    elseif dTable.Rig(indx) == "pre-DMD SOS"
                        tm = vSpdsTimes.onWindowOld;
                    end
                elseif dTable.CellType(indx) == "ONOFF"
                    % Use OnOff DSGC on window
                    % Check DMD setup at time of recording:
                    if dTable.Rig(indx) == "SOS"
                        tm = vSpdsTimes.ooWindowSOS;
                    elseif dTable.Rig(indx) == "pre-DMD SOS"
                        tm = vSpdsTimes.ooWindowOld;
                    end
                end
            end
            
            % Check which holding current window to return
            if dTable.Rig(indx) == "SOS"
                hold = vSpdsTimes.holdSOS;
            elseif dTable.Rig(indx) == "pre-DMD SOS"
                hold = vSpdsTimes.holdOld;
            end
            
            % Return appropriate windows "tm" and "hold".
        end
        
    end
    
end