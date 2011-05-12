function [bestPars, bestModel, bestError] = myRansacTest(feats)

%MYRANSACTEST

NSET = size(feats,2);

% PARAMETERS
N = ceil(NSET*.25); % model
K = 15; % max iterations
D = ceil(NSET*.75); % required number to assert the model fits well the data
T = .3;

% some initializations...
x = linspace(min([feats.tti]),max([feats.tti]),100);

% edit here the function we're using
fun = fittype('exp(-x/lam)');
options = fitoptions('Method', 'NonlinearLeastSquares');

bestError = Inf;
bestModel = 0;

for ii=1:K
    
    model = rndSamples();   % choose 1/4 of the set as starting inliers
    modelSet = feats(model);
    consSet = model;
    
    hold on; grid on;
    plot([feats.tti],[feats.contr],'o');
    
    
    options.startPoint = 1; % TODO: find a good starting poin
    
    
    interpFn = fit([modelSet.tti]',[modelSet.contr]', fun, options); % and now fit!
    lam = interpFn.lam;
    
    plot(x,exp(-x/lam),'y*');
    for ff = feats(model)
        plot(ff.tti,ff.contr,'r*');
    end
    axis([x(1),x(end),minMax([feats.contr])]);
    
    err = 0;
    % count the number of inliers
    ind = 1;
    for ff=feats % for each feat tracked...
        % compute the MSE wrt the fitted function (I know, the regex part
        % is weird, but this way I can globally modify the function used)
        % mse=sum((ff.contr-eval(regexprep(f,'(?<!e)x(?!0)','(maxTrack-ff.num+1:maxTrack)'))).^2/ff.num)^.5;   % (?<!e) is to avoid to replace the "x" in "exp"... regex FTW! (don't touch if you didn't pass FLC)
        mse = sum((ff.contr - exp(-ff.tti/lam)).^2/ff.num)^.5;
        %mse=sum((ff.contr-(1-exp(-(maxTrack-ff.num+1:maxTrack)/lam))).^2/ff.num)^.5
       
        
        if any(ind==model) % if is in the model add error contribution
            err = err+mse;
            
        elseif mse < T % if fits enough add to the consensus set and update error
            err = err+mse;
            consSet = [consSet ind]; %#ok
            
            disp(['- feat ',num2str(ind),' added to consensus set for the model [',num2str(model),'] (mse: ', num2str(mse),')']);
        else
            disp(['- feat ',num2str(ind),' rejected for the model [',num2str(model),'] (mse: ', num2str(mse),')']);
        end
        ind = ind +1;
    end
    
    % update if better model
    if size(consSet,2)>=D
        err=err/size(consSet,2);
        if err < bestError
            title('new best model');
            disp(['- new best model [', num2str(model),']! Mean error: ', num2str(err)]);

            bestPars.lam = lam;
            bestError = err;
            bestModel = model;
        else
            title('good but not better than current best');
            disp(['- model [', num2str(model),'] not good enough. Mean error: ', num2str(err)]);
        end
    else
        title('not enough consensus');
        disp(['- model [', num2str(model),']: not enough consensus']);
    end
    
    legend(['data RMSE: ',num2str(err)], ['\lambda: ',num2str(lam)], 'model');
    print('-depsc',['ransac',num2str(ii),'.eps']);
    print('-dpng',['ransac',num2str(ii),'.png']);
    
    clf;
end


if bestError == Inf
    error 'RANSAC couldn''t find any good model. Life sucks...';
end


hold on; grid on;
plot([feats.tti],[feats.contr],'o');
plot(x,exp(-x/bestPars.lam),'y*');
plot([feats(bestModel).tti],[feats(bestModel).contr],'r*');
axis([x(1),x(end),minMax([feats.contr])]);
legend(['data RMSE: ',num2str(bestError)], ['\lambda: ',num2str(bestPars.lam)], 'model');
print('-depsc','ransacWin.eps');
print('-dpng','ransacWin.png');


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