function [] = impactTime2(imPaths, feats, vp,  time, showPlot)

%IMPACTTIME2
% testing the algorithm using an exponential to approximate the discrete
% contrast function.
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
%
%   See also IMPACTTIME1.

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

[NIMG NFEAT] = size(feats);

if (exist('showPlot','var') && (showPlot==1 || strcmp(showPlot,'true') || strcmp(showPlot,'yes')))
    showPlot = 1;
else
    showPlot = 0;
end

% finding mean mean contrast level over vanishing points
fog_lev = zeros(NIMG,1);
for ii=1:NIMG
    if zoneHom(vp, imPaths(ii,:), 20, .895, .9, .3, 0) ~= -1
       fog_lev(ii) = MichelsonContrast(vp, imPaths(ii,:));
    end
end

if any(fog_lev>0)
    glob_fog = sum(fog_lev)/sum(fog_lev>0);
    disp(['Michelson contrast level over ', num2str(sum(fog_lev>0)),' (of ', num2str(NIMG),  ') vanishing points: ', num2str(glob_fog)]);
else
    disp('No homogeneous vanishing points, can''t find the fog level');
    return;
end
clear fog_lev;

% extracting contrast level for each feature
mCFeat = zeros(NIMG,NFEAT);
for ii=1:NIMG
    im = rgb2gray(imread(imPaths(ii,:)));
    for ff=1:NFEAT
        mCFeat(ii,ff) = MichelsonContrast(feats(ii,ff),im);
    end
end
clear im;

for ff=1:NFEAT
    imageVisibleExpn(mCFeat(:,ff),time,feats(:,ff)',vp,glob_fog,1);
end
if showPlot
    close;
end

end