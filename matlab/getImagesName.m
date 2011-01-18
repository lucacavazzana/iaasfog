function [imgName] = getImagesName(imgPath)

%GETFOLDER  Query the user the name
%
%   GETIMAGESNAME('A') returns:
%
%   Copyright 1985-2010 Stefano Cadario, Luca Cavazzana
%   $Revision: 0.0.0.1 $  $Date: 2010/12/11 14:03:08 $

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