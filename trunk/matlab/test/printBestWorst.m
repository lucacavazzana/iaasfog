function [] = printBestWorst(feats)

%PRINTBESTWORST: stampa immagini per doc

feats = fitLamContr(feats);

best = feats([feats.intErr] <= prctile([feats.intErr],25));
worst = feats([feats.intErr] >= prctile([feats.intErr],75));

ii = 1;
for ff = best
    tt = linspace(ff.tti(1),ff.tti(end),100);
    
    hold on; grid on;
    plot(ff.tti,ff.contr,'o');
    plot(tt, ff.oldPars(1)*exp(-tt/ff.oldPars(2)));
    plot(ff.tti(ff.bestData),ff.contr(ff.bestData),'ro');
    plot(tt, ff.pars(1)*exp(-tt/ff.pars(2)),'r');
    
    axis([ff.tti(1),ff.tti(end),minMax(ff.contr)]);
%     axis(gca,'OuterPosition',[0 0 1 1]);
    title(['intError: ', num2str(ff.intErr)]);
    legend('data',['k: ',num2str(ff.oldPars(1)),', \lambda:',num2str(ff.oldPars(2))],'best data',['k: ',num2str(ff.pars(1)),', \lambda:',num2str(ff.pars(2))]);
    
    print('-dpng',['best',num2str(ii),'.png']);
    print('-depsc',['best',num2str(ii),'.eps']);
    
%     pause;
    clf;
    ii = ii+1;
end

ii = 1;
for ff = worst
    tt = linspace(ff.tti(1),ff.tti(end),100);
    
    hold on; grid on;
    plot(ff.tti,ff.contr,'o');
    plot(tt, ff.oldPars(1)*exp(-tt/ff.oldPars(2)));
    plot(ff.tti(ff.bestData),ff.contr(ff.bestData),'ro');
    plot(tt, ff.pars(1)*exp(-tt/ff.pars(2)),'r');
    
    axis([ff.tti(1),ff.tti(end),minMax(ff.contr)]);
%     axis(gca,'OuterPosition',[0 0 1 1]);
    title(['intError: ', num2str(ff.intErr)]);
    legend('data',['k: ',num2str(ff.oldPars(1)),', \lambda:',num2str(ff.oldPars(2))],'best data',['k: ',num2str(ff.pars(1)),', \lambda:',num2str(ff.pars(2))]);
    
    print('-dpng',['worst',num2str(ii),'.png']);
    print('-depsc',['worst',num2str(ii),'.eps']);
    
%     pause;
    clf;
    ii = ii+1;
end


lam = [best.pars]; lam = lam(2:2:end);
hist(lam); title(['median \lambda; ', num2str(median(lam))]);
print('-dpng','histLamFit.png');
print('-depsc','histLamFit.eps');

close all;

end