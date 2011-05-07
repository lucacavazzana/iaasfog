function [feats] = fitLamContr(feats, showPlot)

if ~exist('showPlot','var')
    showPlot = 0;
end

% this is only to make sure these fields are in the struct list
feats(1).pars = 1;
feats(1).err1norm = 1;
feats(1).err1perc = 1;
feats(1).rmse1 = 1;
feats(1).err2norm = 1;
feats(1).err2perc = 1;
feats(1).rmse2 = 1;
feats(1).step = 1;
feats(1).rapp = 1;
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
    
    fitted = cfun.k*exp(-(ff.tti)/cfun.lam);
    err = abs(ff.contr - fitted);   % error 1th fit
    
    % memorizziamo un po' tutto per prova...
    ff.err1norm = mean(err)/cfun.lam; % 1th mean norm error
    ff.err1perc = mean(err ./ fitted);  % 1th mean perc error
    ff.rmse1 = gof.rmse;    % 1th rmse
    
    if showPlot > 2 % plotting for debug
        
        x = ff.tti(1):.01:ff.tti(end);
        
        clf;
        plot(ff.tti, ff.contr, 'o');
        hold on; grid on;
        plot(x, cfun.k*exp(-x/cfun.lam));

        disp(['    k: ', num2str(cfun.k), ',     lambda: ', num2str(cfun.lam), ',     rmse (k-norm): ', num2str(gof.rmse), ' (', num2str(gof.rmse/cfun.k),')']);
        drawnow;
        oldK = cfun.k; oldLam = cfun.lam; oldErr = gof.rmse;
    end
    
    % best 50% data
    bad = err./fitted <= prctile(err./fitted,50); % err percent
    ff.tti = ff.tti(bad);
    ff.contr = ff.contr(bad);
    
    % second fit
    [cfun gof] = fit(ff.tti',ff.contr', ft, options);
    
    fitted = cfun.k*exp(-(ff.tti)/cfun.lam);
    err = abs(ff.contr - fitted);   % error 2nd fit
    
    ff.err2norm = mean(err)/cfun.lam; % 2nd mean norm error
    ff.err2perc = mean(err ./ fitted);  % 2nd mean perc error
    ff.rmse2 = gof.rmse;    % 2nd rmse
    
    ff.pars = [cfun.k, cfun.lam];
        
    if showPlot > 2
        plot(ff.tti,ff.contr, 'or');
        plot(x, cfun.k*exp(-x/cfun.lam),'r');
        legend(['data - rmse: ', num2str(oldErr)], ...
                ['first fit - k: ', num2str(oldK), ', \lambda: ', num2str(oldLam)], ...
                ['best data - rmse: ', num2str(gof.rmse)], ...
                ['second fit - k: ', num2str(cfun.k), ', \lambda: ', num2str(cfun.lam)]);
        disp(['new k: ', num2str(cfun.k), ', new lambda: ', num2str(cfun.lam), ', new rmse (k-norm): ', num2str(gof.rmse), ' (', num2str(gof.rmse/cfun.k),')']);
        disp(['err1: ', num2str(ff.err1norm), ...
            ', err1perc: ', num2str(ff.err1perc), ...
            ', rmse1: ', num2str(ff.rmse1)]);
        disp(['err2: ', num2str(ff.err2norm), ...
            ', err2perc: ', num2str(ff.err2perc), ...
            ', rmse2: ', num2str(ff.rmse2)]);
        disp(['normStep: ', num2str(ff.err1norm-ff.err2norm), ', percStep: ', num2str(ff.err1perc-ff.err2perc), ', rmsStep: ', num2str(ff.rmse1-ff.rmse2)]);
        disp(['normRapp: ', num2str(ff.err2norm/ff.err1norm), ', percRapp: ', num2str(ff.err2perc/ff.err1perc), ', rmsRapp: ', num2str(ff.rmse2/ff.rmse1)]);
        disp(' ');
        pause;
    end
    
    ff.err = ff.err1perc;
    
    feats(ii) = ff;
    ii = ii+1;
end

if showPlot > 2
    close(asd);
end

end