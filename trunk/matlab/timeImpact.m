function[t_imp] = timeImpact(x1, x2, vp, dt, showPlot, imPath)

%Determina il tempo all'impatto della feature considerata rispetto
%all'immagine in cui la feature ha coordinate pari a x1.
%
%INPUT
%	'x1':       struct containing the coords of the feature in the first
%               frame
%   'x2':       struct containing the coords of the feature in the second
%               frame
%   'vp':       coords struct of the vanishing point
%   'dt':       time between the two images
%   'showPlot': =1 to show plots, 0 else
%   'imPath':   path of the image, needed if plotting
%
%OUTPUT
%'t_imp':   tempo di impatto dell'oggetto considerato rispetto all'istante
%           in cui la feature si trova nel punto x1, l'unità di misura
%           corrisponde a quella con cui è stato inserito il parametro
%           'time'.

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

% Check for plot
if (showPlot && ~exist(imPath,'file'))
    disp('    - ERROR: show graphs flag enabled but no valid image path inserted. Disabling Graphs showing');
    showPlot = 0;
end

%__________________________________________________________________________
%Determinazione della retta e delle proiezioni dei punti x1 e x2 su di essa
%__________________________________________________________________________

% Normalize
x1.x = x1.x/x1.z; x1.y = x1.y/x1.z;
x2.x = x2.x/x2.z; x2.y = x2.y/x2.z;
vp = [[vp.x vp.y]/vp.z 1];

% mean
xm.x = mean([x1.x,x2.x]);
xm.y = mean([x1.y,x2.y]);
xm.z = 1;

% Line through xm and vp
line_f = cross([xm.x,xm.y,xm.z], vp);

% Line at inf
line_inf = [0 0 1]';

% Line orth to line_f
line_ort_linef = [line_f(2) -line_f(1) 0]';
% line_ort_linef point at inf
pinf_lineOrtLinef = cross(line_ort_linef, line_inf);
% line orth to line_f by per x1
line_ortLinef_x1 = cross([x1.x x1.y x1.z], pinf_lineOrtLinef);
% line orth to line_f by per x2
line_ortLinef_x2 = cross([x2.x x2.y x2.z], pinf_lineOrtLinef);

% Proiezione del punto x1 sulla retta line_f
y1_i = cross(line_f, line_ortLinef_x1);
y1_i = y1_i/y1_i(3);
% Proiezione del punto x2 sulla retta line_f
y2_i = cross(line_f, line_ortLinef_x2);
y2_i = y2_i/y2_i(3);


%---------------------------------------
% Time to impact
%---------------------------------------

% Distanza y1_i e y2_i
y1_y2 = norm(y1_i(1:2)-y2_i(1:2));
% Distanza tra y2 e van_p
y2_vp = norm(y2_i(1:2)-vp(1:2));

% Tempo di impatto
t_imp =y2_vp/y1_y2*dt;


%-------------------------------------------------
% Determinazione movimento apparente feature
%-------------------------------------------------

%Distanza tra y1 e van_p
% y1_vp = norm(y1_i(1:2)-van_p(1:2));
%
% %Caso in cui la feature si allontana dalla telecamera
% if y1_vp >= y2_vanp
%     t_imp = -time_imp;
% end
t_imp = abs(t_imp);

%-----------------
% [Plot]
%-----------------
if(showPlot)
    
    f1 = figure; set(f1, 'Position', get(0,'Screensize')*9/10);
    if exist('imPath','var')
        subplot(1,2,1);
        imshow(rgb2gray(imread(imPath))); title(['time to imp: ', num2str(t_imp), 's']);
        hold on;
        if(norm(y1_i-vp)>norm(y2_i-vp))
            line([y1_i(1),vp(1)],[y1_i(2),vp(2)],'Color','r');
        else
            line([y2_i(1),vp(1)],[y2_i(2),vp(2)],'Color','r');
        end
        line([xm.x,vp(1)],[xm.y,vp(2)],'Color','r'); % vp-xm
        plot(vp(1),vp(2),'sr'); text(vp(1)+1, vp(2)+1,'vp');
        plot(x1.x,x1.y,'go'); % x1
        plot(x2.x,x2.y,'go'); % x2
        plot(y1_i(1),y1_i(2),'ro'); % y1
        plot(y2_i(1),y2_i(2),'ro'); % y2
        line([x1.x,x2.x],[x1.y,x2.y],'Color','g'); % x1-x2
        
        subplot(1,2,2);
    end
    hold on; title('axis not in scale');
    if(norm(y1_i-vp)>norm(y2_i-vp))
        line([y1_i(1),vp(1)],[-y1_i(2),-vp(2)],'Color','r');
    else
        line([y2_i(1),vp(1)],[-y2_i(2),-vp(2)],'Color','r');
    end
    plot(x1.x,-x1.y,'go'); text(x1.x+.5, -x1.y,'x1');
    plot(x2.x,-x2.y,'go'); text(x2.x+.5, -x2.y,'x2');
    plot(xm.x,-xm.y,'m*'); text(xm.x+.5, -xm.y,'xm');
    plot(vp(1),-vp(2),'b*'); text(vp(1)+.5, -vp(2),'vp');
    plot(y1_i(1),-y1_i(2),'ro'); text(y1_i(1)+.5, -y1_i(2),'y1');
    plot(y2_i(1),-y2_i(2),'ro'); text(y2_i(1)+.5, -y2_i(2),'y2');
    
    pause();
    close(f1);
end

end