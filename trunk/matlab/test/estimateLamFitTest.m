function [lam] = estimateLamFitTest(feats, showPlot)

%ESTIMATELAMFITTEST: variante di estimateLamFix per stampare immagini per
%la relazione

if ~exist('showPlot','var')
    showPlot = 0;
end

feats = fitLamContrTest(feats, showPlot);

errs = [feats.intErr]; % edit here to try a different criteria for feature "goodness"
feats = feats(errs <= prctile(errs,25));

if showPlot > 1
    for ff = feats

        xx = ff.tti(1):.01:ff.tti(end);
        hold on; grid on;
        plot(ff.tti, ff.contr, 'o');
        plot(ff.tti(ff.bestData), ff.contr(ff.bestData), 'ro');
        plot(xx, ff.pars(1)*exp(-xx/ff.pars(2)));
        
        legend('all data', 'best data', 'fitted');
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
    disp('Best fitted lambdas');
    disp(num2str(lams));
end

lam = [feats.pars]; lam = lam(2:2:end);
lam = median(lam);

end