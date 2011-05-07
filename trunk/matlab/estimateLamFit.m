function [] = estimateLamFit(feats, showPlot)

%

if ~exist('showPlot','var')
    showPlot = 0;
end

feats = fitLamContr(feats, showPlot);

errs = [feats.err];
feats = feats(errs <= prctile(errs,25));

if showPlot > 1
    for ff = feats

        xx = ff.tti(1):.01:ff.tti(end);
        hold on; grid on;
        plot(ff.tti,ff.contr,'o');
        plot(xx, ff.pars(1)*exp(-xx/ff.pars(2)));
        
        legend('data','fitted');
        title(['fitted \lambda: ', num2str(ff.pars(2))]);
        disp(['fitted lambda: ', num2str(ff.pars(2))]);
        pause;
        clf;
    end
end

if showPlot
    lams = [feats.pars]; lams = lams(2:2:end);
    hist(lams);
    title(['mean: ', num2str(mean(lams)), ' median: ' num2str(median(lams))]);
    disp(' ');
    disp('fitted lambdas');
    disp(num2str(lams));
end

end