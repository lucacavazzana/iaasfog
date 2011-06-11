%   $Revision: xxxxx $  $Date: 2011/06/11$

% generates latex code from saved .mat files

clear all;

load('lol.mat');

disp('fit:')
for st = 1:size(imStart,1)
    lol = imStart(st,:);
    for num = 1:size(n,2) % già formattato per latex, lol
                
        asd = [res(st,num,[res(st,num,:).fit]>0).fit];
        lol = [lol, ' & ' num2str(mean(asd),3),'s (',num2str(std(asd),2),'s)'];
        
    end
    disp([lol, '\\ \hline']);
end

disp(' ');
disp('ransac:')
for st = 1:size(imStart,1)
    lol = imStart(st,:);
    for num = 1:size(n,2)        
        
        asd = [res(st,num,[res(st,num,:).rans]>0).rans];
        lol = [lol, ' & ' num2str(mean(asd),3),'s (',num2str(std(asd),2),'s)'];
        
    end
    disp([lol, '\\ \hline']);
end

disp(' ');
disp('nFeats:')
for st = 1:size(imStart,1)
    lol = imStart(st,:);
    for num = 1:size(n,2)        
        
        asd = [res(st,num,:).nFeats];
        lol = [lol, ' & ' num2str(mean(asd),3),' (',num2str(std(asd),2),')'];
        
    end
    disp([lol, '\\ \hline']);
end

disp(' ');
disp('exec time:')
for st = 1:size(imStart,1)
    lol = imStart(st,:);
    for num = 1:size(n,2)        
        
        asd = [res(st,num,:).nFeats];
        lol = [lol, ' & ' num2str(mean([res(st,num,:).fTime]),3),'/',num2str(mean([res(st,num,:).rTime]),2)];
        
    end
    disp([lol, '\\ \hline']);
end