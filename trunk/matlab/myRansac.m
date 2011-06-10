function [bestPars, bestModel, bestError] = myRansac(feats, showPlot)

%MYRANSAC
%   RANSAC implementation to find the lambda value of the exponential
%   visibility function.
%   INPUT:
%     'feats'       :   features vector as parsed by parseFeatures
%     'showPlot'    :   0 - shows nothing
%                       1 - shows messages
%                       2 - plots all ransac models and errors over data
%
%   OUTPUT:
%     'bestPars'    :   computed list of parameters
%     'bestModel'   :   features used to generate the computed lambda
%     'bestError'   :   error of the consensus set
%
%   See also PARSEFEATURES

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/06/08 $

if nargin < 2
    showPlot = 0;
end

NSET = size(feats,2);

% PARAMETERS
N = ceil(NSET*.25); % model
K = 45; % max iterations
D = ceil(NSET*.75); % required number to assert the model fits well the data
T = .4; % consensus treshold

% some initializations...
if showPlot
    x = 0:.01:max([feats.tti]);
end

% edit here the function we're using
fun = fittype('exp(-x/lam)');
options = fitoptions('Method', 'NonlinearLeastSquares');

bestError = Inf;
bestModel = 0;

for ii=1:K
    model = rndSamples();   % choose 1/4 of the set as starting inliers
    modelSet = feats(model);
    consSet = model;    
    
    options.startPoint = 1; % TODO: find a good starting point

    % plots model data
    if showPlot > 1
        plot([modelSet.tti], [modelSet.contr],'ro');
        hold on; grid on;
        drawnow;
    end
    
    try
        interpFn = fit([modelSet.tti]',[modelSet.contr]', fun, options); % and now fit!
    catch e
        warning('Inf computed in the fitting function. Moving to the next model');
        continue;
    end
    
    lam = interpFn.lam;
%     [interpFn2.a, -1/interpFn2.b]
    
    if showPlot
        disp(' ');
        disp(['- trying with lambda = ' num2str(lam)]);
        
        if showPlot > 1
            % show how the function fits the model
            yFit = exp(-x/lam);
            plot(x,yFit);
            plot(x,exp(-x/lam2),'r');
            title(['candidate lambda: ', num2str(lam)]);
            legend('model data','fitted function');
            drawnow
            hold off
        end
    end
    
    err = 0;
    % count the number of inliers
    ind = 1;
    for ff=feats % for each feat tracked...
        
        mse = (sum((ff.contr - exp(-ff.tti/lam)).^2)/(ff.num-1));
        
        % plot how the single feature fits the fitting (lol)
        if showPlot > 1
            pause;
            clf;
            plot(ff.tti,ff.contr,'r*');
            hold on; grid on;
            plot(x,yFit);
            legend('sample feature','candidate model');
            hold off
            drawnow;
        end
        
        if any(ind==model) % if is in the model add error contribution
            err = err+mse;
            if showPlot > 1
                title(['mse: ', num2str(mse),' - already in the model']);
            end
            
        elseif mse < T % if fits enough add to the consensus set and update error
            err = err+mse;
            consSet = [consSet ind]; %#ok
            if showPlot
                disp(['- feat ',num2str(ind),' added to consensus set for the model [',num2str(model),'] (mse: ', num2str(mse),')']);
                if showPlot > 1
                    title(['mse: ', num2str(mse),' - added to the consensus set']);
                end
            end
        else
            if showPlot
                disp(['- feat ',num2str(ind),' rejected for the model [',num2str(model),'] (mse: ', num2str(mse),')']);
                if showPlot > 1
                    title(['mse: ', num2str(mse),' - outlier for current model']);
                end
            end
        end
        ind = ind +1;
    end
    
    % update if better model
    if size(consSet,2)>=D
        err=err/size(consSet,2);
        if err < bestError
            if showPlot
                disp(['- new best model [', num2str(model),']! Mean error: ', num2str(err)]);
            end

            bestPars.lam = lam;
            bestError = err;
            bestModel = model;
        else
            if showPlot
                disp(['- model [', num2str(model),'] not good enough. Mean error: ', num2str(err)]);
            end
        end
    else
        if showPlot
            disp(['- model [', num2str(model),']: not enough consensus']);
        end
    end
    
    if showPlot > 1
        pause;
        clf;
    end
    
end


if showPlot
    close;
end

if bestError == Inf
    error 'RANSAC couldn''t find any good model. Life sucks...';
end

    function [res] = rndSamples()
        % returns an array of N non-repeated random integers within NSET
        
        % uniformly selects a random set (1/4 of the total)
        res = unidrnd(NSET-1,1,N)+1;
        
        % checks there are no repetitions
        for cc = 2:size(res,2)
            while any(res(cc)==res(1:cc-1))
                res(cc) = unidrnd(NSET-1)+1;
            end
        end
    end

end
