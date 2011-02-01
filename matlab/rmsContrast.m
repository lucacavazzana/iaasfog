function [contr] = rmsContrast(feature, image)

%[contr] = RMSCONTRAST(feature, image)
% compute the root mean square contrast level around the feature in the
% image
%INPUT:
%   'feature':  feature coords struct (x,y,z)
%   'image':    image path or matrix
%OUTPUT
%   'contr':    rms contrast level
%
%   See also MICHELSONCONTRAST, WEBERCONTRAST.

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $


n = 10; % feature window

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

%--------------------------------------------------------------------------
% Find root mean square contrast
%--------------------------------------------------------------------------

image = image(:); % make it vector
m = mean(image);
image = image - m;

contr=norm(image)/sqrt(numel(image));

end