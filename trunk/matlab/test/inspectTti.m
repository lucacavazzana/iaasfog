function [] = inspectTti(feats, imPaths)

WIN = 30 /2; % size of the window

fig = figure;

feat = 1;
for ff = feats(feat:end)
    for ii = ff.num:-1:1
        clf;
        im = imread(imPaths(ff.start+ff.num-ii,:));
        
        if size(im,3)==3
            img = rgb2gray(im);
        else
            img = im;
        end
        
        % print detail of the current feature
%         subplot(1,2,2);
%         hold off;
%         imshow(img(max(1,uint16(ff.y(ii)-WIN)):min(size(img,1),uint16(ff.y(ii))+WIN), ...
%             max(1,uint16(ff.x(ii)-WIN)):min(size(img,2),uint16(ff.x(ii))+WIN)));
%         hold on;
%         plot(min(uint16(ff.x(ii)),WIN+1),min(uint16(ff.y(ii)),WIN+1),'o');
%         title('detail');
        
        % plot overview of the image
%         subplot(1,2,1);
        imshow(img);
        hold on;
        plot(ff.x(ii), ff.y(ii),'o','MarkerFace','y','MarkerSize',8);
        set(gca,'Position',[0 0 1 1]);
        title(['frame #' num2str(ff.start+ff.num-ii), ' - tti: ', num2str(ff.tti(ii)+1/30*(ff.start-1+ff.num-ii))]);
        set(gca,'Position',[0 0 1 1]);
        print('-dpng',['asd/tti', num2str(ii), '.png']);
        disp([feat, ff.tti(ii)+1/30*(ff.start-1+ff.num-ii)]);
%         pause();
    end
    
    feat = feat+1;
    pause;
end

close(fig);

end