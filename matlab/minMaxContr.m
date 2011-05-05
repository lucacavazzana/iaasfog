function [lam] = minMaxContr(contr, tti)

% compute lambda as (ttiMin-ttiMax)/log(vMax/vMin) if ttiMax precedes
% ttiMin at least by half of the frames, else returns -1

if size(contr)~=size(tti)
    error('Parameters must be the same size');
end

[vMax iMax] = max(contr);
[vMin iMin] = min(contr);
if iMin-iMax > .5*max(size(contr));
    lam = (tti(iMin)-tti(iMax))/log(vMax/vMin);
else
    lam = -1;
end

end