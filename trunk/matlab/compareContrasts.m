function [] = compareContrasts(imPaths, feats, vp)

%%COMPARECONTRASTS shows contrast levels.
%   COMPARECONTRASTS(IMPATHS, FEATS, VP) visually compare the computed
%   levels of fog using Weber, Michelson and RMS. IMPATHS is a Mx: matrix
%   containing the complete paths of the M images in the serie, FEATS a MxN
%   matrix containint the coordinates of the features as structure. VP is
%   the vanishing point coords struct (x,y,z).

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

[NIMG, NFEAT] = size(feats);

fog_lev = zeros(NIMG,1);
for ii=1:NIMG % homogenity check
    fog_lev(ii)=zoneHom(vp, imPaths(ii,:), 20, .895, .9, .3, 0);
end
if(all(fog_lev <= 0))
    disp('- Cannot find fog level, needed to compute Weber contrast. Proceeding using only Michelson');
    glob_fog = -1;
else
    glob_fog = sum(fog_lev.*(fog_lev>0))/sum(fog_lev>0);
    disp(['Mean fog level (grayscale): ', num2str(glob_fog)]);
end
clear fog_lev;

mContr = zeros(NIMG, NFEAT);
rmsContr = mContr;
if glob_fog~=-1
    wContr = mContr;
end
for ii=1:NIMG
    img = imread(imPaths(ii,:));
    for ff=1:NFEAT
        mContr(ii,ff)=MichelsonContrast(feats(ii,ff),img); % computing Michelson contrast
        rmsContr(ii,ff)=rmsContrast(feats(ii,ff),img); % computing RMS contrast
        if glob_fog~=-1
            wContr(ii,ff)=WeberContrast(glob_fog,img(round(feats(ii,ff).y),round(feats(ii,ff).x))); % ...and Weber contrast
        end
    end
end

for ff=1:NFEAT % shows graphs
    if glob_fog~=-1
        plot([mContr(:,ff),rmsContr(:,ff),wContr(:,ff)]);
        legend('Michelson','RMS','Weber');
    else
        plot([mContr(:,ff),rmsContr(:,ff)]);
        legend('Michelson','RMS');
    end
    title(['feature ', num2str(ff), ' of (', num2str(NFEAT),')']);
    pause;
end

for ff=1:NFEAT % now shows only RMS
    plot(mContr(:,ff)); legend('RMS');
    title(['feature ', num2str(ff), ' of (', num2str(NFEAT),')']);
    pause;
end
end
