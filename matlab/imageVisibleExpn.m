function[im_vis] = imageVisibleExpn(contr, time, coords, vp, fog_lev, showPlot)

% WIP
%[im_vis] = IMAGEVISIBLEEXPN(contr, time, showPlot)
% Given the discrete contrast function returns the number of the image
% where the feature becomes visible, choosen as ...
%
% INPUT
%   'contr':    vector containing the value of the feature in the Ith
%               image
%   'time:      vector array containing the time from image I-1 to I.
%   'coords':   vector of coord struct (x,y,z) of the feature
%   'vp':       coord struct of the vanishing point (x,y,z)
%   'fog_lev':  contrast value associated to the vanishing point
%   'showPlot': if >=1 shows plot, no if <1
%
% OUTPUT
%   'im_vis':   number of the image where the feature become visible
%--------------------------------------------------------------------------
%   'coord_feat': le due righe contengono rispettivamente le coordinate della
%   feature nella penultima e nell'ultima immagine;
%   'vp':   	vanishing point coords
%   'vpCont':     fog contrast in the vanishing point
%
% OUTPUT
%   'im_vis':   number of the frame nearest to the instant the image
%               becomes visible
%--------------------------------------------------------------------------

%FIXME: remove me-----------------------------------
TEST = 0; % EXP = 0 | TANH = 1


NIMGS = size(contr,1);

if size(time,1)==1
    time = time';
end
if any(size(time)~=size(contr))
    error('     size time and contrast arrays must have the same dimension');
end

if (exist('showPlot','var') && (showPlot==1 || strcmp(showPlot,'true')))
    showPlot = 1;
else
    showPlot=0;
end

inTime = cumsum(time);
% contr = contr - fog_lev;
tImpact = abs(timeImpact(coords(1),coords(NIMGS),vp,inTime(NIMGS),0)); % se usassi coords(NIMG) invece di 2 non aumenta la precisione?

%--------------------------------------------------------------------------
% Define function parameters
%--------------------------------------------------------------------------

% TODO: rivedere le funzioni in modo da diminuire se possibile il numero di
% parametri in gioco

if TEST == 0 % EXP -----------------------------------
    def_fun = '1-exp((-x+x0)/lamb)';
    lamb_sp = inTime(NIMGS)/(max(contr)-min(contr)); % discrete derivative seems a good point to star
    x0_sp = 0;
    start_point = [lamb_sp x0_sp];
elseif TEST == 1 % TANH ------------------------------------WIP
    def_fun = 'tanh(x+x0)';
    x0_sp = mean(inTime);
    start_point = x0_sp;
end

fun = fittype(def_fun);
option = fitoptions('Method', 'NonlinearLeastSquares',...
                    'StartPoint', start_point);

% find function
interp_fn = fit(inTime, contr, fun, option); 

%--------------------------------------------------------------------------
% Nearest frame
%--------------------------------------------------------------------------

if TEST == 0 % EXP
    [asd im_vis] = min(abs(inTime-1/interp_fn.lamb-interp_fn.x0));
elseif TEST == 1 % TANH
    [asd im_vis] = min(abs(time-interp_fn.x0));
end



%--------------------------------------------------------------------------
% Plotting
%--------------------------------------------------------------------------
if ~showPlot
    return;
end

plot(interp_fn, 'b'); hold on;
plot(inTime, contr, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g'); title 'exponential fitting discrete function';
plot(inTime(im_vis), contr(im_vis),  'sr', 'LineWidth', 2);
xlabel 'time'; ylabel 'contrast'; hold off;
pause();

end