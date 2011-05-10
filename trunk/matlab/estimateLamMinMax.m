function [] = estimateLamMinMax(feats, showPlot)

%ESTIMATELAMMINMAX
%   estimateLamMinMax computes lambda as (t_min - t_max)/log(c_max/c_min).
%   This method is too much sensitive to outliers

if ~exist('showPlot','var')
    showPlot = 0;
end

for ii = 1:size(feats,2)
    feats(ii).pars = minMaxContr(feats(ii).contr, feats(ii).tti);
end

% cleaning invalid lambdas
feats = feats([feats.pars]~=-1);
disp(['Now only ', num2str(size(feats,2)), ' feats']);

if showPlot
    hist([feats.pars]);
    title(['mean: ', num2str(mean([feats.pars])), ', median: ', num2str(median([feats.pars]))]);
    disp(' ');
    disp('Estimated lambdas:');
    disp(num2str([feats.pars]));
end

end