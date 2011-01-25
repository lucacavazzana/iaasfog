function[im_vis] = imageVisibleExpn(contr, time, showPlot)

% WIP
%[im_vis] = IMAGEVISIBLEEXPN(contr, time, showPlot)
% Given the discrete contrast function returns the number of the image
% where the feature becomes visible, choosen as ...
%
% INPUT
%   'contr':    vector containing the value of the feature in the Ith
%               image
%   'time:      vector array containing the time from image I-1 to I.
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


%__________________________________________________________________________
%Determinazione tempo all'impatto rispetto all'ultima immagine in cui
%compare l'immagine
%__________________________________________________________________________

NIMG = size(contr,1);

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

%--------------------------------------------------------------------------
% Define function parameters
%--------------------------------------------------------------------------

% EXP
% def_fun = 'h * exp(-x/lamb)'; % exp
% h_sp = max(contr);
% lamb_sp = NIMG/2;

% TANH
def_fun = 'tanh(x+x0)'; % tanh
x0_sp = mean(inTime);

fun = fittype(def_fun);
option = fitoptions('Method', 'NonlinearLeastSquares',...
                    ...'StartPoint', [h_sp, lamb_sp]); % exp
                    'StartPoint', x0_sp); % tanh

% find function
interp_fn = fit(inTime, contr, fun, option);

%--------------------------------------------------------------------------
% Nearest frame
%--------------------------------------------------------------------------

% [asd im_vis] = min(abs(inTime-1/interp_fn.lamb)); % exp
[asd im_vis] = min(abs(time-interp_fn.x0)); % tanh



if ~showPlot
    return;
end
%--------------------------------------------------------------------------
% Plotting
%--------------------------------------------------------------------------

plot(interp_fn, 'b'); hold on;
plot(inTime, contr, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g'); title 'exponential fitting discrete function';
plot(inTime(im_vis), contr(im_vis),  'sr', 'LineWidth', 2);
xlabel 'time'; ylabel 'contrast'; hold off;
pause();

return;








% here be n00bs
t_impXn = Time_impact(featCoord(NIMG-1), featCoord(NIMG), vp, time(NIMG)) - featCon(NIMG);


%__________________________________________________________________________
%Determinazione coordinate funzione discreta
%__________________________________________________________________________

dist = t_impXn;
for i = 1:size_m_contr(1)
    if i == 1
        dist = dist;
    else
        dist = dist + contrast_m(size_m_contr(1)-i+2,3);
    end
    fun_discr(size_m_contr(1)-i+1,:) = [dist (contrast_m(size_m_contr(1)-i+1,2)-contr_fog)];
end
    

%__________________________________________________________________________
%Determinazione funzione continua e parametro lambda
%__________________________________________________________________________

%Tipo di funzione esponenziale negativa
fun_expn = fittype('h * exp(-x/lambda)');
option = fitoptions('Method', 'NonlinearLeastSquares');
h_sp = max(fun_discr(:,2));
lambda_sp = min(fun_discr(:,1)) + (max(fun_discr(:,1)) - min(fun_discr(:,1)))/2;
option.StartPoint = [h_sp lambda_sp];
%Funzione esponenziale negativa che meglio approssima i dati dicreti
expn_fit = fit(fun_discr(:,1), fun_discr(:,2), fun_expn, option);


%__________________________________________________________________________
%Determinazione immagine in cui feature diventa visibile
%__________________________________________________________________________
delta_dist = abs(fun_discr(:,1) - expn_fit.lambda);
min_distlambda = min(delta_dist);

for i = 1:size_m_contr(1)
    if delta_dist(i) == min_distlambda
        im_vis = contrast_m(i,1);
        break;
    end
end

end