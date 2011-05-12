function [] = compareFits()

imStart = ['frame0000.jpg';...
    'frame0020.jpg';...
    'frame0040.jpg';...
    'frame0060.jpg'];

n = [15,25,35,50];

resLam = zeros(4,4,10);
resRans = zeros(4,4,10);
featNum = zeros(4,4,10);

% tic
% 
% for ii = 1:5
%     for st = 1:size(imStart,1)
%         cmd = ['c++/Debug/iaasfog -f /home/luca/Matlab/iaasfog/Images -i ', imStart(st,:),' -n 50 -o compare.txt'];
%         system(cmd);
%         feats = parseFeatures('compare.txt', 1);
%         
%         % start X numFr
%         featNum(st,ii) = max(size(feats));
%         resLam(st,ii) = estimateLamFit(feats,0);
%         pause(10);
%         try
%             resRans(st,ii) = fitNormRansac(feats,0);
%         catch e
%             resR
%         end
%         pause(10);
%     end
% end
% toc
% keyboard

for ii = 1:10;
    for st = 1:size(imStart,1)
        for num = 1:size(n,2)
            
            cmd = ['c++/Debug/iaasfog -f /home/luca/Matlab/iaasfog/Images -i ', imStart(st,:),' -n ', num2str(n(num)),' -o compare.txt'];
            system(cmd);
            feats = parseFeatures('compare.txt', 1);
            
            % start X numFr
            featNum(st,num,ii) = max(size(feats));
            resLam(st,num,ii) = estimateLamFit(feats,0);
            try
                resRans(st,num,ii) = fitNormRansac(feats,0);
            catch e
                resRans(st,num,ii) = -1;
            end
        end
    end
end

keyboard

end