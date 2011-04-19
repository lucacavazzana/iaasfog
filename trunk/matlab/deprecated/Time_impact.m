function [time_imp] = Time_impact(x1, x2, van_p, time_frame)
%
%--------------------------------------------------------------------------
%TIME_IMPACT(X1, X2, van_p, time_frame)
%Determina il tempo all'impatto della feature considerata rispetto
%all'immagine in cui la feature ha coordinate pari a x1.
%
%INPUT
%'x1': coordinate omogenee della feature nel primo frame;
%'x2': coordinate omogenee della feature nel secondo frame;
%'van_p': coordinate omogenee del punto di fuga della direzione di
%   traslazione;
%'time_frame': tempo trascorso tra i due frame.
%
%OUTPUT
%'time_imp': tempo di impatto dell'oggetto considerato rispetto all'istante 
%   in cui la feature si trova nel punto x1, l'unit� di misura corrisponde 
%   a quella con cui � stato inserito il parametro 't_frame'.
%--------------------------------------------------------------------------

%__________________________________________________________________________
%Determinazione della retta e delle proiezioni dei punti x1 e x2 su di essa
%__________________________________________________________________________

%Normalizzazione dei punti
x1 = x1/x1(3);
x2 = x2/x2(3);
van_p = van_p/van_p(3);

%Punto medio
x_xm = min(x1(1),x2(1)) + (abs(x1(1)-x2(1))/2);
y_xm = min(x1(2),x2(2)) + (abs(x1(2)-x2(2))/2); 
xm = [x_xm y_xm  1]';

%Retta passante per xm e van_p
line_f = cross(xm, van_p);

%Retta all'infinito
line_inf = [0 0 1]';

%Retta perpendicolare alla retta trovata prima (line_f)
line_ort_linef = [line_f(2) -line_f(1) 0]';
%Punto all'infinito della retta line_ort_linef
pinf_lineOrtLinef = cross(line_ort_linef, line_inf);
%Retta perpendicolare a line_f e passante per x1
line_ortLinef_x1 = cross(x1, pinf_lineOrtLinef);
%Retta perpendicolare a line_f e passante per x2
line_ortLinef_x2 = cross(x2, pinf_lineOrtLinef);

%Proiezione del punto x1 sulla retta line_f
y1_i = cross(line_f, line_ortLinef_x1);
y1_i = y1_i/y1_i(3);
%Proiezione del punto x2 sulla retta line_f
y2_i = cross(line_f, line_ortLinef_x2);
y2_i = y2_i/y2_i(3);


%__________________________________________________________________________
%Plot
%__________________________________________________________________________

fig_timeimp = figure;
plot(x1(1),x1(2),'g*'); text(x1(1)+0.01, x1(2)+0.01,'x1');
hold on;
plot(x2(1),x2(2),'g*'); text(x2(1)+0.01, x2(2)+0.01,'x2');
plot(xm(1),xm(2),'m*'); text(xm(1)+0.02, xm(2)+0.02,'xm');
plot(van_p(1),van_p(2),'b*'); text(van_p(1)+0.02, van_p(2)+0.02,'van_p');
plot(y1_i(1),y1_i(2),'m*'); text(y1_i(1)-0.01, y1_i(2)-0.01,'y1');
plot(y2_i(1),y2_i(2),'m*'); text(y2_i(1)-0.01, y2_i(2)-0.01,'y2');

min_x = min(min(y1_i(1), y2_i(1)), van_p(1));
max_x = max(max(y1_i(1), y2_i(1)), van_p(1));
X = linspace(min_x, max_x, 300);
Y = (-line_f(1)*X - line_f(3))/line_f(2);
plot(X,Y,'b');


%__________________________________________________________________________
%Determinazione del tempo all'impatto
%__________________________________________________________________________

%Distanza y1_i e y2_i
dist_y1_y2 = sqrt(abs(y1_i(1)-y2_i(1))^2 + abs(y1_i(2)-y2_i(2))^2);
%Distanza tra y2 e van_p
dist_y2_vanp = sqrt(abs(y2_i(1)-van_p(1))^2 + abs(y2_i(2)-van_p(2))^2);


%Tempo di impatto
time_imp = dist_y2_vanp/dist_y1_y2*time_frame;


%__________________________________________________________________________
%Determinazione movimento apparente feature
%__________________________________________________________________________

%Distanza tra y1 e van_p
dist_y1_vanp = sqrt(abs(y1_i(1)-van_p(1))^2 + abs(y1_i(2)-van_p(2))^2);

%Caso in cui la feature si allontana dalla telecamera
if dist_y1_vanp >= dist_y2_vanp
    time_imp = -time_imp;
end