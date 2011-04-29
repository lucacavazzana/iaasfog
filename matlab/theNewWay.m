function [] = theNewWay(feats, showPlots)

%THENEWWAY
%
%   something

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/09 11:59:22 $



normType = 'fitExp';

feats = normContrast(feats, normType);

[pars ~] = myRansac(feats, normType, 'exp', showPlots);
% [pars ~] = findPars(feats, 1/25, normType, 'exp', showPlots);

disp(' ');
disp('- result:')
disp(pars.lam);

end