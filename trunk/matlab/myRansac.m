function [bestLam, bestModel, bestError] = myRansac(feats, showPlot)

%MYRANSAC
% RANSAC implementation to find the lambda value of the exponential
% visibility function.
% INPUT:
%   'feats'     :    features vector as parsed by FIXME newParser
% 
% OUTPUT:
%   'bestLam'   :   computed lambda
%   'bestModel' :   features used to generate the computed lambda
%   'bestError' :   error of the consensus set
%
% See also NEWPARSER

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/04/07 17:20:22 $

if exist('showPlot','var') && showPlot~=0
    showPlot = 1;
else
    showPlot = 0;
end

NSET = size(feats,2);

% normalizing data
for ii = 1:NSET
    notZero = feats(ii).contr(feats(ii).contr~=0); % FIXME: this passage is necessary until the c function is fixed
    feats(ii).contr = feats(ii).contr/notZero(end);
end

if showPlot
    plotContrast(feats);
end

% PARAMETERS
N = ceil(NSET*.25); % model
K = 5; % max iterations
T = 1.5;  % threshold for a datum to fit
D = ceil(NSET*.75); % required number to assert the model fits well the data

maxTrack = max([feats.num]);	% longest tracking

f = 'exp(-x/lam)';
fun = fittype(f);
options = fitoptions('Method', 'NonlinearLeastSquares');
x = 1:.01:maxTrack;

bestError = Inf;
bestModel = 0;

for ii=1:K
    model = rndSamples();   % choose 1/4 of the set as starting inliers
    modelSet = feats(model);
    consSet = [];
    
    options.StartPoint = 1; % TODO: find a good starting point
    
    t = []; % I don't want to comment this
    for jj = 1:size(modelSet,2)
        t = [t (maxTrack-modelSet(jj).num+1):maxTrack]; %#ok
    end    
    
    interpFn = fit(t',[modelSet.contr]', fun, options); % and now fit!
    lam = interpFn.lam;
    
    % show how the function fits the data
    if 1
        plot(t,[modelSet.contr],'ro');
        hold on;
        plot(x,eval(f));
        title(['lambda: ', num2str(lam)]);
        hold off
        pause;
    end
    
    err = 0;
    % count the number of inliers
    ind = 1;
    for ff=feats % for each feat tracked...
        % compute the MSE wrt the fitted function (I know, the regex part
        % is weird, but this way I can globally modify the function used
        mse=sum((ff.contr-eval(regexprep(f,'-x','-(maxTrack-ff.num+1:maxTrack)'))).^2)^.5/ff.num
        %mse=sum((ff.contr-(1-exp(-(maxTrack-ff.num+1:maxTrack)/lam))).^2)^.5/ff.num
        
        % fancy plot
        if 1
            plot(maxTrack-ff.num+1:maxTrack,ff.contr,'r*');
            hold on;
            plot(x,eval(f));
            title(['mse: ', num2str(mse)]);
            hold off
            pause;
        end
        
        % if fits enough add to the consensus set
        if mse<T
            err = err+mse;
            consSet = [consSet ind]; %#ok
        end
        ind = ind +1;
    end
    
    % update if better model
    if size(consSet,2)>=D
        if err < bestError
            bestLam = lam;
            bestError = err;
            bestModel = model;
        end
    end
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


    function [] = plotContrast(asd)
        %debugging utility
        colors = ['y','m','c','r','g','b','w','k'];
        figure; hold on;
        for pp = 1:max(size(asd))
%             disp(asd(ii).contr);
            plot(asd(pp).start:asd(pp).start+asd(pp).num-1,asd(pp).contr,colors(rem(pp,8)+1));
            pause(.2)
        end
        clear colors;
    end
end