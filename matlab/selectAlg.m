function [alg] = selectAlg()

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