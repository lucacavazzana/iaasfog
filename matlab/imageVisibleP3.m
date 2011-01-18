function [im_vis] = imageVisibleP3(contr, time, showPlot)

%
%--------------------------------------------------------------------------
%[im_vis] = IMAGE_VISIBLE_P3(contr, time, showPlot)
%Given the discrete visibility function returns the number of the image
%where the feature becomes visible, choosen as the nearest to the point of
%inflection of the 3rd degree polynomial fitting the discrete function.
%
% INPUT
%   'contr':    vector containing the value of the feature in the Ith
%               image
%   'time:      vector array containing the time from image I-1 to I
%   'showPlot': if >=1 shows plot, no if <1
%
% OUTPUT
%   'im_vis':   number of the image where the feature become visible
%--------------------------------------------------------------------------

% Check
if size(time,1)==1
    time = time';
end
if any(size(time)~=size(contr))
    error('     size time and contrast arrays must have the same dimension');
end

% Image time
inTime = cumsum(time); % lol
 
%-------------------------------------------
% Determinazione funzione continua e flesso
%-------------------------------------------

% 3rd degree polynomial fitting the data
pol3 = polyfit(inTime, contr, 3);
if pol3(1) == 0
    display('Cannot find a 3rd degree polynomial!');
    return;
end

% % inflection point (we're considering it as the poit where the feeature
% % become visible
der2_pol3 = polyder(polyder(pol3));
t_visible = roots(der2_pol3);
% % nearest image
[min_dt, im_vis] = min(abs(inTime - t_visible));
    

%-------------------------------
% [Plot]
%-------------------------------
if (showPlot < 1)
    return;
end

hold on;
plot(inTime, contr,'s', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');

% plot polynomial
X = linspace(inTime(1), inTime(size(inTime,1)), 100);
Ypol3 = pol3(1)*X.^3 + pol3(2)*X.^2 + pol3(3)*X + pol3(4);
plot(X, Ypol3,'b', 'MarkerSize', 3);

% plot derivative
% Yder = der2_pol3(1)*X + der2_pol3(2);
% plot(X, Yder,'g');

% plot where image becomes visible (2nd der = 0)
plot(t_visible, pol3(1)*t_visible^3 + pol3(2)*t_visible^2 + pol3(3)*t_visible + pol3(4),'o','MarkerFaceColor', 'b'); % cont
plot(inTime(im_vis), contr(im_vis), 'sr', 'LineWidth', 2); % disc

end