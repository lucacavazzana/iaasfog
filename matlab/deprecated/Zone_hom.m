function[level] = Zone_hom(van_p, im, n, low_t, high_t, sigma, showPlot)
%

% for a more optimized function use zoneHom.m

%--------------------------------------------------------------------------
%[level] = ZONE_HOM(van_p, im1, n, low_t, high_t, sigma)
%Determina se il quadratino centrato in 'van_p' � da considerarsi omogeneo
%e, se � cos�, calcola il livello associato alla zona, altrimenti l'uscita vale -1. La zona �
%considerata omogenea quando non vengono individuati bordi al suo interno,
%la ricerca dei bordi viene fatta utilizzando il metodo di Canny.
%
%INPUT
%'van_p': punto di fuga della direzione di traslazione;
%'im': path immagine;
%'n': numero di pixel del lato del quadratino.
%'low_t': threshold basso;
%'high_t': threshold alto;
%'sigma': deviazione standard;
%'showPlot': boolean, if it's true the plots about the zone are shown.
%
%OUTPUT
%'level': livello associato alla zona, vale -1 se la zona non � omogenea.
%--------------------------------------------------------------------------


%Normalizzazione
van_p = van_p/van_p(3);

%Scala di grigi
im = imread(im);
im1 = im2double(rgb2gray(im));  % FIXME: not sure im2double is necessary


%__________________________________________________________________________
%Determinazione intorno del punto di fuga
%__________________________________________________________________________

%Dimensioni immagine
size_im = size(im1);

%Coordinate vertici 'quadratini'
xi = cast(van_p(2) - n/2, 'int32');
if xi < 1
    xi = 1;
end
xf = cast(van_p(2) + n/2, 'int32');
if xf > size_im(1)
    xf = size_im(1);
end
yi = cast(van_p(1) - n/2, 'int32');
if yi < 1
    yi = 1;
end
yf = cast(van_p(1) + n/2, 'int32');
if yf > size_im(2)
    yf = size_im(2);
end

%'Quadratini'
quad_im1 = im1(xi:xf, yi:yf);


%__________________________________________________________________________
%Canny edge detection
%__________________________________________________________________________

quad1_canny = edge(quad_im1, 'canny', [low_t high_t], sigma);

%Applicazione operatore clean
quad1_clean = bwmorph(quad1_canny, 'clean');


%__________________________________________________________________________
%Plot
%__________________________________________________________________________

%Plot 'quadratino'
if ((strcmp(showPlot, 'true')) == 1)
	fig_quad1 = figure;
	subplot(1,2,1), imshow(quad_im1); 
	title('''Quadratino'' centrato sul punto di fuga relativo alla prima immagine.');
	subplot(1,2,2), imshow(quad1_clean);
	title('''Quadratino'' dopo Canny e l''operatore clean');
end


%__________________________________________________________________________
%Verifica omogeneità 'quadratino'
%__________________________________________________________________________

%Se non viene modificato indica che il 'quadratino' a cui si riferisce è
%omogeneo
homog = 'true'; % FIXME: string as boolean? seriously?

for i = 1:n % FIXME: sure crash if the frame is smaller than n
    for j = 1:n
        if quad1_clean(i,j) == 1
            homog = 'false';
        end
    end
end


%__________________________________________________________________________
%Calcolo livello di grigio (solo se il 'quadratino' � omogeneo)
%__________________________________________________________________________

%Calcolo livello di grigio prima immagine
if (strcmp(homog, 'true')) == 1 % FIXME: can write waaaaaay better
    level = 0;
    for i = 1:n
        for j = 1:n
            level = level + quad_im1(i,j);
        end
    end
    level = level / (n*n);
else
    level = -1;
end
