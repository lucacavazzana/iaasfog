function [wMean mMean] = impactTime1 (imPaths, feats, vp,  time, showPlot)

%IMPACTTIME1
%
% testing the algorithm using a 3rd degree polynomial to approximate the
% discrete contrast function.
%
%INPUT:
%   'imPaths':  MxN matrix, containing the complete paths of the M images
%               in the serie.
%   'feats':    MxN matrix containint the coordinates of the features as a
%               structure. N is the number of features, M the number of
%               images.
%   'vp':       vanishing point coords struct (x,y,z)
%   'time':     vector, for each i-th position contains the time between
%               frame i and i-1
%   showPlot:   =1 or ='true' to show various graphs (otherwise just ignore
%               it)
%OUTPUT:
%   'wMean':    mean impact time computed using Weber contrast
%   'mMean':    mean impact time computed using Michelson contrast
%
%   See also IMPACTTIME2.

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

[NIMG, NFEAT] = size(feats);

if (exist('showPlot','var') && (showPlot==1 || strcmp(showPlot,'true')))
    showPlot = 1;
else
    showPlot=0;
end

% for ii=1:2:size(imPaths,1)
%     if ii~=size(imPaths,1)
%         jj = ii+1;
%     else
%         jj = ii;
%     end
    % leggermente modificata rispetto alla versione in c++, in modo che
    % ogni livello contribuisca con lo stesso peso
    % FIXME:  non capisco la logica di sta roba... stai calcolando la media
    % dei valori di ogni singola immagine, a che scopo dargli due immagini
    % per poi farne la media? Non è meglio Calcolare il livello della
    % singola immagine? Bah...
%     fog_lev(ii) = fogLevel(vp,imPaths(ii,:),imPaths(jj,:), showPlot);
%     end
for ii=1:NIMG
    % proviamo così
    fog_lev(ii) = zoneHom(vp, imPaths(ii,:), 20, .895, .9, .3, 0); % FIXME: check parameters (n)
end;
if(all(fog_lev <= 0))
    disp('- Cannot find fog level, needed to compute Weber contrast. Proceeding using only Michelson');
    glob_fog = -1;
else
    glob_fog = sum(fog_lev.*(fog_lev>0))/sum(fog_lev>0);
    disp(['Mean fog level (grayscale): ', num2str(glob_fog)]);
end
clear fog_lev;

% preallocate
if(glob_fog ~= -1)
    wContr = zeros(NIMG,NFEAT);
end
mContr = zeros(NIMG,NFEAT);
for ii=1:NIMG % for each image
    img = rgb2gray(imread(imPaths(ii,:)));
    for ff=1:NFEAT %for each feature
        if(glob_fog ~= -1)
            wContr(ii,ff) = WeberContrast(glob_fog,img(round(feats(ii,ff).y),round(feats(ii,ff).x)));
        end
%         mContr(ii,ff) = MichelsonContrast(feats(ii,ff),img);
        mContr(ii,ff) = rmsContrast(feats(ii,ff),img); % provando RMS
    end
end
clear img;

mImVisFeat = zeros(NFEAT,1);
if(glob_fog ~= -1)
    wImVisFeat = mImVisFeat;
end
for ii=1:NFEAT % for each feature
    if (showPlot) % if we wanna plot...
        f = figure;
        if(glob_fog~=-1) % if we can use Weber use subplots
            subplot(1,2,1);
            title('Weber');
        end
    end
    
    if(glob_fog~=-1)
        wImVisFeat(ii) = imageVisibleP3(wContr(:,ii), time, showPlot);
    end
    
    if(showPlot)
        if(glob_fog~=-1)
            subplot(1,2,2);
        end
        title('Michelson');
    end
    mImVisFeat(ii) = imageVisibleP3(mContr(:,ii), time, showPlot);
    
    if (showPlot)
        pause();
        close(f);
    end
end

mIsLast = (mImVisFeat==NIMG); mImpact=zeros(NFEAT,1);
if (glob_fog~=-1)
    wIsLast = (wImVisFeat==NIMG); wImpact=zeros(NFEAT,1);
end

for jj=1:NFEAT
    mImpact(jj) = timeImpact(feats(mImVisFeat(jj)-mIsLast(jj),jj),feats(mImVisFeat(jj)+(~mIsLast(jj)),jj),vp,.1,showPlot,imPaths(mImVisFeat(jj),:));
    if(glob_fog~=-1)
        wImpact(jj) = timeImpact(feats(wImVisFeat(jj)-wIsLast(jj),jj),feats(wImVisFeat(jj)+(~wIsLast(jj)),jj),vp,.1,showPlot,imPaths(wImVisFeat(jj),:));
    end
end

if(glob_fog~=-1)
    wMean = mean(wImpact);
    if(showPlot)
        disp(['Mean time to impact with Weber: ',num2str(wMean),'s']);
    end
end

mMean = mean(mImpact);
if(showPlot)
    disp(['Mean time to impact with Michelson: ',num2str(mMean),'s']);
end

%% TODO ora dobbiamo inventarci una funzione crescente rispetto al
% tempo d'impatto medio: maggiore è la visibilità, più lontano cominceranno
% ad apparire le features, maggiore sarà il tempo d'impatto medio
% (ipotizzando scenario con distribuzione uniforme delle features nel
% tempo)

end
