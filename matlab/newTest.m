function [asd] = newTest(feats, showPlot)

% 0 = ln(max/min)/(t2-t1)
% 1 = fit norm data over k
TEST = 1;

if TEST == 0   % ln(max/min)/(t2-t1). Ignore positive values
    for ii = 1:max(size(feats))
        [ma ima] = max(feats(ii).contr(1:end-1));
        [mi imi] = min(feats(ii).contr(1:end-1));
        feats(ii).pars = log(ma/mi)/(feats(ii).tti(ima)-feats(ii).tti(imi));
    end
    
elseif TEST == 1
    
    plotContrasts(feats);
    
end

asd = rand();

end