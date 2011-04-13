function [fig] = plotContrasts(feats)

%% PLOTCOTRASTS
%PLOTCONTRASTS
%INPUT:
%   'feats' :   vector of features as parsed by parseFeatures.m
%
%OUTPUT
%   'fig'   :   figure handler

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/04/13 17:20:22 $

colors = ['y','m','c','r','g','b','w','k'];
ii = 1;
fig = figure; hold on; grid on;
for ff = feats
    plot(ff.start:ff.start+ff.num-1,ff.contr,colors(rem(ii,8)+1));
    ii = ii+1;
    pause(.2);
end


end