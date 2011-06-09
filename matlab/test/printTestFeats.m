% carica dati salvati mediante

if ~exist('res','var')
    load oldImgs.mat
end

% indici dell'immagine da printare------------------------------
st = 1;
num = 4;
it = 1;

SAVE = 1;
%----------------------------------------------------------------

feats = res(st, num, it).feats;
lamF = res(st, num, it).fit;
lamR = res(st, num, it).rans;

im = imStart(st,:);
s = str2double(im(end-7:end-4));

save(['test/',im(1:max(strfind(im,'/'))),'data.mat'],'feats','im','n','lamF','lamR');

for ii = 1:size(feats,2)
    asd = fit(feats(ii).tti',feats(ii).contr','exp1');
    feats(ii).contr = feats(ii).contr/asd.a;
end

for ii = 1:n(num)
    im(end-3-size(num2str(s+ii-1),2):end-4) = num2str(s+ii-1);
    imshow(rgb2gray(imread(im)));
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
            print('-dpng',['test/',im(1:end-3),'png'],'-loose');
        catch e
            warning(e.identifier,'%s, make sure the folder exists',e.message);
        end
    end
    
%     pause;
    clf;
end

close;