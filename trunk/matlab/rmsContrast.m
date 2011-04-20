function [contr] = rmsContrast(feature, image)

%RMSCONTRAST compute the comtrast level using root mean square
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
%       image = imread('myImage.jpg');
%       contr = rmsContrast(coords,image);
%
%   See also MICHELSONCONTRAST, WEBERCONTRAST.

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

if exist('image','var')
    n = 2; % feature window
    
    % Normalize
    if feature.z~=1
        feature.x = feature.x/feature.z;
        feature.y = feature.y/feature.z;
    end
    
    if size(image,1)==1 % if ==1 is a string...
        image = imread(image);
    end
    if size(image,3)==3 % if ==3 RGB. FIXME: use the new function when isrgb will be replaced
        image = rgb2gray(image);
    end
    
    % frame around the feature
    xi = max(round(feature.x - n),1);
    xf = min(round(feature.x + n),size(image,2));
    yi = max(round(feature.y - n),1);
    yf = min(round(feature.y + n),size(image,1));
    
    image = im2double(image(yi:yf,xi:xf));
else
    image = feature; %pointing at the same data... matlab doesn't allocate new memory until variables differ
    clear feature;
end

%--------------------------------------------------------------------------
% Find root mean square contrast
%--------------------------------------------------------------------------

image = image(:); % make it vector
m = mean(image);
image = image - m;

contr=norm(image)/sqrt(numel(image));

end
