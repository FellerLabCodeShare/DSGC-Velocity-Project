function out = spdIndx(x,y)
% Function to calculate speed index; x should be high speed, y low speed.
% Outputs close to one imply tuning for high speeds, negative one tuning
% for slow speeds, and zero implies minimal speed tuning.

% Calculate speed index
out = (x-y)./(x+y);

% Bound outputs between -1 and 1 (only becomes an issue with negative input
% values, which sometimes happens w/ DSIs)
out(out > 1) = 1;
out(out < -1) = -1;

end