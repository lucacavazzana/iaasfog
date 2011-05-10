function [feats] = fitLamContr(feats, showPlot)

%FITLAMCONTR
%   FITLAMCOTR(FEATS, SHOWPLOT) for each feature selects the 0.5 percentile
%   of datas with the least error over the best-fitting curve, then add to
%   the struct the parameters of the curve fitting the best datas (PARS
%   attribute, stored as [k, lambda]).
%
%   Various attributes are added to the outputted struct list, like:
%       bestData : indexes of the least-error data over the fitted function
%       pars     : [k2, lam2], parameters of the exp fitted using bestData
%       err1norm : k1-scaled mean error over the first fit
%       err2norm : k2-scaled mean error over the second fit
%       err1perc : mean percent error over the first fit
%       err2perc : mean percent error over the second fit
%       rmse1    : root mean square error over the first fit
%       rmse2    : root mean square error over the second fit
%       intErr   : difference between the integral of the two fitted exp
%
%   See also PARSEFEATURES, ESTIMATELAMFIT

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/13 17:20:22 $

if ~exist('showPlot','var')
    showPlot = 0;
end

% this is only to make sure these fields are in the struct list
feats(1).bestData = []; % index of the best 50% contrast levels (nearest to the fitted function)
feats(1).pars = [];     % stores [k, lambda]
feats(1).err1norm = []; % k1-scaled mean error over the first fit
feats(1).err1perc = []; % mean percent error over the first fit
feats(1).rmse1 = [];    % rmse error over the first fit
feats(1).err2norm = []; % k2-scaled mean error over the second fit
feats(1).err2perc = []; % mean percent error over the second fit
feats(1).rmse2 = [];    % rmse error over the second fit
feats(1).intErr = [];   % area between the two fitted functions

fun = 'k*exp(-x/lam)';
ft = fittype(fun);
options = fitoptions('Method', 'NonlinearLeastSquares');

if showPlot > 2
    asd = figure;
end

ii=1; infFit = 0; % to handle possible exceptions caused by fitting generating infinite values
for ff = feats
    
    options.StartPoint = [max(ff.contr), .5]; % TODO: find good starting points
    
    % first fit
    try
        [cfun gof] = fit(ff.tti',ff.contr', ft, options);
    catch exc %#ok
        disp('- Warning: Inf computed by model function. Feat deleted');
        infFit = infFit +1;
        feats(ii) = [];
    end
    
    fitted = cfun.k*exp(-(ff.tti)/cfun.lam);
    err = abs(ff.contr - fitted);   % error 1th fit
    
    % memorizziamo un po' tutto per prova...
    ff.err1norm = mean(err)/cfun.lam; % 1th mean norm error
    ff.err1perc = mean(err ./ fitted);  % 1th mean perc error
    ff.rmse1 = gof.rmse;    % 1th rmse
    
    if showPlot > 2 % plotting for debug
        
        x = ff.tti(1):.01:ff.tti(end);
        
        clf;
        plot(ff.tti, ff.contr, 'o');
        hold on; grid on;
        plot(x, cfun.k*exp(-x/cfun.lam));
        
        disp(['    k: ', num2str(cfun.k), ',     lambda: ', num2str(cfun.lam), ',     rmse (k-norm): ', num2str(gof.rmse), ' (', num2str(gof.rmse/cfun.k),')']);
        drawnow;
    end
    oldK = cfun.k; oldLam = cfun.lam; oldErr = gof.rmse;
    
    % best 50% data
    ff.bestData = err./fitted <= prctile(err./fitted,50); % err percent
    
    % second fit
    try
        [cfun gof] = fit(ff.tti(ff.bestData)',ff.contr(ff.bestData)', ft, options);
    catch exc %#ok
        disp('- Warning: Inf computed by model function. Feat deleted');
        infFit = infFit +1;
        feats(ii) = [];
    end
    
    fitted = cfun.k*exp(-(ff.tti(ff.bestData))/cfun.lam);
    err = abs(ff.contr(ff.bestData) - fitted);   % error 2nd fit
    
    ff.err2norm = mean(err)/cfun.lam;   % 2nd mean norm error
    ff.err2perc = mean(err ./ fitted);  % 2nd mean perc error
    ff.rmse2 = gof.rmse;    % 2nd rmse
    
    % promettente
    % int(k1*exp(-t/lam1,0,Inf) - k2*exp(-t/lam2)) = k2*lam2*exp(-t/lam2) - k1*lam1*exp(-t/lam1) ~ k2*lam2 - k1*lam1
    ff.intErr = abs(cfun.k*cfun.lam - oldK*oldLam);
    
    ff.pars = [cfun.k, cfun.lam];
    
    if showPlot > 2
        plot(ff.tti(ff.bestData),ff.contr(ff.bestData), 'or');
        plot(x, cfun.k*exp(-x/cfun.lam),'r');
        legend(['data - rmse: ', num2str(oldErr)], ...
            ['first fit - k: ', num2str(oldK), ', \lambda: ', num2str(oldLam)], ...
            ['best data - rmse: ', num2str(gof.rmse)], ...
            ['second fit - k: ', num2str(cfun.k), ', \lambda: ', num2str(cfun.lam)]);
        disp(['new k: ', num2str(cfun.k), ', new lambda: ', num2str(cfun.lam), ', new rmse (k-norm): ', num2str(gof.rmse), ' (', num2str(gof.rmse/cfun.k),')']);
        disp(['err1: ', num2str(ff.err1norm), ...
            ', err1perc: ', num2str(ff.err1perc), ...
            ', rmse1: ', num2str(ff.rmse1)]);
        disp(['err2: ', num2str(ff.err2norm), ...
            ', err2perc: ', num2str(ff.err2perc), ...
            ', rmse2: ', num2str(ff.rmse2)]);
        disp(['normStep: ', num2str(ff.err1norm-ff.err2norm), ', percStep: ', num2str(ff.err1perc-ff.err2perc), ', rmsStep: ', num2str(ff.rmse1-ff.rmse2)]);
        disp(['normRapp: ', num2str(ff.err2norm/ff.err1norm), ', percRapp: ', num2str(ff.err2perc/ff.err1perc), ', rmsRapp: ', num2str(ff.rmse2/ff.rmse1)]);
        disp(['intError: ', num2str(ff.intErr)]);
        disp(' ');
        pause;
    end
    
    feats(ii - infFit) = ff;
    ii = ii+1;
end

if showPlot > 2
    close(asd);
end

end