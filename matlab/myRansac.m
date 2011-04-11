function [bestLam, bestModel, bestError] = myRansac(contr)

%MYRANSAC
% RANSAC implementation to find the lambda value of the exponential
% visibility function.
%   'contr':    contrasts array IMGxFEATS

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/04/07 17:20:22 $

[NIMG NSET] = size(contr);

N = ceil(NSET*.25); % min required inliers
K = 3; % max iterations
T = 0.017;  % threshold for a datum to fit
D = ceil(NSET*.75); % required number to assert the model fits well the data

fun = fittype('1-exp(-x/lam)');
options = fitoptions('Method', 'NonlinearLeastSquares');

bestError = Inf;
bestModel = 0;

for ii=1:K
    model = rndSamples(); % choose 1/4 of the set as starting inliers
    modelSet = contr(:,model);
    consSet = model;
    
    options.StartPoint = 1; % TODO: find a good starting point
    
    interp_fn = fit(ceil((1:numel(modelSet))/size(modelSet,2))', reshape(modelSet',[],1), fun, options); % and now fit!
    lam = interp_fn.lam;
    
    % count the number of inliers
    for ff=setdiff(1:NSET,model) % only the not-in-the-model
        err = 0;
%         ff
%         contr(:,ff)'
%         curva = 1-exp(-(1:NIMG)/lam)
        mse = sum((contr(:,ff)'+exp(-(1:NIMG)/lam)-1).^2)^.5/NIMG; % mean square error
%         mse
        if mse < T  % if LSE less than treshold add consensus
            consSet = [consSet, ff] %#ok
            err = err + mse;
        end
    end
    
%     consSize = size(consSet,2)
    
    % if the model is valid
    if size(consSet,2)>=D
        % if the model is better, update
        if err/size(consSet,2) < bestError
            bestError = err/size(consSet,2);
            bestModel = modelSet;
            bestLam = lam;
        end
    end
%     bestModel
%     bestError
%     consSet
%     model
end


if bestError == Inf
    error 'RANSAC couldn''t find any good model. Life sucks...';
end


    function [res] = rndSamples()
        % returns an array of N non-repeated random integers within NSET
        
        % uniformly selects a random set (1/4 of the total)
        res = unidrnd(NSET-1,1,N)+1;
        
        % checks there are no repetitions
        for jj = 2:size(res,2)
            while any(res(jj)==res(1:jj-1))
                res(jj) = unidrnd(NSET-1)+1;
            end
        end
    end
end