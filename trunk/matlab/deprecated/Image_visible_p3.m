function[im_vis] = Image_visible_p3(contrast_m)
%
%--------------------------------------------------------------------------
%[im_vis] = IMAGE_VISIBLE_P3(constrast_m)
%Determina l'immagine in cui la feature studiata diventa visibile, cio�
%l'immagine corrispondente all'istante di tempo in cui la feature comincia 
%ad essere considerata visibile.
%Considera la funzione discreta che descrive l'andamento del contrasto 
%della feature nel tempo e la approssima con un polinomio di terzo grado.
%
%
%INPUT
%'constrast_m': matrice nX3 in cui n � il numero di immagini in cui �
%   definito il contrasto della feature considerata; la prima colonna
%   deve contenere gli identificativi delle immagini (es. 1, 2,..) che 
%   devono essere disposte in ordine cronologico dalla prima all'ultima; la 
%   seconda colonna deve corrispondere al valore del contrasto, per la 
%   feature considerata, relativo all'immagine che si trova sulla stessa 
%   riga; la terza colonna deve contenere il tempo che separa l'immagine
%   che si trova sulla stessa riga a quella che la precede, per la prima
%   immagine questo campo deve quindi valere zero.
%
%OUTPUT
%'im_vis': identificativo dell'immagine in cui la feature diventa visibile.
%--------------------------------------------------------------------------


%__________________________________________________________________________
%Determinazione coordinate funzione discreta
%__________________________________________________________________________

size_m_contr = size(contrast_m);

%Ogni riga contiene le coordinate non omogenee dei punti che compongono la
%funzione discreta tempo-contrasto
t = 0;
for i = 1:size_m_contr(1)
    t = t + contrast_m(i,3);
    fun_discr(i,:) = [t contrast_m(i,2)];
end


%__________________________________________________________________________
%Determinazione funzione continua e flesso
%__________________________________________________________________________

%Polinomio di 3o grado che approssima i punti discreti
pol3 = polyfit(fun_discr(:,1), fun_discr(:,2), 3);
if pol3(1) == 0
    display('Cannot find a 3rd degree polynomial!');
    return
end
%Derivata seconda del polinomio di 3o grado
der2_pol3 = polyder(polyder(pol3));
%Determinazione flesso della funzione di 3o grado
t_visible = roots(der2_pol3);


%__________________________________________________________________________
%Determinazione immagine in cui feature diventa visibile
%__________________________________________________________________________

delta_t = abs(fun_discr(:,1) - t_visible);
min_delta_t = min(delta_t);

for i = 1:size_m_contr(1)
    if delta_t(i) == min_delta_t
        im_vis = contrast_m(i,1);
        break;
    end
end
    

%__________________________________________________________________________
%Plot
%__________________________________________________________________________

fig_contrast_function = figure;
plot(fun_discr(:,1), fun_discr(:,2), '*m');
hold on;

X = linspace(0, fun_discr(size_m_contr(1), 1), 400);
Ypol3 = pol3(1)*X.^3 + pol3(2)*X.^2 + pol3(3)*X + pol3(4);
plot(X, Ypol3, 'b');

Yder = der2_pol3(1)*X + der2_pol3(2);
plot(X, Yder, 'g');

%Immagine in cui la feature diventa visibile
plot(fun_discr(i,1), fun_discr(i,2), 'kd');
