function [sel] = selectAlg(algs)

%SELECTALG   display a selection menu
%   SELECTALG(LINES) displays a text menu of item given with the LINES
%   parameter as cell array of strings, then prompts the user for a valid
%   selection.
%
%   Example:
%       sel = {'selection1', 'selection'};
%       selectAlg(sel);
%       
%       - select a function:
%       1: selection1
%       2: selection2
%       select:

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

N = max(size(algs));

if N==0
    error('non-empty items list needed');
end

sel = -1;

while (sel==-1)
    disp(' ');
    disp('- Select a function:');
    for ii=1:N
        disp([num2str(ii),': ',algs{ii}]);
    end
    sel = str2double(input('select: ','s'));
    
    if all(sel~=(1:N))
        sel=-1;
        disp('- ERROR: bad selection');
    else
        disp(' ' );
    end
end

end