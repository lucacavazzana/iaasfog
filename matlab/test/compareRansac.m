function [] = compareRansac(feats)

feats = normContrast(feats, 'fitExp', 0);
lam = [feats.pars]; lam = lam(2:2:end); % tmp var, not the output
feats(lam > prctile(lam,80)) = [];

ps = [];
for ii = 1:50
    [p ~] = myRansac(feats,0);
    ps = [ps, p.lam];
    disp(['it ', num2str(ii)]);
end

hist(ps);
title(['mean: ',num2str(mean(ps)),', median: ',num2str(median(ps))]);
print('-deps','multiRansac.eps');
print('-dpng','multiRansac.png');

end