function [] = showVideo()

imFolder = '/home/luca/Matlab/iaasfog/Images';
imName = 'frame0000.jpg';
num = 113;
paths = getPaths(imFolder, imName, num);

for ii = 1:num
    img(:,:,ii) = rgb2gray(imread(paths(ii,:)));
end

w = 1/30;
for ii = 1:num
    tic
    imshow(img(:,:,ii));
    title(ii-1);
    pause(w);
    clf;
    toc
end

close all;