function[wContr] = weberContrast(feature, image, n, fogLevel)

%[w_contr] = WEBER_CONTRAST(fogLevel, feature, image)
% compute the Weber contrast level on the specified grayscale point
%
%INPUT
%   'feature' : feat coords struct or uint value
%   'image'   : image (path or matrix). Parameter needed if 'features'
%               if 'feature' is a coordinates struct
%   'n'       : frame radius (window will have a 2*n+1 side)
%   'fogLevel': graylevel in the vanishing point (if omitted, it will
%               use the mean lever around the feature)
%
%OUTPUT
%   'wContr':      Weber contrast level
%
%   See also MICHELSONCONTRAST, RMSCONTRAST.

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/05/19 $


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
    
    %frame extraction
    image = im2double(image(yi:yf,xi:xf));
else
    image = feature; %pointing at the same data... matlab doesn't allocate new memory until variables differ
    clear feature;
    if size(image,3)==3 % if ==3 RGB
        image = im2gray(rgb2gray(image));
    end
    n = floor(min(size(image))/2);
end

if ~exist('fogLevel','var')
    fogLevel = mean(mean(image));
end
    
%--------------------------------------------------------------------------
% Find Weber contrast
%--------------------------------------------------------------------------

wContr = abs((image(n+1,n+1) - fogLevel) / fogLevel);