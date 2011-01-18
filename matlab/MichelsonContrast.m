function[contr] = MichelsonContrast(feature, image)
%
%--------------------------------------------------------------------------
%[contr] = MICHELSON_CONTRAST(feature, image)
%
%Determina il contrasto di Michelson relativo alla feature considerata.
%
%INPUT
%   'feature':  coordinate omogenee della feature sull'immagine 'image';
%   'image':    immagine (matrice o path) in cui calcolare il contrasto
%               della feature.
%
%OUTPUT
%   'contr':    contrasto di Michelson riferito alla feature considerata.
%--------------------------------------------------------------------------

% Normalize
feature.x = feature.x/feature.z;
feature.y = feature.y/feature.z;

if size(image,1)==1
    image = imread(image);
end
if size(image,3)==3
    image = im2double(rgb2gray(image));
end


%__________________________________________________________________________
%Determinazione contrasto di Michelson
%__________________________________________________________________________

% Frame size
n = 50;
%Coordinate vertici 'quadratini'
xi = max(round(feature.x - n/2),1);
xf = min(round(feature.x + n/2),size(image,2));
yi = max(round(feature.y - n/2),1);
yf = min(round(feature.y + n/2),size(image,1));

%'Quadratino' centrato sulla feature
quad_im = image(yi:yf,xi:xf);

%Massima e minima intensit�
I_max = max(max(quad_im));
I_min = min(min(quad_im));

%Contrasto
contr = (I_max - I_min) / (I_max + I_min);