function [k, lam, rmse] = fitExp(x, y)

% see http://mathworld.wolfram.com/LeastSquaresFittingExponential.html

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
