function [vp,feats2] = parseFeatures(fileName)

% parse the file to get vanishing point and features coordinates
% returns:
%   vp = 3x1
%   feats = array N_FEATURESxN_IMAGES, with fields x,y and z

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

f = fopen(fileName,'r');

coord_regex = '-?\d+(\.\d+)?';

tline = fgets(f);
% parse for vanishing points
vp = str2double(regexp(tline, coord_regex, 'match'));
vp(3)=1;

% skip a line
tline = fgets(f); tline = fgets(f); %#ok,

while (tline~=-1)
    if(exist('feats','var'))
        feats = [feats; str2double(regexp(tline,coord_regex,'match'))]; %#ok,
    else
        feats = str2double(regexp(tline,coord_regex,'match'));
    end
    tline = fgets(f);
end

fclose(f);

for ii=1:size(feats,1) % restructuring
    for jj=1:size(feats,2)/2
        feats2(ii,jj).x = feats(ii,jj*2-1); %#ok,
        feats2(ii,jj).y = feats(ii,jj*2); %#ok,
        feats2(ii,jj).z = 1; %#ok,
    end
end

end