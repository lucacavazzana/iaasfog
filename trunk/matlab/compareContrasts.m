function [] = compareContrasts(imPaths, feats, showPlot)

SCREENSHOTS = 1; %that's for me, to get some fancy screenshots

if ~exist('showPlot','var')
    showPlot = 0;
end

WRADIUS = 20;


close all;
if showPlot
    mov = figure;
end
p = figure;
fe = 1;
for ff = feats
    
    contr = zeros(3,ff.num);
    
    for ii = ff.start:ff.start+ff.num-1
        
        img = im2double(rgb2gray(imread(imPaths(ii,:))));
        crd.x = round(ff.x(ff.num-ii+1));
        crd.y = round(ff.y(ff.num-ii+1));
        crd.z = 1;
        
        xi = max(crd.x - WRADIUS,1);
        xf = min(crd.x + WRADIUS,size(img,2));
        yi = max(crd.y - WRADIUS,1);
        yf = min(crd.y + WRADIUS,size(img,1));
        
        fr = img(yi:yf,xi:xf);
        
        contr(:,ii) = [weberContrast(fr); ...
            michelsonContrast(fr); ...
            rmsContrast(fr)];
        
        if showPlot
            figure(mov);
            imshow(img); hold on;
            plot(ff.x(ff.num-ii+1),ff.y(ff.num-ii+1),'o');
            pause(.1);
        end
        
    end
    
    if showPlot
        clf(mov,'reset');
        figure(p);
    end
    
    if SCREENSHOTS
        cc(fe).c = contr;
    else
        subplot(1,3,1);
        plot(contr(1,:)'); title('Weber');
        subplot(1,3,2);
        plot(contr(2,:)'); title('Michelson');
        subplot(1,3,3);
        plot(contr(3,:)'); title('RMS');
        pause;
        clf(p,'reset');
    end
    
    fe = fe+1;
end

if SCREENSHOTS
    for ff = 10:12
        subplot(3,3,3*rem(ff-1,3)+1);
        plot(cc(ff).c(1,:)');
        subplot(3,3,3*rem(ff-1,3)+2);
        plot(cc(ff).c(2,:)');
        subplot(3,3,3*rem(ff-1,3)+3);
        plot(cc(ff).c(3,:)');
    end
    subplot(3,3,1); title('Weber');
    subplot(3,3,2); title('Weber');
    subplot(3,3,3); title('RMS');
else
    close all;
end

end