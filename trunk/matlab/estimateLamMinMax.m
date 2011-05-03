function [] = estimateLamMinMax(feats, showPlot)

if ~exist('showPlot','var')
    showPlot = 0;
end

% compute pars by minMax, delete the feature if min and max are too close
for ii = size(feats,2):-1:1
    [vMax iMax] = max(feats(ii).contr);
    [vMin iMin] = min(feats(ii).contr);
    if abs(iMin-iMax) > .5*feats(ii).num
        feats(ii).pars = (feats(ii).tti(iMin)-feats(ii).tti(iMax))/log(vMax/vMin);
    else
        feats(ii) = [];
    end
end

disp(['Now only ', num2str(size(feats,2)), ' feats']);

if showPlot
    hist([feats.pars]);
    title(['mean: ', num2str(mean([feats.pars])), ', median: ', num2str(median([feats.pars]))]);
end

end