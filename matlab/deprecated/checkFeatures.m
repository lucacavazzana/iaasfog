function [] = checkFeatures(imPaths, feats)

%% OBSOLETE SINCE UPDATE OF THE OUTPUT FILE
%CHECKFEATURES   displays the computed features
%   CHECKFEATURES(IMAGES, FEATURES) displays each features in the sequence
%   of images. IMAGES is a column vector of strings containing the images'
%   paths, while FEATS is a matrix where in the i,j cell there is a struct
%   representing the coordinates (fields x,y,z) of the j-th feature in the
%   i-th image.
%
%   Example
%       images = ['image01.jpg'; 'image02.jpg'];
%       f1.x=1; f1.y=1; f1.z=1;
%       f2.x=2; f2.y=2; f2.z=2;
%       feat = [f1; f2];
%       checkFeatures(images,feat);

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

[NIMGS, NFEATS] = size(feats);
WIND = 40; % frame size


imInfo = imfinfo(imPaths(1,:));
imgs=zeros([imInfo.Height, imInfo.Width, NIMGS],'uint8');
for ii=1:NIMGS
    imgs(:,:,ii) = rgb2gray(imread(imPaths(ii,:)));
end

figure;
for ff=1:NFEATS
    for ii=1:NIMGS
        subplot(1,2,1);
        x = floor(feats(ii,ff).x);
        y = floor(feats(ii,ff).y);
        imshow(imgs(max(1,y-WIND):min(imInfo.Height,y+WIND), max(1,x-WIND):min(imInfo.Width,x+WIND),ii)); hold on;
        plot(WIND+(y-WIND<1)*(y-WIND),WIND+(x-WIND<1)*(x-WIND),'or'); hold off;
        subplot(1,2,2);
        imshow(imgs(:,:,ii)); hold on;
        plot(feats(ii,ff).x,feats(ii,ff).y,'o'); hold off;
        title(['feat ', num2str(ff), ', image ', num2str(ii)]);
        pause();
    end
end

close;

end