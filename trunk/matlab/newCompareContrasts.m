function [] = newCompareContrasts(imPaths, feats)

%%COMPARECONTRASTS shows contrast levels.
%   COMPARECONTRASTS(IMPATHS, FEATS, VP) visually compare the computed
%   levels of fog using RMS. IMPATHS is Mx: matrix containing the complete
%   paths of the M images in the serie, FEATS a vector of N features as
%   rapresented by the output of the function newParser

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/04/11 17:20:22 $

NFEAT = size(feats,2);

fig = figure;
for ff = 1:NFEAT
    t = feats(ff).start:(feats(ff).start+feats(ff).num-1);
    subplot(2,2,1);
    hold off;
    plot(t,feats(ff).contr); % plot contrast graph
    hold on;
    for ii = 1:feats(ff).num
        subplot(2,2,1);
        hold on;
        plot(t(ii),feats(ff).contr(ii),'ro'); % print current contrast
        
        subplot(2,2,2);
        img = rgb2gray(imread(imPaths(t(ii),:)));
        
        % print detail of the current feature
        imshow(img(max(1,uint16(feats(ff).y(ii)-20)):min(size(img,1),uint16(feats(ff).y(ii))+20),...
            max(1,uint16(feats(ff).x(ii)-20)):min(size(img,2),uint16(feats(ff).x(ii))+20)));
        
        subplot(2,2,[3,4]);
        imshow(img); % plot overview of the image
        hold on;
        plot(feats(ff).x(ii),feats(ff).y(ii),'ro');
        pause;
    end
end
clear img;

close(fig);
end