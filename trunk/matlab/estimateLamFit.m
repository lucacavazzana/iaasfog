function [] = estimateLamFit(feats, showPlot)

if ~exist('showPlot','var')
    showPlot = 0;
end

feats = normContrast(feats,'fitExp');


if showPlot > 1
    for ff = feats
        lamMinMax = minMaxContr(ff.contr, ff.tti);
        hold on; grid on;
        plot(ff.tti,ff.contr*ff.pars(1),'o');
        plot(ff.tti(1):.01:ff.tti(end), ff.pars(1)*exp(-(ff.tti(1):.01:ff.tti(end))/ff.pars(2)));
        if lamMinMax ~= -1
            plot(ff.tti(1):.01:ff.tti(end), ff.pars(1)*exp(-(ff.tti(1):.01:ff.tti(end))/lamMinMax),'g');
        end
        legend('data','fitted','minMax');
        title(['fitted \lambda: ', num2str(ff.pars(2)), ', minMax \lambda: ', num2str(lamMinMax)]);
        disp(['fitted lambda: ', num2str(ff.pars(2)), ', minMax lambda: ', num2str(lamMinMax)]);
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