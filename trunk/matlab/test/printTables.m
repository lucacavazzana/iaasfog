%   $Revision: xxxxx $  $Date: 2011/06/08 $

load('newImgs2.mat');

disp('fit:')
disp('\hline');
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
disp('\hline');
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
disp('\hline');
for st = 1:size(imStart,1)
    lol = imStart(st,:);
    for num = 1:size(n,2)        
        
        asd = [res(st,num,:).nFeats];
        lol = [lol, ' & ' num2str(mean(asd),3),' (',num2str(std(asd),2),')'];
        
    end
    disp([lol, '\\ \hline']);
end