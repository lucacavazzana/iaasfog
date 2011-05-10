function [bestPars, bestModel, bestError] = myRansac(feats, showPlot)

%MYRANSAC
%   RANSAC implementation to find the lambda value of the exponential
%   visibility function.
%   INPUT:
%     'feats'       :   features vector as parsed by parseFeatures
%     'showPlot'    :   0: shows nothing, 1: shows the fitting curve,
%                       2: error over fitting
%
%   OUTPUT:
%     'bestPars'    :   computed list of parameters
%     'bestModel'   :   features used to generate the computed lambda
%     'bestError'   :   error of the consensus set
%
%   See also PARSEFEATURES

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/07 17:20:22 $

if ~exist('showPlot','var')
    showPlot = 0;
end

NSET = size(feats,2);

% PARAMETERS
N = ceil(NSET*.25); % model
K = 15; % max iterations
D = ceil(NSET*.75); % required number to assert the model fits well the data
T = .10;

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
    if showPlot
        plot([modelSet.tti], [modelSet.contr],'ro');
        hold on; grid on;
        drawnow;
    end
    
    
    interpFn = fit([modelSet.tti]',[modelSet.contr]', fun, options); % and now fit!
    lam = interpFn.lam;
    
    
    if showPlot
        disp(' ');
        disp(['- trying with lambda = ' num2str(lam)]);
        
        % show how the function fits the model
        yFit = exp(-x/lam);
        plot(x,yFit);
        title(['lambda: ', num2str(lam)]);
        legend('model data','fitted function');
        drawnow
        hold off
    end
    
    err = 0;
    % count the number of inliers
    ind = 1;
    for ff=feats % for each feat tracked...
        % compute the MSE wrt the fitted function (I know, the regex part
        % is weird, but this way I can globally modify the function used)
        % mse=sum((ff.contr-eval(regexprep(f,'(?<!e)x(?!0)','(maxTrack-ff.num+1:maxTrack)'))).^2)^.5/ff.num;   % (?<!e) is to avoid to replace the "x" in "exp"... regex FTW! (don't touch if you didn't pass FLC)
        mse = sum((ff.contr - exp(-ff.tti/lam)).^2)^.5/ff.num;
        %mse=sum((ff.contr-(1-exp(-(maxTrack-ff.num+1:maxTrack)/lam))).^2)^.5/ff.num
        
        % plot how the single feature fits the fitting (lol)
        if showPlot > 1
            pause;
            plot(ff.tti,ff.contr,'r*');
            hold on; grid on;
            plot(x,yFit);
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
                disp(['- new best model [', num2str(model),']! Error: ', num2str(err)]);
            end

            bestPars.lam = lam;
            bestError = err;
            bestModel = model;
        else
            if showPlot
                disp(['- model [', num2str(model),'] not good enough. Error: ', num2str(err)]);
            end
        end
    else
        if showPlot
            disp(['- model [', num2str(model),']: not enough consensus']);
        end
    end
    
    if showPlot
        pause;
        clf;
    end
    
end


if bestError == Inf
    error 'RANSAC couldn''t find any good model. Life sucks...';
end

if showPlot
    close;
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