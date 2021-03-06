function [feats] = normContrast(feats, type, showPlot)

%NORMCONTRAST   Normalize contrast values
%
%   NormContrast(feats, type) normalizes contrast values.
%   INPUT:
%     'feats'   :   array of features as parsed by parseFeatures
%     'type'    :   type of normalization
%                   'fitExp': norm over 'k' fitting the function
%                             'k*exp(-x/lam)            <<--- this one rocks
%                   'mean': rescaled by two times the mean value
%                   'minMax': equalizes over min and max values (outlier sensitive...)
%   OUTPUT:
%      'feats'  :   list of features with contrast properly normalized
%
%   See also PARSEFEATURES

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/06/08 $


if ~exist('showPlot','var')
    showPlot = 0;
end


if strcmp(type, 'max')
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = feats(ii).contr/max(notZero);
    end
    
elseif strcmp(type, 'minMax') %--------------------------------------------
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = (feats(ii).contr-min(notZero))/(max(notZero)-min(notZero));
    end
    
elseif strcmp(type, 'last') %----------------------------------------------
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = feats(ii).contr/notZero(end);
    end
    
elseif strcmp(type, 'firstLast') %-----------------------------------------
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = (feats(ii).contr-notZero(1))/abs(notZero(end)-notZero(1));
    end
    
elseif strcmp(type, 'mean') %----------------------------------------------
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = feats(ii).contr/(2*mean(notZero));
    end
    
elseif strcmp(type, 'fitExp') %-----------------------------------------------
    ft = fittype('k*exp(-x/lam)');
    options = fitoptions('Method', 'NonlinearLeastSquares');
        
    if showPlot > 2
        fig = figure;
    end
    ii=1;
    for ff = feats
        % using simple fit
        options.StartPoint = [max(ff.contr), 1]; % TODO: find good starting point
        [cfun gof] = fit(ff.tti',ff.contr', ft, options);
        k = cfun.k; lam = cfun.lam;

        % exp fit
%         cfun = fit(ff.tti',ff.contr', 'exp1');
%         k = cfun.a; lam = -1/cfun.b;
        
        % LSE fit
%         [k, lam] = fitExp(ff.tti,ff.contr);
        
        feats(ii).contr = ff.contr/k;
        feats(ii).pars = [k, lam];
        

        if showPlot > 2 % plotting for debug
            
            plot(feats(ii).tti,k*feats(ii).contr, 'ro');
            hold on; grid on;
            x = feats(ii).tti(1):.01:feats(ii).tti(end);
            plot(x, k*exp(-x/lam));
            legend(sprintf('feat #%d',ii), sprintf('k: %f, lambda: %f', k, lam));
            
            pause();
            clf;
        end
        
        ii = ii+1;
    end
    
    if showPlot > 2
        close(fig);
    end
    
else %---------------------------------------------------------------------
    error('    invalid normalization parameter');
end

end