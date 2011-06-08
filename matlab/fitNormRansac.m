function [lam] = fitNormRansac(feats, showPlot)

%FITNORMRANSAC
%   FITNORMRANSAC(FEATS, PLOT) computes the lambda value of the features
%   list FEATS using RANSAC after rescaling the contrasts over the fitted k
%
%   INPUT:
%       'feat'  :   list of features as parsed by parseFeatures
%
%   OUTPUT:
%       'lam'   :   the computed lambda
%
%   See also PARSEFEATURES, NORMCONTRAST

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/05/16 $

if nargin < 2
    showPlot = 0;
end

feats = normContrast(feats, 'fitExp', showPlot);

% sweeping some outliers
lam = [feats.pars]; lam = lam(2:2:end); % tmp var, not the output
feats(lam > prctile(lam,80)) = [];

% ransacching
[pars ~] = myRansac(feats, showPlot);

lam = pars.lam;

if ~showPlot
    return;
end

figure; grid on; hold on;

plot(0:.01:max([feats.tti]), exp(-(0:.01:max([feats.tti]))/pars.lam), 'y*');
title(['lambda: ', num2str(pars.lam)]);

for ff = feats
    plot(ff.tti, ff.contr, 'o');
end
pause;
close;

end