function [time] = getPeriod()

% queries the user for the time between images. Must be a non-zero positive
% real.

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