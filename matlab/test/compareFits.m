% test function. Computes lambdas over various sets of images and saves the
% result matrix on file

%   $Revision: xxxxx $  $Date: 2011/06/08 $

% old set
imStart = ['Images/frame0000.jpg';...
    'Images/frame0020.jpg';...
    'Images/frame0040.jpg';...
    'Images/frame0060.jpg'];

clear res;

% new set
% imStart = ['newImages/Images01/frame0000.png';...
%     'newImages/Images02/frame0000.png';...
%     'newImages/Images02/frame0060.png';...
%     'newImages/Images03/frame0000.png';...
%     'newImages/Images04/frame0000.png';...
%     'newImages/Images04/frame0040.png';...
%     'newImages/Images05/frame0000.png';...
%     'newImages/Images05/frame0100.png'];

nSt = size(imStart,1);

n = [15,25,35,50];
nLen = size(n,2);

if exist('lol.mat','file')==2 % reload datas in case of crash
    load('lol.mat','res','ii','st','num');
else % initialize
    res.feats = []; % features
    res.nFeats = []; % #feats
    res.fit = []; % lambda fit
    res.rans = []; % lambda ransac
    res.rTime = []; % exec time
    res.fTime = []; % exec time
    res(nSt,nLen,10) = res; % lamer way to preallocate
    % size(res)
    
    ii = 1;
    st = 1;
    num = 1;
end

while ii<=10
    while st<=nSt
        while num<=nLen
            save('lol.mat','res','ii','st','num','imStart','n'); % mica che crasha e mi tocca ricominciare da 0, con quello che ci mette...
            fprintf('\n %s, %d frames, try #%d\n', imStart(st,:), n(num), ii);
            
            cmd = ['c++/Debug/iaasfog -f /home/luca/Matlab/iaasfog/ -i ', imStart(st,:),' -n ', num2str(n(num)),' -o compare.txt'];
            system(cmd);
            feats = parseFeatures('compare.txt', 1);
            
            % start X numFr X try
            res(st,num,ii).feats = feats;
            res(st,num,ii).nFeats = max(size(feats));
            
            if round(rand) % mixing order to avoid biasing exec time via caching
                tic;
                res(st,num,ii).fit = estimateLamFit(feats,0);
                res(st,num,ii).fTime = toc;
                %             pause(3); % per lasciare raffreddare il processore, altrimenti crasha...
                try
                    tic;
                    res(st,num,ii).rans = fitNormRansac(feats,0);
                    res(st,num,ii).rTime = toc;
                catch e
                    res(st,num,ii).rans = -1;
                    warning('Ransac failed');
                end
            else
                try
                    tic;
                    res(st,num,ii).rans = fitNormRansac(feats,0);
                    res(st,num,ii).rTime = toc;
                catch e
                    res(st,num,ii).rans = -1;
                    warning('Ransac failed');
                end
%                 pause(3); % per lasciare raffreddare il processore...
                tic;
                res(st,num,ii).fit = estimateLamFit(feats,0);
                res(st,num,ii).fTime = toc;
            end
            
            disp(mean([res(st,num,:).fit]));
%             pause(3); % per lasciare raffreddare il processore...
            
            num = num+1;
        end
        st = st+1;
        num = 1;
    end
    ii = ii+1;
    st = 1;
end

save('lol.mat','res','ii','st','num','imStart','n');

disp('DONE!');