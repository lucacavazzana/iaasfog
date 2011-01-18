function[level] = fogLevel(vp, im1, im2, showPlot)
%
%--------------------------------------------------------------------------
%[level, find_lev] = FOG_LEVEL(van_p, im1, im2)
%Determina il livello di grigio associato alla nebbia se l'intorno del
%punto di fuga è omogeneo almeno in una delle due immagini, in caso 
%contrario non è in grado di associare nessun valore alla nebbia.
%
%INPUT
%   'vp':       vanishing point [X,Y,Z];
%   'im1':      path first image;
%   'im2':      path second image;
%   'showPlot': optional, if equal to 1 or 'true' plots about the zone are
%               shown.
%
%OUTPUT
%   'level':    livello di grigio associato alla nebbia; -1 indica che non 
%	     è stato possibile calcolarlo.
%--------------------------------------------------------------------------
%   Copyright 1985-2010 Stefano Cadario, Luca Cavazzana
%   $Revision: 0.0.0.1 $  $Date: 2010/12/ 18:22:08 $


% Frame size
n = 20;
% Canny parameters
low_t = 0.89;
high_t = 0.9;
sigma = 0.3;

% Check homogeneity of the images
lev_1 = zoneHom(vp, im1, n, low_t, high_t, sigma, showPlot);
lev_2 = zoneHom(vp, im2, n, low_t, high_t, sigma, showPlot);


% If both frames are homogeneous retrurns the mean value, if only one
% returns his value, else returns -1
if ((lev_1 ~= -1) && (lev_2 ~= -1))
    level = (lev_1 + lev_2) / 2;
elseif (lev_1~=-1)
    level = lev_1;
else
    level = lev_2;
end