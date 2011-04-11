function [] = theNewWay(imPaths, feats, showPlot)

%THENEWWAY
%

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/04/09 11:59:22 $


%% COMMENTI:
% frequenza fra i frames fissata => dt fisso ($\frac{1}{25}$ ... $\frac{1}{30}$)

NFEAT = size(feats,2);

%% vecchia parte dove si calcola contrasto a mano (...o 'a Matalb')
% [NIMG, NFEAT] = size(feats);
%
% % first of all we are computing contrast level using different algorithms
% wContr = zeros(NIMG, NFEAT);
% mContr = wContr; rmsContr = wContr;
% for ii=1:NIMG
%     img = rgb2gray(imread(imPaths(ii,:)));
%     for ff=1:NFEAT
%         mContr(ii,ff) = MichelsonContrast(feats(ii,ff),img);
%         rmsContr(ii,ff) = rmsContrast(feats(ii,ff),img);
%         % TODO: quando hai voglia aggiungi anche Weber
%     end
% end
% clear img;

%% PLOT FEATS FOR FUN
if showPlot
    colors = ['y','m','c','r','g','b','w','k'];
    figure; hold on;
    for ii = 1:NFEAT
        plot(feats(ii).start:feats(ii).start+feats(ii).num-1, feats(ii).contr/feats(ii).contr(end), colors(rem(ii,8)+1));
        pause(.3);
    end
end

% myRansac(rmsContr)

end