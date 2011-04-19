function [n] = getNumImages()

% prompts for the number of image to analyse

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

badN = 1;

while badN
    n = input('images number: ');
    
    if mod(n,1) ~= 0
        disp('    - Error: number must be integer');
    elseif n < 2
        disp('    - Error: you need at least two images');
    else
        badN = 0;
    end        
end