function [] = showVideo()

imFolder = '/home/luca/Matlab/iaasfog/Images';
imName = 'frame0000.jpg';
num = 113;
paths = getPaths(imFolder, imName, num);

img = rgb2gray(imread(paths(1,:)));
img = reshape(img, size(img,1), size(img,2), num);
for ii = 2:num
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

end