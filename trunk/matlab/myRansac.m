function [bestPars, bestModel, bestError] = myRansac(feats, normType, funct, showPlot)

%MYRANSAC
%   RANSAC implementation to find the lambda value of the exponential
%   visibility function.
%   INPUT:
%     'feats'       :   features vector as parsed by parseFeatures.m
%     'normType'    :   type of normalization used (see normContrast)
%     'funct'       :   function type. Actually supports 'exp' and 'tanh'
%     'showPlot'    :   0: shows nothing, 1: shows fitting curve, 2: also
%                       shows error over each set
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

if showPlot > 2 % shows contrasts plot
    fig = plotContrasts(feats);
    pause;
    close(fig);
end

% PARAMETERS
N = ceil(NSET*.25); % model
K = 15; % max iterations
D = ceil(NSET*.75); % required number to assert the model fits well the data

if strcmp(normType,'max')
    T=.075;
elseif strcmp(normType,'minMax')
    T=.07;
elseif strcmp(normType,'last')
    T=.2;
elseif strcmp(normType,'firstLast')
    T=.2;
elseif strcmp(normType,'mean')
    T=.06;
elseif strcmp(normType,'fitExp')
    T=.11;
else
    error('   invalid normalization parameter');
end

% some initializations...
maxTrack = max([feats.tti]);	% longest tracking


% edit here the function we're using
switch funct
    case 'exp'
        f = 'exp(-x/lam)';
    case 'tanh'
        f = '-.5*tanh((x-x0)/lam)+.5';
end


fun = fittype(f);
options = fitoptions('Method', 'NonlinearLeastSquares');
x = 0:.01:maxTrack;

bestError = Inf;
bestModel = 0;

for ii=1:K
    model = rndSamples();   % choose 1/4 of the set as starting inliers
    modelSet = feats(model);
    consSet = model;    
    
    switch funct
        case 'exp'
            options.StartPoint = 1; % TODO: find a good starting point
        case 'tanh'
            options.StartPoint = [1, mean([modelSet.tti])];
    end
    
    interpFn = fit([modelSet.tti]',[modelSet.contr]', fun, options); % and now fit!
    switch funct
        case 'exp'
            lam = interpFn.lam;
        case 'tanh'
            lam = interpFn.lam;
            x0 = interpFn.x0;
    end
    
    disp(' ');
    disp(['- try with lambda = ' num2str(lam)]);
    
    % show how the function fits the data
    if showPlot
        plot([modelSet.tti], [modelSet.contr],'ro');
        hold on; grid on;
        plot(x,eval(f));
        switch funct
            case 'exp'
                title([f,' : lambda: ', num2str(lam)]);
            case 'tanh'
                title([f,' : lambda: ', num2str(lam), ', x0: ', num2str(x0)]);
                plot(x0, .5, '*y');
        end
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
        
        % fancy plot
        if showPlot > 1
            pause;
            plot(ff.tti,ff.contr,'r*');
            hold on; grid on;
            plot(x,eval(f));
            hold off
        end
        
        if any(ind==model) % if is in the model add error contribution
            err = err+mse;
            if showPlot > 1
                title(['mse: ', num2str(mse),' - already in the model']);
            end
            
        elseif mse < T % if fits enough add to the consensus set and update error
            err = err+mse;
            consSet = [consSet ind]; %#ok
            disp(['- feat ',num2str(ind),' added to consensus set for the model [',num2str(model),'] (mse: ', num2str(mse),')']);
            if showPlot > 1
                title(['mse: ', num2str(mse),' - added to the consensus set']);
            end
            
        else
            disp(['- feat ',num2str(ind),' rejected for the model [',num2str(model),'] (mse: ', num2str(mse),')']);
            if showPlot > 1
                title(['mse: ', num2str(mse),' - outlier for current model']);
            end
        end
        ind = ind +1;
    end
    
    % update if better model
    if size(consSet,2)>=D
        err=err/size(consSet,2);
        if err < bestError
            disp(['- new best model [', num2str(model),']! Error: ', num2str(err)]);
            switch funct
                case 'exp'
                    bestPars.lam = lam;
                case 'tanh'
                    bestPars.lam = lam;
                    bestPars.x0 = x0;
            end
            bestError = err;
            bestModel = model;
        else
            disp(['- model [', num2str(model),'] not good enough. Error: ', num2str(err)]);
        end
    else
        disp(['- model [', num2str(model),']: not enough consensus']);
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