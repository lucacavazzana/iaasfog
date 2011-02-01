function [] = checkFeatures(imPaths, feats)

%[] = CHECKFEATURES(images, feats)
% test function to visually check features consistency
% 
% INPUT
%   'imPahts':  column vector of N_IMG string containing images' paths
%   'feats':    N_IMG x N_FEATS matrix containg features' coords structs
%               (x,y,z)

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

[NIMGS, NFEATS] = size(feats);
WIND = 40;


imInfo = imfinfo(imPaths(1,:));
imgs=zeros([imInfo.Height, imInfo.Width, NIMGS],'uint8');
for ii=1:NIMGS
    imgs(:,:,ii) = rgb2gray(imread(imPaths(ii,:)));
end

for ff=1:NFEATS
    for ii=1:NIMGS
        x = floor(feats(ii,ff).x);
        y = floor(feats(ii,ff).y);
        imshow(imgs(max(1,y-WIND):min(imInfo.Height,y+WIND), max(1,x-WIND):min(imInfo.Width,x+WIND),ii)); hold on;
        plot(WIND+(y-WIND<1)*(y-WIND),WIND+(x-WIND<1)*(x-WIND),'or'); hold off;
        pause();
    end
end

close;

end