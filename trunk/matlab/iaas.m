function [] = iaas()
% IAAS
%
%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

arch = computer('arch');

if strcmp(arch,'win32') || strcmp(arch,'win64')
    bin_name = 'iaasfog.exe';
else
    bin_name = 'iaasfog';
end

% REMEMBER TO REMOVE ------------------------------------------------------
SHOWPLOTS = 0;
DEFPATHS = 1;
if ~regexp(path,'/home/luca/','once')
    imFolder = '/home/luca/Matlab/iaasfog/Images';
    alg = 0;
elseif regexp(path,'/home/stefano/','once')
    imFolder = '/home/stefano/Matlab/iaasfog/Images';
else
    DEFPATHS = 0; % se non sei ne Luca ne Stefano ti tocca inserire a mano i path
end
outFile = 'outFile.txt';
imName = 'frame0020.jpg';
imNum = 6;
imTime = 0.1;
speed = 0;
% -------------------------------------------------------------------------

exec_path = ['c++/Debug/', bin_name]; % path of the c++ part of the project. Make sure it exists
if exist(exec_path,'file')~=2
    error('- ERROR: cannot find the feature-finding executable. Click on this message to fix the path');
end

if ~DEFPATHS % FIXME: delete this condition in the final release
    imFolder = getFolder;
    imName = getImagesName(imFolder);
    imNum = getNumImages;
    imTime = getPeriod;
    alg = selectAlg;
end

% checks the image list
imPaths = getPaths(imFolder,imName,imNum);

if ~DEFPATHS % FIXME: delete this condition in the final release
    disp('Computing image features. Could take some time...');
    if(system([exec_path,' -v -f ',imFolder,' -i ',imName,' -n', num2str(imNum),' -t' num2str(imTime),' -o',outFile])~=0)
        disp('    - ERROR in finding features. Exit');
        return;
    end
end

[vp,feats] = parseFeatures(outFile); % re-parsing features
vp_st.x=vp(1); vp_st.y=vp(2); vp_st.z=vp(3); clear vp;
imTime = imTime*ones(1,imNum); imTime(1)=0; % time vector

disp(['Found ', num2str(size(feats,1)), ' features over ', num2str(size(feats,2)), ' images']);

switch alg
    case 0,
        checkFeatures(imPaths, feats'); % visually check features
    case 1,
        impactTime1(imPaths, feats', vp_st, imTime, 1); % polynomial interpolation
    case 2,
        impactTime2(imPaths, feats', vp_st, imTime, 1); % exp interpolation
end

end
