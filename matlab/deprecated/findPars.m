function [bestPars, bestModel, bestError] = findPars(feats, frameTime, normType, funct, showPlot)

%MYRANSAC
%   RANSAC implementation to find the lambda value of the exponential
%   visibility function.
%   INPUT:
%     'feats'       :   features vector as parsed by parseFeatures.m
%     'funct'       :   function type. Actually supports 'exp' and 'tanh'
%
%   OUTPUT:
%     'bestPars'    :   computed list of parameters
%     'bestModel'   :   features used to generate the computed lambda
%     'bestError'   :   error of the consensus set
%
%   See also PARSEFEATURES

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/27 17:20:22 $

% FUNCTION: 'exp' | 'tanh'
TRYFUN = funct;


if ~exist('showPlot','var')
    showPlot = 0;
end

NSET = size(feats,2);

if showPlot>2
    fig = plotContrasts(feats);
    pause;
    close(fig);
end

% PARAMETERS
N = ceil(NSET*.25); % model
K = 1; % max iterations
D = ceil(NSET*.75); % required number to assert the model fits well the data

if strcmp(normType,'max')
    T=.075;
elseif strcmp(normType,'minmax')
    T=.07;
elseif strcmp(normType,'last')
    T=.2;
elseif strcmp(normType,'firstlast')
    T=.2;
elseif strcmp(normType,'mean')
    T=.06;
else
    error('   invalid normalization parameter');
end

maxTrack = max([feats.tti] + frameTime*([feats.num]-1));    %farthest tracked feat time

% edit here the function we're using
switch TRYFUN
    case 'exp'
        f = 'exp(-x/lam)';
    case 'tanh'
        f = '-.5*tanh((x-x0)/lam)+.5';
end

fun = fittype(f);
options = fitoptions('Method', 'NonlinearLeastSquares');
x = .9*min(feats.tti):.01:maxTrack;

bestError = Inf;
bestModel = 0;

for ii=1:K
    model = rndSamples();   % choose 1/4 of the set as starting inliers
    modelSet = feats(model);
    consSet = model;
    
    t = []; % I don't want to comment this
    for ff = modelSet;
        t = [t ff.tti:frameTime:(ff.tti+frameTime*(ff.num-1))]; %#ok
    end
    
    switch TRYFUN
        case 'exp'
            options.StartPoint = 1; % TODO: find a good starting point
        case 'tanh'
            options.StartPoint = [1, mean(t)];
    end
    
    interpFn = fit(t',[modelSet.contr]', fun, options); % and now fit!
    switch TRYFUN
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
        plot(t,[modelSet.contr],'ro');
        hold on; grid on;
        plot(x,eval(f));
        switch TRYFUN
            case 'exp'
                title([f,' : lambda: ', num2str(lam)]);
            case 'tanh'
                title([f,' : lambda: ', num2str(lam), ', x0: ', num2str(x0)]);
                plot(x0, .5, '*y');
        end
        hold off
    end
    
    
    
    
    
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