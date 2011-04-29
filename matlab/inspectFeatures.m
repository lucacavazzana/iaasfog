function [] = inspectFeatures(imPaths, feats)

%COMPARECONTRASTS shows contrast levels.
%
%   COMPARECONTRASTS(IMPATHS, FEATS, VP) visually compare the computed
%   levels of fog using RMS. IMPATHS is Mx: matrix containing the complete
%   paths of the M images in the serie, FEATS a vector of N features as
%   rapresented by the output of the function newParser

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/11 17:20:22 $

% REMEMBER: in 'feats' elements are ordered from the nearest to the
% farthest

OVERTTI = 1; % =0 plots over frames, =1 over time-to-impact

WIN = 40 /2; % size of the window

fig = figure;

indf=1;
for ff = feats
    subplot(2,2,1);
    t = ff.start:ff.start+ff.num-1;
    hold off;
    if OVERTTI
        plot(ff.tti,ff.contr);
    else
        plot(t,ff.contr(end:-1:1)); % plot contrast graph
    end
    title(['contrast ', num2str(ff.start), ' - ', num2str(ff.start+ff.num-1)]);
    hold on;
    for ii = ff.num:-1:1
        im = imread(imPaths(t(ff.num-ii+1),:));
        img = rgb2gray(im);
        
        % print current contrast
        subplot(2,2,1);
        hold on;
        
        if OVERTTI
            plot(ff.tti(ii),ff.contr(ii),'o');
        else
            plot(t(ff.num-ii+1),ff.contr(ii),'o');
        end
        
        % print detail of the current feature
        subplot(2,2,2);
        hold off;
        imshow(img(max(1,uint16(ff.y(ii)-WIN)):min(size(img,1),uint16(ff.y(ii))+WIN),...
            max(1,uint16(ff.x(ii)-WIN)):min(size(img,2),uint16(ff.x(ii))+WIN)));
        hold on;
        plot(min(uint16(ff.x(ii)),WIN+1),min(uint16(ff.y(ii)),WIN+1),'o');
        title('detail');
        
        % plot overview of the image
        subplot(2,2,[3,4]);
        imshow(img);
        hold on;
        plot(ff.x(ii),ff.y(ii),'*');
        title(['feat ',num2str(ff.num-ii+1),'/',num2str(ff.num),', set ',num2str(indf),'/',num2str(size(feats,2))]);
        pause(.1);
    end
    indf=indf+1;
    drawnow;
    pause(.3);
    clf(fig);
end

close(fig);

end