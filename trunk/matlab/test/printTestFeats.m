% carica dati salvati mediante

clear all;
FIT = 0; RANSAC = 1;

% - indici dell'immagine da visualizzare / printare------------------------
st = 1;     % first image
num = 4;    % {15, 25, 35, 50}
it = 1;     % nth iteration

SAVE = 1;   % if 1 saves images, else just visualize
ALG = FIT;  % FIT / RANSAC}. Choose the alg used to compute lam
%--------------------------------------------------------------------------

load('oldImgs.mat','res','n','imStart');

if SAVE
    if ~exist('./lol','dir')
        !mkdir lol
    end
end

feats = res(st, num, it).feats;
lamF = res(st, num, it).fit;
lamR = res(st, num, it).rans;
if ALG == FIT
    lam = lamF;
else
    lam = lamR;
end

im = imStart(st,:);
s = str2double(im(end-7:end-4));

save('lol/data.mat','feats','im','n','lamF','lamR');

for ii = 1:size(feats,2)
    asd = fit(feats(ii).tti',feats(ii).contr','exp1');
    feats(ii).contr = feats(ii).contr/asd.a;
end

for ii = 1:n(num)
    im(end-3-size(num2str(s+ii-1),2):end-4) = num2str(s+ii-1);
    imshow(imread(im));
    title(sprintf('%s, %d of %d - \\lambda: %f',im, ii,n(num), lam)); hold on;
    
    for ff=feats
        if (ii>=ff.start && ii<=(ff.start+ff.num-1))
            if ff.tti(ff.num-ii+ff.start) > lamF
                plot(ff.x(ff.num-ii+ff.start),ff.y(ff.num-ii+ff.start),'*');
            else
                plot(ff.x(ff.num-ii+ff.start),ff.y(ff.num-ii+ff.start),'r*');
            end
        end
    end
    
    set(gca,'Position',[0 0 1 .9]);
    drawnow;
    if SAVE
        try
            print('-dpng',['lol/',im(max(strfind(im,'/'))+1:end-3),'png']);
            disp([im, ' saved']);
        catch e
            warning(e.identifier,'%s, make sure the folder exists',e.message);
        end
    else
        disp('hit a key to continue');
        pause;
    end
    
    clf;
end

imshow(imread(im));
for ff = feats
    line([ff.x(1) ff.x(end)],[ff.y(1) ff.y(end)],'LineWidth',2);
end
set(gca,'Position',[0 0 1 1]);

if SAVE
    try
        print('-dpng','lol/flow.png');
        disp('flow saved');
    catch e
        warning(e.identifier,'%s, make sure the folder exists',e.message);
    end
else
    disp('hit a key to end');
    pause;
end

fprintf('%s + %i - it %i\n', imStart(st,:), n(num), it);

close;