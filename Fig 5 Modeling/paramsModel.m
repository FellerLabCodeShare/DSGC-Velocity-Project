classdef paramsModel
    % Object to contain default parallel conductance model parameters
    
    properties (Constant)
        eExc = 0e-3; % excitatory reversal potential
        eInh = -60e-3; % inhibitory reversal potential
        eLeak = -55e-3; % leak reversal potential
        gLeak = 4.2e-9; % nS leak conductance %formerly 5 nS
        cap = 80e-12; % pF capacitance %formerly 120 pF
        dt = 1e-4; % 100 microsecond sampling interval
        nPtsOld = 8e4; % 8s recording number of points for old recordings
        nPtsSOS = 6e4;
        stimSpds = [-58.1 -38.7 -19.4 -9.7 -4.8 4.8 9.7 19.4 38.7 58.1]; %stim spds in deg/s
    end
    
    methods (Static)
        
        function nPts = checkType(dTable,indx)
            % Function to check recording types to determine model
            % parameters
            if nargin < 2 || isempty(indx)
                indx = 1;
            end
            
            % Older recordings were 8 sec, newer recordings 6 sec
            if dTable.Rig(indx) == "SOS"
                nPts = paramsModel.nPtsSOS;
            elseif dTable.Rig(indx) == "pre-DMD SOS"
                nPts = paramsModel.nPtsOld;
            end
        end
        
    end
    
end
