function [] = estimateLamFit(feats, showPlot)


if ~exist('showPlot','var')
    showPlot = 0;
end

feats = normContrast(feats,'fitExp');


if showPlot > 1
    for ff = feats

        hold on; grid on;
        plot(ff.tti,ff.contr*ff.pars(1),'o');
        plot(ff.tti(1):.01:ff.tti(end), ff.pars(1)*exp(-(ff.tti(1):.01:ff.tti(end))/ff.pars(2)));
        
        legend('data','fitted');
        title(['fitted \lambda: ', num2str(ff.pars(2))]);
        disp(['fitted lambda: ', num2str(ff.pars(2))]);
        pause;
        clf;
    end
end

% extracting percentile 0.6
lams = [feats.pars]; lams = lams(2:2:end);
feats = feats(lams <= prctile(lams,60));

if showPlot
    lams = [feats.pars]; lams = lams(2:2:end);
    hist(lams);
    title(['mean: ', num2str(mean(lams)), ' median: ' num2str(median(lams))]);
    disp(' ');
    disp('fitted lambdas');
    disp(num2str(lams));
end

end