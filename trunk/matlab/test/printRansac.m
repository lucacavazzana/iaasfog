function [] = printRansac(feats)

feats = normContrast(feats, 'fitExp', 0);
% lam = [feats.pars]; lam = lam(2:2:end); % tmp var, not the output
% feats(lam > prctile(lam,80)) = [];

myRansacTest(feats);

end