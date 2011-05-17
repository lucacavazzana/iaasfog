function [lam] = iaas(showPlot)
%IAAS
%
%   iaas(SHOWPLOT) computes the mean impact time in foggy conditions
%   estimating the lam parameter of the contrast function k*exp(-t/lam),
%   where t is the time of impact.
%
%   INPUT:
%     'showPlot'    : if 1 shows some cool visual feedback, if 2 shows a lot
%                     more graphs (mainly for testing purposes, can become
%                     veeery boring), if 0 plots nothing
%   OUTPUT:
%      'lam'        : computed lamda value for k*exp(-t/lam)

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

% OPTIONS
GUI = 0;    % if 0 use our default test values

try
%     !rm outFile.txt
catch e
    
end

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
if regexp(path,'/home/luca/','once')   % for Luca
    imFolder = '/home/luca/Matlab/iaasfog/Images';
    imName = 'frame0000.jpg';
    imNum = 40;
    exec_path = ['c++/Debug/', bin_name];
    
elseif regexp(path,'/Users/stefanocadario','once')  % for Stefano
    imFolder = '../Images';
    exec_path = ['../Debug/', bin_name];
    GUI = 1;
    
else
    exec_path = ['./', bin_name]; % FIXME: EDIT HERE THE PATH OF THE C++ EXE!!!
    GUI = 1;
end
outFile = 'outFile.txt';

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
    'normalize by fitted k and then ransac'});

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

feats = parseFeatures(outFile, 1); % re-parsing features

disp(['Found ', num2str(size(feats,2)), ' features over ', num2str(size(imPaths,1)), ' images']);

switch alg
    case 1, % visually check features
        inspectFeatures(imPaths, feats);
        lam = NaN;
    case 2, % plots computed contrast
        plotContrasts(feats);
        lam = NaN;
    case 3, % estimates lamdas by fitting on each single set
        lam = estimateLamFit(feats, showPlot);
    case 4, % computes lambda normalizing by the fitted k and then applying ransac
        lam = fitNormRansac(feats, showPlot);
end

if showPlot
    disp(' ');
    disp(['Estimated lambda: ', num2str(lam), ' s']);
end

end
