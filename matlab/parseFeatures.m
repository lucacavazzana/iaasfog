function [feats]  = parseFeatures(fileName, cleanFeats)

%%
% parse the output file of the feature finder
% INPUT:
%   'fileName'  :   valid name of the output file
%   'cleanFeats':   temporary parameter, if 1 removes redundant features
%                   (since the until the C++ function is fixed)
%
% OUTPUT:
%   'feats'     :   list of struct representing the features as
%                   f.start - first frame the feature appears
%                   f.num - # of frame the feature is tracked
%                   f.x - x coords of the features in each frame appears
%                   f.y - x coords of the features in each frame appears
%                   f.contr - contrast value of the feat for each frame

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $


REVERSE = 1;    %FIXME : rimuovere quando findFeatures sparerà fuori feats nell'ordine corretto (stefano suks)


if ~exist('fileName','var')
    error '    - ERROR: fileName needed'
% elseif ~exist('fileName','file') % FIXME: it doesn't work... why?
%     error(['    - ERROR: ', fileName, ' does not exist']);
end

if exist('cleanFeats','var') && cleanFeats~=0
    cleanFeats=1;
else
    cleanFeats=0;
end

f = fopen(fileName,'r');
coord_regex = '\d+(\.\d+)?';

tline = fgets(f);
% parses the output of the c++ program, each line representes a feature in
% the form:
% #ImageFeatFirstAppears #ImagesFeatIsTracked [xValue yValue contrastValue ]+
while (tline~=-1)
    if(exist('feats','var'))
        parsed = str2double(regexp(tline,coord_regex,'match'));
        new.start = parsed(1)+1;    % since starts counting from 0
        new.num = parsed(2);
        new.x = parsed(3:3:end); new.y = parsed(4:3:end); new.contr = parsed(5:3:end);
        feats = [feats, new]; %#ok
    else
        parsed = str2double(regexp(tline,coord_regex,'match'));
        feats.start = parsed(1); feats.num = parsed(2);
        feats.x = parsed(3:3:end); feats.y = parsed(4:3:end); feats.contr = parsed(5:3:end);
    end
    tline = fgets(f);
end

fclose(f);

%% TODO: remove this when the c function will be fixed---------------------
% clears too-close tracking set
if cleanFeats
    for ii=size(feats,2):-1:1
        for jj=ii-1:-1:1
            if (feats(ii).num==feats(jj).num && ...
                    all(round(feats(ii).x)==round(feats(jj).x)) && ...
                    all(round(feats(ii).y)==round(feats(jj).y)))
                feats(ii)=[]; % deleting feature
                break;
            end
        end
    end
end
%--------------------------------------------------------------------------

if REVERSE
    for ii = 1:max(size(feats))
        feats(ii).start = 1; %feats(ii).start-feats(ii).num+1;
        feats(ii).x = feats(ii).x(end:-1:1);
        feats(ii).y = feats(ii).y(end:-1:1);
        feats(ii).contr = feats(ii).contr(end:-1:1);
    end
end

% for ii = 1:max(size(feats))
%     disp(ii);
%     disp(feats(ii).start);
%     disp(feats(ii).num);
%     disp(feats(ii).x);
%     disp(feats(ii).y);
%     disp(feats(ii).contr);
%     pause;
% end

% colors = ['y','m','c','r','g','b','w','k'];
% figure; hold on;
% for ii = 1:max(size(feats))
% %     plot(feats(ii).start:feats(ii).start+feats(ii).num-1,feats(ii).contr)
%     plot(feats(ii).start:feats(ii).start+feats(ii).num-1, feats(ii).contr, colors(rem(ii,8)+1));
%     pause(.3);
% end

end