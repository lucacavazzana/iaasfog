function [fig] = plotContrasts(feats)

%PLOTCOTRASTS
%
%   INPUT:
%     'feats'   :   vector of features as parsed by parseFeatures.m
%
%   OUTPUT
%     'fig'     :   figure handler

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/04/13 17:20:22 $

% 0 = using frames
% 1 = using time-to-impact
OVERTTI = 1;

colors = ['y','m','c','r','g','b','k'];


ii = [0,0];
fig = figure; hold on; grid on;
if OVERTTI == 1
    xlabel('time to impact');
else
    xlabel('frame number');
end
for ff = feats
    if OVERTTI == 1
        plot(ff.tti, ff.contr, getFace);
    else
        plot(ff.start:ff.start+ff.num-1, getFace);
    end
    pause(.2);
end


    function l = getFace()
        % dirty function to get graph color and face
        if ii(1)==7
            ii = [1,rem(ii(2)+1,3)];
        else
            ii(1)=ii(1)+1;
        end
        
        l = colors(ii(1));
        
        if ii(2)==1
            l=[l,'--'];
        elseif ii(2)==2
            l=[l,'-.'];
        end
    end

end