function [imgFolder] = getFolder()

%GETFOLDER  Query the user for folder path and check it until a valid one is inserted.
%
%   GETFOLDER returns a string containing the valid folder path.
%
%   Copyright 1985-2010 Stefano Cadario, Luca Cavazzana
%   $Revision: 0.0.0.1 $  $Date: 2010/12/11 14:03:08 $

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