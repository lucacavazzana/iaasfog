function [lam] = iaas(showPlot)
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
GUI = 0;    % if 0 use our default test values

if ~exist('showPlot','var')
    showPlot=0;
else
    showPlot = str2double(showPlot);
end

if ispc
    bin_name = 'iaasfog.exe';
else
    bin_name = 'iaasfog';
end

% REMEMBER TO REMOVE ------------------------------------------------------
if regexp(path,'/home/luca/','once')
    imFolder = '/home/luca/Matlab/iaasfog/Images';
    exec_path = ['c++/Debug/', bin_name]; % path of the c++ part of the project. Make sure it exists
elseif regexp(path,'/Users/stefanocadario','once')
    imFolder = '../Images';
    exec_path = ['../Debug/', bin_name]; % path of the c++ part of the project. Make sure it exists
else
    exec_path = ['', bin_name]; % EDIT HERE!
end
outFile = 'outFile.txt';
imName = 'frame0000.jpg';
imNum = 50;
% -------------------------------------------------------------------------

if exist(exec_path,'file')~=2
    error('- ERROR: cannot find the feature-finding executable. Click on this message to fix the path');
end

% get images folder, name and number
if GUI % FIXME: delete this condition in the final release
    [imFolder, imName, imNum] = iaasGui;
end

% checks the image list
imPaths = getPaths(imFolder, imName, imNum);

alg = selectAlg({'inspect features'; ...
    'plot contrasts'; ...
    'estimate lambda by fitting'; ...
    'normalize by fitted k and then ransac'; ...
    'compare constrasts'});

if GUI || exist(outFile,'file')~=2
    disp('Computing image features. Could take some time and open funny windows...');
    
    cmd = [exec_path,' -f ',imFolder,' -i ',imName,' -n ', num2str(imNum),' -o ',outFile];
    if exist('imTime','var')
        cmd = [cmd,' -t' num2str(imTime)];
    end
    
    if(system(cmd)~=0)
        disp('    - ERROR in finding features. Exit');
        return;
    end
end

feats = parseFeatures(outFile); % re-parsing features

disp(['Found ', num2str(size(feats,2)), ' features over ', num2str(size(imPaths,1)), ' images']);

switch alg
    case 1, % visually check features
        inspectFeatures(imPaths, feats);
        lam = -1;
    case 2, % plots computed contrast
        plotContrasts(feats);
        lam = -1;
    case 3, % estimates lamdas by fitting on each single set
        lam = estimateLamFit(feats, showPlot);
    case 4, % computes lambda normalizing by the fitted k and then applying ransac
        lam = fitNormRansac(feats, showPlot);
    case 5, % compare different contrast formulas
        compareContrasts(imPaths, feats, showPlot);
        lam = -1;
end

disp(' ');
disp(['Estimated lambda: ', num2str(lam), 's']);

end