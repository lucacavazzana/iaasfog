function [bestLam, bestModel, bestError] = myRansac(feats, showPlot)

%MYRANSAC
% RANSAC implementation to find the lambda value of the exponential
% visibility function.
% INPUT:
%   'feats'     :    features vector as parsed by parseFeatures.m
%
% OUTPUT:
%   'bestLam'   :   computed lambda
%   'bestModel' :   features used to generate the computed lambda
%   'bestError' :   error of the consensus set
%
% See also NEWPARSER

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/07 17:20:22 $


NORMALIZE = 1;

if ~exist('showPlot','var')
    showPlot = 0;
end

NSET = size(feats,2);

% normalizing data
if NORMALIZE
    for ii = 1:NSET
        notZero = feats(ii).contr(feats(ii).contr~=0); % FIXME: this passage is necessary until the c function is fixed
        feats(ii).contr = feats(ii).contr/mean(2*notZero);
    end
end

if showPlot>2
    fig = plotContrasts(feats);
    pause
    close(fig);
end

% PARAMETERS
N = ceil(NSET*.25); % model
K = 10; % max iterations
T = .2;  % threshold for a datum to fit
D = ceil(NSET*.75); % required number to assert the model fits well the data

% some initializations...
maxTrack = max([feats.num]);	% longest tracking

% edit here the function we're using
f = '1-exp(-x/lam)';
% f = '.5*tanh(x/lam)+.5';
fun = fittype(f);
options = fitoptions('Method', 'NonlinearLeastSquares');
x = 1:.01:maxTrack;

bestError = Inf;
bestModel = 0;

for ii=1:K
    model = rndSamples();   % choose 1/4 of the set as starting inliers
    modelSet = feats(model);
    consSet = model;
    
    options.StartPoint = 1; % TODO: find a good starting point
    
    t = []; % I don't want to comment this
    for jj = 1:size(modelSet,2)
        t = [t (maxTrack-modelSet(jj).num+1):maxTrack]; %#ok
    end
    
    interpFn = fit(t',[modelSet.contr]', fun, options); % and now fit!
    lam = interpFn.lam;
    disp(' ');
    disp(['- try with lambda = ' num2str(lam)]);
    
    % show how the function fits the data
    if showPlot
        plot(t,[modelSet.contr],'ro');
        hold on; grid on;
        plot(x,eval(f));
        title([f,' : lambda: ', num2str(lam)]);
        hold off
    end
    
    err = 0;
    % count the number of inliers
    ind = 1;
    for ff=feats % for each feat tracked...
        % compute the MSE wrt the fitted function (I know, the regex part
        % is weird, but this way I can globally modify the function used
        mse=sum((ff.contr-eval(regexprep(f,'(?<!e)x','(maxTrack-ff.num+1:maxTrack)'))).^2)^.5/ff.num;   % (?<!e) is to avoid to replace the "x" in "exp"... regex FTW!
        %mse=sum((ff.contr-(1-exp(-(maxTrack-ff.num+1:maxTrack)/lam))).^2)^.5/ff.num
        
        % fancy plot
        if (showPlot > 1)
            pause;
            plot(maxTrack-ff.num+1:maxTrack,ff.contr,'r*');
            hold on; grid on;
            plot(x,eval(f));
            hold off
        end
        
        if any(ind==model) % if is in the model add error contribution
            err = err+mse;
            if showPlot>1
                title(['mse: ', num2str(mse),' - already in the model']);
            end
            
        elseif mse<T % if fits enough add to the consensus set and update error
            err = err+mse;
            consSet = [consSet ind]; %#ok
            disp(['- feat ',num2str(ind),' added to consensus set for the model [',num2str(model),'] (mse: ', num2str(mse),')']);
            if showPlot>1
                title(['mse: ', num2str(mse),' - added to the consensus set']);
            end
            
        else
            disp(['- feat ',num2str(ind),' rejected for the model [',num2str(model),'] (mse: ', num2str(mse),')']);
            if showPlot>1
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
            bestLam = lam;
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