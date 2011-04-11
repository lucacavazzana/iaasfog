function [] = iaas()
%IAAS

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

% OPTIONS
REFIND_FEATURES = 0;   % = 1 to call the exe to recompute the features (useless and costly for multiple run on the same set of images)
SHOWPLOTS = 0; % = 1 to show some cool animations


arch = computer('arch');

if strcmp(arch,'win32') || strcmp(arch,'win64')
    bin_name = 'iaasfog.exe';
else
    bin_name = 'iaasfog';
end

% REMEMBER TO REMOVE ------------------------------------------------------
DEFPATHS = 1;

if regexp(path,'/home/luca/','once')
    imFolder = '/home/luca/Matlab/iaasfog/Images';
    exec_path = ['c++/Debug/', bin_name]; % path of the c++ part of the project. Make sure it exists
elseif regexp(path,'/Users/stefanocadario','once')
    imFolder = '../Images';
    exec_path = ['../Debug/', bin_name]; % path of the c++ part of the project. Make sure it exists
else
    DEFPATHS = 0; % se non sei ne Luca ne Stefano ti tocca inserire a mano i path
end
outFile = 'outFile.txt';
imName = 'frame0020.jpg';
imNum = 6;
imTime = 0.1;
speed = 0;
% -------------------------------------------------------------------------

if exist(exec_path,'file')~=2
    error('- ERROR: cannot find the feature-finding executable. Click on this message to fix the path');
end

if ~DEFPATHS % FIXME: delete this condition in the final release
    imFolder = getFolder;
    imName = getImagesName(imFolder);
    imNum = getNumImages;
    imTime = getPeriod;
end
alg = selectAlg({'check features';...
                 'compute impact time by polynomial interpolation';...
                 'compute impact time by exponential interpolation';...
                 'compare contrast algorightms';...
                 'new experiment'});

% checks the image list
imPaths = getPaths(imFolder,imName,imNum);

if REFIND_FEATURES || exist(outFile,'file')~=2
    disp('Computing image features. Could take some time and open funny windows...');
    if(system([exec_path,' -v -f ',imFolder,' -i ',imName,' -n', num2str(imNum),' -t' num2str(imTime),' -o',outFile])~=0)
        disp('    - ERROR in finding features. Exit');
        return;
    end
end

[vp,feats] = parseFeatures(outFile); % re-parsing features
vp_st.x=vp(1); vp_st.y=vp(2); vp_st.z=vp(3); clear vp;
imTime = imTime*ones(1,imNum); imTime(1)=0; % time vector

if strcmp(arch,'glnxa64') % that's because Luca's computer sucks and is unable to compute the vp correctly
    vp_st.x=190; vp_st.y=120; vp_st.z=1;
end

disp(['Found ', num2str(size(feats,1)), ' features over ', num2str(size(feats,2)), ' images']);

switch alg
    case 1, % visually check features
        checkFeatures(imPaths, feats');
    case 2, % polynomial interpolation
        impactTime1(imPaths, feats', vp_st, imTime, 1);
    case 3, % exp interpolation
        impactTime2(imPaths, feats', vp_st, imTime, 1);
    case 4, % compare contrast algs
        compareContrasts(imPaths, feats', vp_st);
    case 5, % new test alg
        theNewWay(imPaths, feats', vp_st, 1);
end

return;

end
