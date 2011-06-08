function [contr] = rmsContrast(feature, image, n)

%RMSCONTRAST compute the contrast level using root mean square. The result
%   will computed on the image normalized over [0,1] (keep in mind: the
%   depends on the color depth)
%
%   RMSCONTRAST(FEATURE, IMAGE) computes the root mean square contrast
%   level in the 21x21 frame around the feature's coords. The FEATURE
%   parameter must be a coordinates struct (x,y,z), while IMAGE can be the
%   a path of an image or the image matrix itself (both RGB or grayscale).
%
%   RMSCONTRAST(FEATURE) computes the rms contrast of the feature frame
%   matrix (both RGB or grayscale) given as parameter.
%
%   Example:
%       coords.x = 100; coords.y = 200; coords.z = 1;
%       image = imread('myImage.jpg',2);
%       contr = rmsContrast(coords,image);
%
%   See also MICHELSONCONTRAST, WEBERCONTRAST.

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/05/10 $

if exist('image','var')
    if ~exist('n','var')
        n = 2; % feature window
    end
    
    % Normalize
    feature.x = round(feature.x/feature.z);
    feature.y = round(feature.y/feature.z);
    
    if size(image,1)==1 % if ==1 is a string...
        image = imread(image);
    end
    if size(image,3)==3 % if ==3 RGB. FIXME: use the new function when isrgb will be replaced
        image = rgb2gray(image);
    end
    
    % frame around the feature
    xi = max(feature.x - n,1);
    xf = min(feature.x + n,size(image,2));
    yi = max(feature.y - n,1);
    yf = min(feature.y + n,size(image,1));
    
    % extracting the feature
    image = im2double(image(yi:yf,xi:xf));
else
    image = feature; %pointing at the same data... matlab doesn't allocate new memory until variables differ
    clear feature;
    if size(image,3)==3 % if ==3 RGB
        image = im2gray(rgb2gray(image));
    end
end

%--------------------------------------------------------------------------
% Find root mean square contrast
%--------------------------------------------------------------------------

image = image(:); % make it vector
m = mean(image);
image = image - m;

contr=norm(image)/sqrt(numel(image));

end
