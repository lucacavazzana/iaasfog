function[level] = fog_level(van_p, im1, im2, showPlot)
%
% for a more optimized function use fogLevel.m 
%
%--------------------------------------------------------------------------
%[level, find_lev] = FOG_LEVEL(van_p, im1, im2)
%Determina il livello di grigio associato alla nebbia se l'intorno del
%punto di fuga è omogeneo almeno in una delle due immagini, in caso 
%contrario non è in grado di associare nessun valore alla nebbia.
%
%INPUT
%'van_p': punto di fuga della direzione di traslazione;
%'im1': path prima immagine;
%'im2': path seconda immagine;
%'showPlot': boolean, if it's true the plots about fog level are shown. 
%
%OUTPUT
%'level': livello di grigio associato alla nebbia; -1 indica che non 
%	     è stato possibile calcolarlo.
%--------------------------------------------------------------------------


%Normalizzazione
van_p = van_p/van_p(3);


%__________________________________________________________________________
%Calcolo livelli associati alla nebbia nelle due immagini
%__________________________________________________________________________

%Numero di pixel lato 'quadratino'
n = 20;
%Parametri Canny
low_t = 0.89;
high_t = 0.9;
sigma = 0.3;

%Verifica omogeneità e calcolo livello prima immagine
[lev_1] = Zone_hom(van_p, im1, n, low_t, high_t, sigma, showPlot);
%Verifica omogeneità e calcolo livello seconda immagine
[lev_2] = Zone_hom(van_p, im2, n, low_t, high_t, sigma, showPlot);


%__________________________________________________________________________
%Calcolo livello nebbia globale
%__________________________________________________________________________

%Se entrambi i 'quadratini' sono omogenei
if ((lev_1 ~= -1) && (lev_2 ~= -1))
    level = (lev_1 + lev_2) / 2;
    find_lev = 'true';
end
%Se solo il primo 'quadratino' è omogeneo
if ((lev_1 ~= -1) && (lev_2 == -1))
    level = lev_1;
    find_lev = 'true';
end
%Se solo il secondo 'quadratino' è omogeneo
if ((lev_1 == -1) && (lev_2 ~= -1))
    level = lev_2;
    find_lev = 'true';
end
%Se nessuno dei due 'quadratini' è omogeneo
if ((lev_1 == -1) && (lev_2 == -1))
    level = 'none';
    find_lev = 'false';
end

if ((strcmp(find_lev, 'false')) == 1)
	level = -1;
end