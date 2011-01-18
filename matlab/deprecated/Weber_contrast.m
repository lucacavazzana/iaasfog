function[w_contr] = Weber_contrast(fog_level, feature, image)
%
%--------------------------------------------------------------------------
%[w_contr] = WEBER_CONTRAST(fog_level, feature, image)
%
%Determina il contrasto di Weber relativo alla feature e al livello di
%grigio associato alla nebbia.
%
%INPUT
%   'fog_level':livello di grigio associato alla nebbia;
%   'feature':  coordinate omogenee della feature sull'immagine 'image';
%   'image':    immagine in cui calcolare il contrasto della feature.
%
%OUTPUT
%   'w_contr':  contrasto di Weber riferito alla feature e al livello della
%               nebbia.
%--------------------------------------------------------------------------


% Normalize
feature = feature / feature(3);

image = im2double(rgb2gray(image));


%__________________________________________________________________________
%Determinazione contrasto di Weber
%__________________________________________________________________________

% Feature intensity
If = image(cast(feature(2), 'int32'), cast(feature(1), 'int32'));

% Weber contrast
w_contr = abs((If - fog_level) / fog_level);