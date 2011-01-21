function [] = iaas()

%% IAAS
%
%   Copyright 1985-2010 Stefano Cadario, Luca Cavazzana
%   $Revision: 0.0.0.1 $  $Date: 2010/12/ 18:22:08 $

exec_path = 'c++/Debug/iaasfog'; % path of the c++ part of the project. Make sure it exists
if exist(exec_path,'file')~=2
    error('- ERROR: cannot find the feature-finding executable. Click on this message to fix the path');
end

% REMEMBER TO REMOVE ------------------------------------------------------
SHOWPLOTS = 1;
DEFPATHS = 1;
if regexp(path,'/home/luca/','once')
    imFolder = '/home/luca/Matlab/iaasfog/Images';
    outFile = 'outFile.txt';
else
    error('    unhandled Stefano_è_frocio_exception');
end
imName = 'frame0020.jpg';
imNum = 6;
imTime = 0.1;
speed = 0;
% -------------------------------------------------------------------------


if ~DEFPATHS
    imFolder = getFolder;
    imName = getImagesName(imFolder);
    imNum = getNumImages;
    imTime = getPeriod;
end

% checks the image list
imPaths = getPaths(imFolder,imName,imNum);

if(system([exec_path,' -v -f ',imFolder,' -i ',imName,' -n', num2str(imNum),' -t' num2str(imTime),' -o',outFile])~=0)
    disp('    - ERROR in finding features. Exit');
    return;
end


[vp,feats] = parseFeatures(outFile); % re-parsing features
imTime = imTime*ones(1,imNum); imTime(1)=0; % time vector

disp(['Found ', num2str(size(feats,1)), ' features over ', num2str(size(feats,2)), ' images']);

% impactTime1(imPaths, feats', vp, imTime, SHOWPLOTS);
impactTime2(imPaths, feats', vp, imTime, 1);
end
