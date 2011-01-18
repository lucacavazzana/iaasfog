function[im_vis] = imageVisibleExpn(featCon, featCoord, time, vpCoord, vpCont)
%
%--------------------------------------------------------------------------
%Returns the number of the frame nearest to the instant the feature become
%visible, computed as the ---- of the exponential fitting the discrete
%function of the contrast
%
% INPUT
%   'constrast_m':  matrice nX3 in cui n � il numero di immagini in cui �
%   definito il contrasto della feature considerata; la prima colonna
%   deve contenere gli identificativi delle immagini (es. 1, 2,..) che 
%   devono essere disposte in ordine cronologico dalla prima all'ultima; la 
%   seconda colonna deve corrispondere al valore del contrasto, per la 
%   feature considerata, relativo all'immagine che si trova sulla stessa 
%   riga; la terza colonna deve contenere il tempo che separa l'immagine
%   che si trova sulla stessa riga a quella che la precede, per la prima
%   immagine questo campo deve quindi valere zero;
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

NIMG = size(featCon,1);

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


%__________________________________________________________________________
%Plot
%__________________________________________________________________________

fig_contrast_expn = figure;
plot(fun_discr(:,1), fun_discr(:,2), '*m');
hold on;

X = linspace(0, max(fun_discr(:,1)), 400);
Yexpn = expn_fit.h * exp(-X/expn_fit.lambda);
plot(X, Yexpn, 'b');

%Immagine in cui la feature diventa visibile
plot(fun_discr(i,1), fun_discr(i,2), 'kd');
