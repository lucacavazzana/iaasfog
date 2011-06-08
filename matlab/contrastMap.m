function [contr, norm] = contrastMap(img, alg)

%COTRASTMAP
%
%   contrastMap(IMG, ALG) is a test function, computes the contrast for
%   each pixel. IMG is a path or image, ALG the algorightm used (0:RMS
%   (default),1:MICHELSON, 2:WEBER)

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/05/05 $

%default: RMS
if nargin < 2
    alg=0;
end

% CONTRAST WINDOW: 2*WIN+1
WIN = 1;

if size(img,1)==1
    img = imread(img);
end

img = im2double(rgb2gray(img));

% direi di cazziare il blurring, non risolve il vp non-omogeneo e sballa i
% valori di contrasto delle features
% h = fspecial('gaussian',10,10);
% img=imfilter(img,h);

[Y,X] = size(img);
contr = zeros(size(img));

if alg == 0 %RMS
    for yy=1:Y
        for xx=1:X
            frame = img(max(1,yy-WIN):min(Y,yy+WIN),max(1,xx-WIN):min(X,xx+WIN));
            
            m = mean(mean(frame));
            contr(yy,xx)=sqrt(sum((frame(:)-m).^2)/numel(frame));
        end
    end
    
elseif alg==1   %MICHELSON
    for yy=1:Y
        for xx=1:X
            frame = img(max(1,yy-WIN):min(Y,yy+WIN),max(1,xx-WIN):min(X,xx+WIN));

            ma = max(frame(:)); mi = min(frame(:));
            contr(yy,xx) = (ma-mi)/(ma+mi);
        end
    end
    
elseif alg==2 %WEBER
    m = mean(mean(img));
    contr = abs(img-m)/m;
end

% norm = imadjust(contr);
mi = min(min(contr)); ma = max(max(contr));
norm = (contr-mi)/(ma-mi);

figure;
subplot(2,1,1);
imshow(img);
if alg==0
    title('using RMS');
elseif alg==1
    title('using MICHELSON');
elseif alg==2
    title('using WEBER');
end
subplot(2,1,2);
imshow(norm);
title(['frame: ', num2str(2*WIN+1), 'x', num2str(2*WIN+1),' pixels. Image normalized, original values between ', num2str(min(min(contr))), ' and ', num2str(max(max(contr)))]);

end