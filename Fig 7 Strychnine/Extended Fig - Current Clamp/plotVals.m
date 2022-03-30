classdef plotVals
    % Class to define default plotting values
    
    properties (Constant)
        % Stim parameters
        pSpdsBars = [4.8 9.7 19.4 38.7 58.1];
        pSpdsGrates = [1.6 3.2 4.8 9.7 19.4 38.7 58.1];
        xTicks = [5 10 20 40 60];
        xRange = [0 64];
        % Yaxis parameters (update these values)
        spLim = [0 200];
        hzLim = [0 200];
        spTick = 0:20:200;
        hzTick = 0:20:200;
        % Color plotting values
        defaultAlpha = .3;
        defaultColor = [.2 .2 .2];
        onColor = [.61 .27 .6]; %[ .68 .41 .68 ];
        ooColor = [ .31 .7 .83 ];
        otherColor = [ .45 .77 .46];
    end
    
    methods (Static)
        
        function outColor = getColor(cType,useAlpha)
            % Function to determine color to use for a given input type
            
            if nargin < 2 || isempty(useAlpha) % flag to implement alpha
                useAlpha = false;
            end
            
            if nargin < 1 || isempty(cType) % which color to use
                cType = 'default';
            end
            
            % Return RGB values for specified data type
            switch cType
                case "ON"
                    outColor = plotVals.onColor;
                case "ONOFF"
                    outColor = plotVals.ooColor;
                case "Other"
                    outColor = plotVals.otherColor;
                otherwise
                    outColor = plotVals.defaultColor;
            end
            
            % Add alpha blending
            if useAlpha
                outColor = [outColor plotVals.defaultAlpha];
            end
            
        end
    end
    
end


%%%% RGB values from: https://github.com/timothyrenner/ColorBrewer.jl/blob/master/data/colorbrewer.json

%         onColor = [ .73 .89 .7 ];
%         ooColor = [ .19 .64 .33 ];
%         otherColor = [ .45 .77 .46];


