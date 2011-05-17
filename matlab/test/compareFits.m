function [] = compareFits()

% imStart = ['Images01/frame0000.png';...
%     'Images02/frame0000.png';...
%     'Images02/frame0060.png';...
% 	'Images03/frame0000.png';...
%     'Images04/frame0000.png';...
%     'Images04/frame0040.png';...
%     'Images05/frame0000.png';...
%     'Images05/frame0100.png'];

imStart = ['Images/frame0000.jpg';...
    'Images/frame0020.jpg';...
    'Images/frame0040.jpg';...
    'Images/frame0060.jpg'];

nSt = size(imStart,1);

n = [15,25,35,50];
nLen = size(n,2);

resLam = zeros(nSt,nLen,10);
resRans = zeros(nSt,nLen,10);
featNum = zeros(nSt,nLen,10);

for ii = 1:10
    for st = 1:nSt
        for num = 1:size(n,2)
            
            cmd = ['c++/Debug/iaasfog -f /home/luca/Matlab/iaasfog/ -i ', imStart(st,:),' -n ', num2str(n(num)),' -o compare.txt'];
            system(cmd);
            feats = parseFeatures('compare.txt', 1);
            
            disp([st,num,ii]);
%             start X numFr
%             featNum(st,num,ii) = max(size(feats));
%             resLam(st,num,ii) = estimateLamFit(feats,0);
            try
                resRans(st,num,ii) = fitNormRansac(feats,0);
            catch e
                resRans(st,num,ii) = -1;
                disp('Ransac fail');
            end
            save lol.mat; %mica che crasha e mi tocca ricominciare da 0, con quello che ci mette...
            pause(5);
        end
    end
end
end