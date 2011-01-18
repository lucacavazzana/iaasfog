function[level] = zoneHom(van_p, im, n, low_t, high_t, sigma, showPlot)
%
%--------------------------------------------------------------------------
%[level] = ZONEHOM(van_p, im1, n, low_t, high_t, sigma)
%
%Checks if the frame around VAN_P is homogeneous (no borders are found
%using Canny filter) and returns the mean value of the grayscale pixels.
%Returns -1 if the frame is not homogeneous.
%
%INPUT
%   'van_p':    vanishing point coordinates [X,Y,Z];
%   'im':       image path;
%   'n':        frame size;
%   'low_t':    low threshold;
%   'high_t':   high threshold;
%   'sigma':    standard deviation;
%   'showPlot': optional, if equal to 1 or 'true' plots about the zone are
%               shown.
%
%OUTPUT
%   'level':    average level in the frame around the point, -1 if not
%               homogeneous
%--------------------------------------------------------------------------
%   Copyright 1985-2010 Stefano Cadario, Luca Cavazzana
%   $Revision: 0.0.0.1 $  $Date: 2010/12/ 18:22:08 $



%Normalize
van_p = van_p/van_p(3);

im = rgb2gray(imread(im));
im1 = im2double(im); % ---- FIXME: not sure this is necessary -----

%-------------------------------------
% Define the area around the point
%-------------------------------------
size_im = size(im);

% VP frame boundaries
xi = max(round(van_p(1) - n/2),1);
xf = min(round(van_p(1) + n/2),size_im(2));
yi = max(round(van_p(2) - n/2),1);
yf = min(round(van_p(2) + n/2),size_im(1));

% extracting
quad_im1 = im1(yi:yf, xi:xf);

%-------------------------------------
% Canny edge detection and cleaning
%-------------------------------------

quad1_canny = edge(quad_im1, 'canny', [low_t high_t], sigma);
quad1_clean = bwmorph(quad1_canny, 'clean');


%-------------------------------------
% [Plot]
%-------------------------------------
if (exist('showPlot','var') &&...
        (showPlot(1) == 1 || (strcmp(showPlot, 'true')) == 1))
    
    f = figure;
	subplot(1,2,1), imshow(quad_im1); 
	title('Frame around vanishing point');
	subplot(1,2,2), imshow(quad1_clean);
	title('...after Canny and clean');
    pause();
    close(f);
end

%-------------------------------------
% If the frame isn't homogeneous (ie: there are 1s after cleaning) returns
% -1, else returns the average value
%-------------------------------------

if any(any(quad1_clean))
    level = -1;
else
    level = sum(sum(quad_im1))/numel(quad_im1);
end
end