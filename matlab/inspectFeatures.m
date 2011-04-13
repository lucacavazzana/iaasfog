function [] = inspectFeatures(imPaths, feats)

%%COMPARECONTRASTS shows contrast levels.
%   COMPARECONTRASTS(IMPATHS, FEATS, VP) visually compare the computed
%   levels of fog using RMS. IMPATHS is Mx: matrix containing the complete
%   paths of the M images in the serie, FEATS a vector of N features as
%   rapresented by the output of the function newParser

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/04/11 17:20:22 $

NFEAT = size(feats,2);
WIN = 40 /2; % size of the window

fig = figure;
for ff = 30:NFEAT
    t = feats(ff).start:(feats(ff).start+feats(ff).num-1);
    subplot(2,2,1);
    hold off;
    plot(t,feats(ff).contr); % plot contrast graph
    hold on;
    for ii = 1:feats(ff).num
        
        % print current contrast
        subplot(2,2,1);
        hold on;
        plot(t(ii),feats(ff).contr(ii),'ro');
        title('contrast');
        
        % print detail of the current feature
        subplot(2,2,2);
        img = rgb2gray(imread(imPaths(t(ii),:)));
        hold off;
        imshow(img(max(1,uint16(feats(ff).y(ii)-WIN)):min(size(img,1),uint16(feats(ff).y(ii))+WIN),...
            max(1,uint16(feats(ff).x(ii)-WIN)):min(size(img,2),uint16(feats(ff).x(ii))+WIN)));
        hold on;
        plot(min(uint16(feats(ff).x(ii)),WIN+1),min(uint16(feats(ff).y(ii)),WIN+1),'ro');
        title('detail');
        
        % plot overview of the image
        subplot(2,2,[3,4]);
        imshow(img);
        hold on;
        plot(feats(ff).x(ii),feats(ff).y(ii),'ro');
        title(['feat ',num2str(ii),'/',num2str(max(feats(ff).num)),', set ',num2str(ff),'/',num2str(max(size(feats)))]);
        pause(.1);
    end
end
clear img;

close(fig);
end