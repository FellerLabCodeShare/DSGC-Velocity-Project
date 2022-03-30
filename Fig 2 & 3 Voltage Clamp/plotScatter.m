function hF = plotScatter(x,y,isDSI,cType)
% Function to plot relationship between two variables, with or without
% linear fit.

if nargin < 4 || isempty(cType)
    cType = 'default';
end

if nargin < 3 || isempty(isDSI)
    isDSI = false;
end

%% Prepare figure

% Perform linear fit unless DSI plot is requested

if ~isDSI
    % Get linear fit
    pp = polyfit(x(:),y(:),1);
    
    % Calculate R^2
    yFit = polyval(pp,x(:));
    ssResid = sum((y(:) - yFit).^2);
    ssTotal = (numel(y) - 1) * var(y(:));
    rSq = 1 - ssResid/ssTotal;
    
    % Print linear fit results
    fprintf('Linear fit: y = %3.2f * x + %3.2f, R^2 = %3.3f\n',pp(1),pp(2),rSq);
        
    % Plot params
    xRange = [min(x(:)) max(x(:))];
    yPlot = polyval(pp,xRange);
end


% Create figure
hF = figure;

%% Plot data

if isDSI % Set DSI axes parameters
    plot([0 1],[0 1],'Color',[.4 .4 .4]); % Unity line
    xlabel('Charge Transfer DSI');
    ylabel('Peak Current DSI');
    set(gca,'YTick',-1:.25:1);
    set(gca,'XTick',-1:.25:1);
    xlim([0 1]);
    ylim([0 1]);
else % Set current/charge axes parameters
    plot(xRange,yPlot,'Color',plotVals.getColor(cType));
    ylabel('Peak Current (pA)');
    xlabel('Charge Transfer (pC)');
    set(gca,'YTick',0:500:5000);
    set(gca,'XTick',0:500:5000);
%     xlim([0 3000]);
%     ylim([0 3000]);
end
hold on
plot(x(:),y(:),'o','linewidth',1,'Color',plotVals.getColor(cType));

set(gca,'Box','off');

end
