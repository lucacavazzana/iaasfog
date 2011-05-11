function [] = printTests()

%PRINTTESTS stampa immagini per la relazione

% to recompute feats
%!rm ./outFile.txt

imFolder = '/home/luca/Matlab/iaasfog/Images';
imName = 'frame0000.jpg';
imNum = 50;
exec_path = 'c++/Debug/iaasfog';
outFile = 'outFile.txt';


% checks the image list
imPaths = getPaths(imFolder, imName, imNum);

alg = selectAlg({'inspect features'; ...
    'plot contrasts'; ...
    'estimate lambda by fitting'; ...
    'normalize by fitted k and then ransac'; ...
    'compare constrasts'});

if exist(outFile,'file')~=2
    
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
    case 2, % plots computed contrast
        plotContrasts(feats);
    case 3, % estimates lamdas by fitting on each single set
        estimateLamFitTest(feats, 3);
    case 4, % computes lambda normalizing by the fitted k and then applying ransac
        fitNormRansacTest(feats, 3);
    case 5, % compare different contrast formulas
        compareContrasts(imPaths, feats, 0);
end

end