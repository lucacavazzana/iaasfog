function [alg] = selectAlg()

%SELECTALG   ask the user to choose a function
%   SELECTALG() displays a menu of the available functions in the IAAS
%   projectand waits for the user to choose one. Returns the integer
%   associated to the chosen function.

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

N = 2;
alg = -1;

while (alg==-1)
    disp(' ');
    disp('- Select a function:');
    disp('0: check features');
    disp('1: compute impact time by polynomial interpolation');
    disp('2: compute impact time by exponential interpolation');
    alg = str2double(input('select: ','s'));
    
    if all(alg~=(0:N))
        alg=-1;
        disp('- ERROR: bad selection');
    else
        disp(' ' );
    end
end

end