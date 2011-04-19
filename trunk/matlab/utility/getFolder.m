function [imgFolder] = getFolder()

%GETFOLDER returns a string containing the valid folder path.
%
%   GETFOLDER  Query the user for folder path and check it until a valid
%   one is inserted.

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $


badFolder = 1;

while badFolder
    imgFolder = input('insert images path: ', 's');
    
    if exist(imgFolder, 'dir') ~= 7
        disp('    - Error: the folder doesn''t exist');
        disp(' ');
    else
        badFolder = 0;
    end
end