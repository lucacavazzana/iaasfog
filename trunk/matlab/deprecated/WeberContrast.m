function[w_contr] = WeberContrast(fog_level, feature, image)

%[w_contr] = WEBER_CONTRAST(fog_level, feature, image)
% compute the Weber contrast level on the specified grayscale point
%
%INPUT
%   'fog_level':    graylevel in the vanishing point
%   'feature':      feat coords struct or uint value
%   'image':        image (path or matrix). Parameter eeded if 'features'
%                   if 'feature' is a coordinates struct
%
%OUTPUT
%   'w_contr':      Weber contrast level
%
%   See also MICHELSONCONTRAST, RMSCONTRAST.

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $


if isstruct(feature) % if are coordinates...
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
    
%--------------------------------------------------------------------------
% Find Weber contrast
%--------------------------------------------------------------------------
    
    % Feature intensity
    If = double(image(round(feature.y), round(feature.x)));
else % else, if is the value...
    If = im2double(feature);
end

% Weber contrast
w_contr = abs((If - fog_level) / fog_level);