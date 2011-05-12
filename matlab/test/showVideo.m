function [] = showVideo()

imFolder = '/home/luca/Matlab/iaasfog/Images';
imName = 'frame0000.jpg';
num = 99;
paths = getPaths(imFolder, imName, num);

for ii = 1:num
    img(:,:,ii) = rgb2gray(imread(paths(ii,:)));
end

w = 1/30;
for ii = 1:num
    tic
    imshow(img(:,:,ii));
    pause(w);
    clf;
    toc
end

close all;