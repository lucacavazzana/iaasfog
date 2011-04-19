function [imgName] = getImagesName(imgPath)

%GETFOLDER  Query the user the name
%
%   GETIMAGESNAME('A') returns:

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

badName = 1;
regex = '[0-9]{4}\.(jpg|png|tiff|bmp)$';

while badName
    imgName = input('insert the name of the first image: ', 's');
    
    if size(regexp(imgName,regex))==0
        disp('    - Error: file name must be in the form ''name####.ext''');
    elseif exist([imgPath,cast(~ispc*'/'+ispc*'\','char'),imgName], 'file') ~= 2
        disp('    - Error: file doesn''exist');
        disp(' ');
    else
        badName = 0;
    end
end