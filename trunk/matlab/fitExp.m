function [k, lam, rmse] = fitExp(x, y)

%FITEXP fits parameters using least squares fitting
%   FITEXP(X,Y) returns k, lam (and eventually the computed rmse) of the
%   fitting y = k*exp(-x/lam) using least square formula.
%   Way faster than FIT, but less robust for very noisy data
%   
%   Example
%       x = linspace(0,5,20);
%       y = 10*exp(-x/5) + rand(1,20) - .5;
%       [k, lam] = fitExp(x,y);
%       xx = linspace(0,5,20);
%       plot(x,y,'o',x,k*exp(-xx/lam),'r');
%       title(sprintf('k: %f, \lambda: %f',k,lam));
%
%   See also fit http://mathworld.wolfram.com/LeastSquaresFittingExponential.html

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/06/08 $

sx = sum(x);
sx2 = sum(x.^2);
den = max(size(x))*sx2 - sx^2;

ly = log(y);
sly = sum(ly);
sxly = sum(x.*ly);

k = exp((sly*sx2 - sx*sxly)/den);
lam = -den/(max(size(x))*sxly - sx*sly);

if nargout > 2
    rmse = sqrt(mean((y-k*exp(-x/lam)).^2));
end

end
