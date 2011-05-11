function [feats] = normContrastTest(feats, type, showPlot)

%NORMCONTRAST:  versione modificata di normContrastTest per stampare
%immagini per la relazione


if ~exist('showPlot','var')
    showPlot = 0;
end


if strcmp(type, 'max')
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = feats(ii).contr/max(notZero);
    end
    
elseif strcmp(type, 'minMax') %--------------------------------------------
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = (feats(ii).contr-min(notZero))/(max(notZero)-min(notZero));
    end
    
elseif strcmp(type, 'last') %----------------------------------------------
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = feats(ii).contr/notZero(end);
    end
    
elseif strcmp(type, 'firstLast') %-----------------------------------------
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = (feats(ii).contr-notZero(1))/abs(notZero(end)-notZero(1));
    end
    
elseif strcmp(type, 'mean') %----------------------------------------------
    
    for ii = 1:max(size(feats))
        notZero = feats(ii).contr(feats(ii).contr~=0);
        feats(ii).contr = feats(ii).contr/(2*mean(notZero));
    end
    
elseif strcmp(type, 'fitExp') %-----------------------------------------------
    ft = fittype('k*exp(-x/lam)');
    options = fitoptions('Method', 'NonlinearLeastSquares');
    
    
    if showPlot > 2
        fig = figure;
    end
    ii=1;
    for ff = feats
        
        options.StartPoint = [max(ff.contr), 1]; % TODO: find good starting point
        cfun = fit(ff.tti',ff.contr(1:end)', ft, options);
        
        feats(ii).contr = ff.contr/cfun.k;
        feats(ii).pars = [cfun.k, cfun.lam];
        
        if showPlot > 2 % plotting for debug
            
            plot(feats(ii).tti,cfun.k*feats(ii).contr(1:end), 'ro');
            hold on; grid on;
            x = feats(ii).tti(1):.01:feats(ii).tti(end);
            plot(x, cfun.k*exp(-x/cfun.lam));
            legend(['feat #', num2str(ii)], ['k: ', num2str(cfun.k), ', lambda: ', num2str(cfun.lam)]);
            
            axis([ff.tti(1),ff.tti(end),minmax(ff.contr)]);
            set(gca,'Position',[0.02 0.04 .98 .96]);
            
            print('-dpng', ['feat',num2str(ii),'.png']);
            print('-depsc', ['feat',num2str(ii),'.eps']);
            
            
%             pause(.3);
            clf;
        end
        
        ii = ii+1;
    end
    
    if showPlot > 2
        close(fig);
    end
    
else %---------------------------------------------------------------------
    error('    invalid normalization parameter');
end

end