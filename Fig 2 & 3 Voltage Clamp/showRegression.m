function showRegression(x,y)
% For each speed, compute regression of X and Y, where X is DSI of peak
% current and Y is DSI of total charge transfer.
figure;
% for i = 1:5
%     plot(x(:,i),y(:,i),'ok')
%     hold on
%     pp = polyfit(x(:,i),y(:,i),1)
%     resid = y(:,i) - polyval(pp,x(:,i));
%     ssResid = sum(resid.^2);
%     ttResid = (numel(x(:,i)) - 1) * var(y(:,i));
%     rSq = 1 - ssResid / ttResid
%     xlim([0 1]); ylim([0 1]);
% end

    plot(x(:),y(:),'ok')
    hold on
    pp = polyfit(x(:),y(:),1)
    plot(x(:),polyval(pp,x(:)),'r');
    resid = y(:) - polyval(pp,x(:));
    ssResid = sum(resid.^2);
    ttResid = (numel(x(:)) - 1) * var(y(:));
    rSq = 1 - ssResid / ttResid
%     xlim([0 1]); ylim([0 1]);


end