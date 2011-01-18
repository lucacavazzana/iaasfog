function[contr] = Michelson_contrast(feature, image)
%
%--------------------------------------------------------------------------
%[contr] = MICHELSON_CONTRAST(feature, image)
%
%Determina il contrasto di Michelson relativo alla feature considerata.
%
%INPUT
%   'feature':  coordinate omogenee della feature sull'immagine 'image';
%   'image':    immagine in cui calcolare il contrasto della feature.
%
%OUTPUT
%   'contr':    contrasto di Michelson riferito alla feature considerata.
%--------------------------------------------------------------------------


% Normalize
feature = feature / feature(3);

image = im2double(rgb2gray(image));


%__________________________________________________________________________
%Determinazione contrasto di Michelson
%__________________________________________________________________________

%Dimensioni immagine
size_im = size(image);

% Frame size
n = 4;
%Coordinate vertici 'quadratini'
xi = cast(feature(2) - n/2, 'int32');
if xi < 0
    xi = 0;
end
xf = cast(feature(2) + n/2, 'int32');
if xf > size_im(1)
    xf = size_im(1);
end
yi = cast(feature(1) - n/2, 'int32');
if yi < 0
    yi = 0;
end
yf = cast(feature(1) + n/2, 'int32');
if yf > size_im(2)
    yf = size_im(2);
end

%'Quadratino' centrato sulla feature
quad_im = image(xi:xf, yi:yf);

%Massima e minima intensit�
I_max = max(max(quad_im));
I_min = min(min(quad_im));

%Contrasto
contr = (I_max - I_min) / (I_max + I_min);