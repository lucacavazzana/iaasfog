function [lam] = estimateLamFit(feats, showPlot)

%ESTIMATELAMFIT    estimates lambda of the contrast function.
%   ESTIMATELAMFIT(FEATS, SHOWPLOT) computes the mean time to impact for a
%   list of FEATS. Selects the lambda parameters of the best .25 percentile
%   of features (using a value computed by fitLamContrast) and computes the
%   median as global lambda.
%
%   INPUT:  
%       'feats' :   list of features as parsed by parseFeatures
%   OUTPUT:
%       'lam'   :   estimated lambda
%
%   See also PARSEFEATURES, FITLAMCONTR

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/13 17:20:22 $

if ~exist('showPlot','var')
    showPlot = 0;
end

feats = fitLamContr(feats, showPlot);

errs = [feats.intErr]; % edit here to try a different criteria for feature "goodness"
feats = feats(errs <= prctile(errs,25));

if showPlot > 1
    for ff = feats

        xx = ff.tti(1):.01:ff.tti(end);
        hold on; grid on;
        plot(ff.tti, ff.contr, 'o');
        plot(ff.tti(ff.bestData), ff.contr(ff.bestData), 'ro');
        plot(xx, ff.pars(1)*exp(-xx/ff.pars(2)));
        
        legend('all data', 'best data', 'fitted');
        title(['fitted \lambda: ', num2str(ff.pars(2))]);
        disp(['fitted lambda: ', num2str(ff.pars(2))]);
        pause;
        clf;
    end
end

if showPlot
    lams = [feats.pars]; lams = lams(2:2:end);
    hist(lams);
    title(['mean: ', num2str(mean(lams)), ' median: ' num2str(median(lams))]);
    disp(' ');
    disp('Best fitted lambdas');
    disp(num2str(lams));
end

lam = [feats.pars]; lam = lam(2:2:end);
lam = median(lam);

end