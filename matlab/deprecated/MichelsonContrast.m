function[contr] = MichelsonContrast(feature, image)

%[contr] = MICHELSON_CONTRAST(feature, image)
%
% Finds the contrast level of the given feature
%
%INPUT
%   'feature':  feature coords struct
%   'image':    image (path or matrix)
%
%OUTPUT
%   'contr':    contrasto di Michelson riferito alla feature considerata.
%
%   See also RMSCONTRAST, WEBERCONTRAST.

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

% Normalize
feature.x = feature.x/feature.z;
feature.y = feature.y/feature.z;

if size(image,1)==1 % if ==1 is a string...
    image = imread(image);
end
if size(image,3)==3 % if ==3 RGB. FIXME: use the new function when isrgb will be replaced
    image = rgb2gray(image);
end

%--------------------------------------------------------------------------
% Find Michelson contrast
%--------------------------------------------------------------------------

% Frame size
n = 10;
% Frame coords
xi = max(round(feature.x - n),1);
xf = min(round(feature.x + n),size(image,2));
yi = max(round(feature.y - n),1);
yf = min(round(feature.y + n),size(image,1));

% Frame extraction
quad_im = image(yi:yf,xi:xf);

% Min&max intensity
I_max = im2double(max(max(quad_im)));
I_min = im2double(min(min(quad_im)));

% Compute contrast
contr = (I_max-I_min)/(I_max+I_min);