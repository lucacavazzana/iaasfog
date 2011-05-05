function [feats] = fitLamContr(feats, showPlot)

if ~exist('showPlot','var')
    showPlot = 0;
end

% this is only to make sure these fields are in the struct list
feats(1).pars = 1;
feats(1).err = 1;

fun = 'k*exp(-x/lam)';
ft = fittype(fun);
options = fitoptions('Method', 'NonlinearLeastSquares');

if showPlot > 2
    asd = figure;
end

ii=1;
for ff = feats
    
    options.StartPoint = [max(ff.contr), .5]; % TODO: find good starting points
    
    % first fit
    [cfun gof] = fit(ff.tti',ff.contr', ft, options);
    
    if showPlot > 2 % plotting for debug
        
        x = ff.tti(1):.01:ff.tti(end);
        
        clf;
        plot(ff.tti,ff.contr, 'o');
        hold on; grid on;
        plot(x, cfun.k*exp(-x/cfun.lam));

        disp(['    k: ', num2str(cfun.k), ',     lambda: ', num2str(cfun.lam), ',     rmse (k-norm): ', num2str(gof.rmse), ' (', num2str(gof.rmse/cfun.k),')']);
        drawnow;
        oldK = cfun.k; oldLam = cfun.lam; oldErr = gof.rmse;
    end
    
    err = abs(ff.contr-cfun.k*exp(-(ff.tti)/cfun.lam));
    ff.err = sum(err ./ (cfun.k*exp(-(ff.tti)/cfun.lam))) / ff.num; % errore percentuale medio iniziale
    bad = err < prctile(err,50);
    
    ff.tti = ff.tti(bad);
    ff.contr = ff.contr(bad);
    
    [cfun gof] = fit(ff.tti',ff.contr', ft, options);
    
    ff.pars = [cfun.k, cfun.lam];
    % ff.err = gof.rmse;  % looks like a good index to me
    
    if showPlot > 2
        plot(ff.tti,ff.contr, 'or');
        plot(x, cfun.k*exp(-x/cfun.lam),'r');
        legend(['data - rmse: ', num2str(oldErr)], ...
                ['first fit - k: ', num2str(oldK), ', \lambda: ', num2str(oldLam)], ...
                ['best data - rmse: ', num2str(gof.rmse)], ...
                ['second fit - k: ', num2str(cfun.k), ', \lambda: ', num2str(cfun.lam)]);
        disp(['new k: ', num2str(cfun.k), ', new lambda: ', num2str(cfun.lam), ', new rmse (k-norm): ', num2str(gof.rmse), ' (', num2str(gof.rmse/cfun.k),')']);
        disp(ff.err);
        disp(' ');
        pause;
    end
    
    feats(ii) = ff;
    ii = ii+1;
end

if showPlot > 2
    close(asd);
end

end