function [time] = getPeriod()

% queries the user for the time between images. Must be a non-zero positive
% real.

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

badTime = 1;

while badTime
    time = input('insert time between images: ');
    if ~isreal(time) || time <= 0
        disp('    - Error: time must be a positive real');
        disp(' ');
    else
        badTime = 0;
    end
end