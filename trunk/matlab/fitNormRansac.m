function [lam] = fitNormRansac(feats, showPlot)

%THENEWWAY
%
%   something

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/09 11:59:22 $


normType = 'fitExp';
func = 'exp';

feats = normContrast(feats, normType, showPlot);


% sweeping some outliers
switch normType
    case 'fitExp'   % remove too high lambdas
        lam = [feats.pars]; lam = lam(2:2:end);
        feats(lam > prctile(lam,80)) = [];
        clear lam;
end

% ransacching
[pars ~] = myRansac(feats, normType, func, showPlot);

if showPlot
    figure; grid on; hold on;
    
    plot(0:.01:max([feats.tti]), exp(-(0:.01:max([feats.tti]))/pars.lam), 'y*');
    title(['lambda: ', num2str(pars.lam)]);
        
    for ff = feats
        plot(ff.tti, ff.contr, 'o');
    end
    pause;
    close;
end

lam = pars.lam;

end