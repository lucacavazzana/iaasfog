function [] = theNewWay(imPaths, feats, vp_st, showPlot)

%THENEWWAY
%   

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/04/09 11:59:22 $

[NIMG, NFEAT] = size(feats);


% first of all we are computing contrast level using different algorithms
wContr = zeros(NIMG, NFEAT);
mContr = wContr; rmsContr = wContr;
for ii=1:NIMG
    img = rgb2gray(imread(imPaths(ii,:)));
    for ff=1:NFEAT
        mContr(ii,ff) = MichelsonContrast(feats(ii,ff),img);
        rmsContr(ii,ff) = rmsContrast(feats(ii,ff),img);
        % TODO: quando hai voglia aggiungi anche Weber
    end
end
clear img;

myRansac(rmsContr)

end