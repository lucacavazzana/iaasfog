function[contr] = michelsonContrast(feature, image, n)

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
end

%--------------------------------------------------------------------------
% Find Michelson contrast
%--------------------------------------------------------------------------

% Min&max intensity
I_max = im2double(max(max(image)));
I_min = im2double(min(min(image)));

% Compute contrast
contr = (I_max-I_min)/(I_max+I_min);