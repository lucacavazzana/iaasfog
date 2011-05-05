function [] = iaas(showPlot)
%IAAS
%
%   bla bla bla bla
%
%   INPUT:
%     'showPlot'  : if 1 shows some cool visual feedback, if 2 shows a lot
%                   more graphs (mainly for testing purposes, can become
%                   veeery boring), if 0 plots nothing

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

% OPTIONS
REFINDFEATURES = 0;   % = 1 to call the exe to recompute the features (just to avoid wasting time recomputing during tests ont he same set of images)


if ~exist('showPlot','var')
    showPlot=0;
else
    showPlot = str2double(showPlot);
end

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
imNum = 25;
imTime = 1/30;
% -------------------------------------------------------------------------

if exist(exec_path,'file')~=2
%     error('- ERROR: cannot find the feature-finding executable. Click on this message to fix the path');
end

if ~DEFPATHS % FIXME: delete this condition in the final release
    imFolder = getFolder;
    imName = getImagesName(imFolder);
    imNum = getNumImages;
    imTime = getPeriod;
end
alg = selectAlg({'inspect features'; ...
    'plot contrasts'; ...
    'estimate lambda by min-max'; ...
    'estimate lambda by fitting'; ...
    'normalize by fitted k and then ransac'; ...
    'compare constrasts'});

% checks the image list
imPaths = getPaths(imFolder,imName,imNum);

if REFINDFEATURES || exist(outFile,'file')~=2
    disp('Computing image features. Could take some time and open funny windows...');
    if(system([exec_path,' -v -f ',imFolder,' -i ',imName,' -n', num2str(imNum),' -t' num2str(imTime),' -o',outFile])~=0)
        disp('    - ERROR in finding features. Exit');
        return;
    end
end

feats = parseFeatures(outFile); % re-parsing features

disp(['Found ', num2str(size(feats,2)), ' features over ', num2str(size(imPaths,1)), ' images']);

switch alg
    case 1, % visually check features
        inspectFeatures(imPaths, feats);
    case 2, % plots computed contrast
        plotContrasts(feats);
    case 3, % estimates lambda as t_min-t_max/ln(c_max/c_min), then 
        estimateLamMinMax(feats, showPlot);
    case 4, % estimates lamdas by fitting on each single set
        estimateLamFit(feats, showPlot);
    case 5, % computes lambda normalizing by the fitted k and then applying ransac
        fitNormRansac(feats, showPlot);
    case 6, % compare different contrast formulas
        compareContrasts(imPaths, feats, showPlot);
end

end