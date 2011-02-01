function[level] = zoneHom(vp, im, n, low_t, high_t, sigma, showPlot)

%[level] = ZONEHOM(van_p, im1, n, low_t, high_t, sigma)
%Checks if the frame around VAN_P is homogeneous (no borders are found
%using Canny filter) and returns the mean value of the grayscale pixels.
%Returns -1 if the frame is not homogeneous.
%
%INPUT
%   'vp':    vanishing point coordinates [X,Y,Z];
%   'im':       image path;
%   'n':        frame size;
%   'low_t':    low threshold;
%   'high_t':   high threshold;
%   'sigma':    standard deviation;
%   'showPlot': optional, if equal to 1 or 'true' plots about the zone are
%               shown.
%
%OUTPUT
%   'level':    double representing the average level in the frame around
%               the point, -1 if not homogeneous

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $


%Normalize
vp.x = round(vp.x/vp.z); vp.y=round(vp.y/vp.z);

im = rgb2gray(imread(im));

%-------------------------------------
% Define the area around the point
%-------------------------------------
size_im = size(im);

% VP frame boundaries
xi = max(round(vp.x - n/2),1);
xf = min(round(vp.x + n/2),size_im(2));
yi = max(round(vp.y - n/2),1);
yf = min(round(vp.y + n/2),size_im(1));

% extracting
quad_im = im(yi:yf, xi:xf);
%-------------------------------------
% Canny edge detection and cleaning
%-------------------------------------
quad_canny = edge(quad_im, 'canny', [low_t high_t], sigma);
quad_clean = bwmorph(quad_canny, 'clean');

%-------------------------------------
% [Plot]
%-------------------------------------
if (exist('showPlot','var') &&...
        (showPlot(1) == 1 || (strcmp(showPlot, 'true')) == 1))
    
    f = figure;
    subplot(1,2,1), imshow(quad_im);
    title('Frame around vanishing point');
    subplot(1,2,2), imshow(quad_clean);
    title('...after Canny and clean');
    pause();
    close(f);
end

%-------------------------------------
% If the frame isn't homogeneous (ie: there are 1s after cleaning) returns
% -1, else returns the average value
%-------------------------------------

if any(any(quad_clean))
    level = -1;
else
    level = sum(sum(im2double(quad_im)))/numel(quad_im);
end
end