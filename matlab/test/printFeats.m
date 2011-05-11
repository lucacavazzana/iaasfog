function [feats] = printFeats(feats)

% test function for the relation

feats = normContrast(feats, 'fitExp', 0);

pos = [ 0   2/3;...
        1/3 2/3;...
        2/3 2/3;...
        0   1/3;...
        1/3 1/3;...
        2/3 1/3;...
        0   0;...
        1/3 0;...
        2/3 0];

ii = 1;
for ff = feats(1:9)
    xx = linspace(ff.tti(1),ff.tti(end),100);
    subplot(3,3,ii); hold on; grid on;
    plot(ff.tti, ff.pars(1)*ff.contr,'ro');
    plot(xx, ff.pars(1)*exp(-xx/ff.pars(2)));
    legend(['feat #', num2str(ii,2)], ['k: ', num2str(ff.pars(1),5), ', \lambda: ', num2str(ff.pars(2),5)]);
    axis([ff.tti(1),ff.tti(end), minmax(ff.pars(1)*ff.contr)]);
    set(gca,'OuterPosition',[pos(ii,:), 1/3 1/3]);
    ii = ii+1;
end
print('-dpng','feats1.png');
print('-depsc','feats1.eps');
clf;

for ff = feats(10:18)
    xx = linspace(ff.tti(1),ff.tti(end),100);
    subplot(3,3,ii-9); hold on; grid on;
    plot(ff.tti, ff.pars(1)*ff.contr,'ro');
    plot(xx, ff.pars(1)*exp(-xx/ff.pars(2)));
    legend(['feat #', num2str(ii,2)], ['k: ', num2str(ff.pars(1),5), ', \lambda: ', num2str(ff.pars(2),5)]);
    axis([ff.tti(1),ff.tti(end), minmax(ff.pars(1)*ff.contr)]);
    set(gca,'OuterPosition',[pos(ii-9,:), 1/3 1/3]);
    ii = ii+1;
end
pause;
print('-dpng','feats2.png');
print('-depsc','feats2.eps');
clf;

for ff = feats(19:27)
    xx = linspace(ff.tti(1),ff.tti(end),100);
    subplot(3,3,ii-18); hold on; grid on;
    plot(ff.tti, ff.pars(1)*ff.contr,'ro');
    plot(xx, ff.pars(1)*exp(-xx/ff.pars(2)));
    legend(['feat #', num2str(ii,2)], ['k: ', num2str(ff.pars(1),5), ', \lambda: ', num2str(ff.pars(2),5)]);
    axis([ff.tti(1),ff.tti(end), minmax(ff.pars(1)*ff.contr)]);
    set(gca,'OuterPosition',[pos(ii-18,:), 1/3 1/3]);
    ii = ii+1;
end
pause;
print('-dpng','feats3.png');
print('-depsc','feats3.eps');

end