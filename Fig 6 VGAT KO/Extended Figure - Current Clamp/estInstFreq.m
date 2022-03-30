function [peakFR,ifr] = estInstFreq(spTms,respWidth)
% Function to estimate the instantaneous frequency from a provide set of
% spike times using kernel density estimation

if nargin < 2 || isempty(respWidth)
    respWidth = 8; % If no response window width is provided, 8s is longest recording window
end

% Initialize
nTraces = size(spTms,1);
tBins = cell(nTraces,1);
kFilter = cell(nTraces,1);
convType = cell(nTraces,1);

% Kernel parameters
nPts = 5; %10 for 200 ms window, 5 for 100 ms
dt = .01; %10 ms bins

% Generate kernel
kernel = normpdf(-5*nPts:5*nPts,0,nPts); %produce gaussian filter, 10 pt sigma, 2 sigma = width, width is thus 200 ms
kernel = kernel .* (1 / (sum(kernel) * dt)); %normalize
kFilter(:) = {kernel};
convType(:) = {'same'};

% Bin spikes for convolution
t = 0:dt:(respWidth - dt);
tBins(:) = {[t respWidth]};%set time bins, extra timepoint for bin edges
binSpikes = cellfun(@histcounts,spTms,tBins,'Uni',false); % bin spikes

% Convolve kernel and spike bins
ifr = cellfun(@conv,binSpikes,kFilter,convType,'Uni',false);
ifr = cell2mat(ifr)';

% Get peak firing rate
peakFR = max(ifr);

% N = histcounts(spTms,[t tEnd]); %bin spikes, extra timepoint for bin edges
% c = conv(N,kernel,'same'); %filter spike bins with guassian


% [f,xi,bw] = ksdensity(b,0:.01:2.5,'Bandwidth',.05);
% plot(xi,f/bw,'m');

%ksdensity implementation
%    z = (repmat(txi',n,1)-repmat(ty,1,m))/u;
%    f = weight * feval(kernel, z);
% f = exp(-0.5 * z .^2) ./ sqrt(2*pi)


end