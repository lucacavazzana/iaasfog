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

alg = selectAlg({'printFeats',...
                'printFeats2',...
                'printBestWorst',...
                'ransac'});

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
    case 1,
        printFeats(feats);
    case 2,
        normContrastTest(feats,'fitExp',3);
    case 3,
        printBestWorst(feats);
    case 4
        printRansac(feats);
end

end