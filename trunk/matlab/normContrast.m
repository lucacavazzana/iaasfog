function [feats] = normContrast(feats, type)

%NORMCONTRAST   Normalize contrast values
%
%   NormContrast(feats, type) normalizes contrast values.
%   INPUT:
%     'feats'   :   array of features as parsed by parseFeatures
%     'type'    :   type of normalization
%                   'max':
%                   'minMax':
%                   'last':
%                   'firstLast':
%                   'mean':
%                   'fitExp': norm over 'k' fitting the function 'k*exp(-x/lam)
%   OUTPUT:
%      'feats'  :   list of features with contrast properly normalized
%
%   See als PARSEFEATURES

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/09 11:59:22 $

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
    
    fun = 'k*exp(-x/lam)';
    ft = fittype(fun);
    options = fitoptions('Method', 'NonlinearLeastSquares');
    
    ii=1;
    for ff = feats
        
        options.StartPoint = [max(ff.contr), 1]; % TODO: find good starting point
        fitted = fit(ff.tti',ff.contr(1:end)', ft, options);
        
        feats(ii).contr = feats(ii).contr/fitted.k;
        feats(ii).pars = [fitted.k, fitted.lam];
        
        if 0
            k = fitted.k;
            lam = fitted.lam;
            x = feats(ii).tti(1):.01:feats(ii).tti(end);
            plot(feats(ii).tti,feats(ii).contr(1:end), 'ro');
            hold on; grid on;
            plot(x, eval(fun)/k);
            pause(.2);
            close;
        end
        
        ii = ii+1;
    end
    
else %---------------------------------------------------------------------
    error('    invalid normalization selected');
end

end