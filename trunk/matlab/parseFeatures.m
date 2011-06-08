function [feats]  = parseFeatures(fileName, cleanFeats)

%PARSEFEATURES
%
%   parseFeatures(FILENAME) parses the output file of the feature finder
%   INPUT:
%     'fileName'    :   valid name of the output file
%     'cleanFeats'  :   temporary parameter, if 1 removes redundant
%                       features (since the until the C++ function is fixed)
%
%   OUTPUT:
%     'feats'       :   list of struct representing the features as
%                       f.start - first frame the feature appears
%                       f.num - # of frame the feature is tracked
%                       f.x - x coords of the features in each frame appears
%                       f.y - x coords of the features in each frame appears
%                       f.contr - contrast value of the feat for each frame
%                       f.tti - computed time-to-impact
%                       f.pars - vector to store possible parameters

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/05/11 $


if ~exist('cleanFeats','var')  %FIXME: rimuovere cleanFeats quando sarà sistemato in findFeatures
    cleanFeats = 0;
end

if ~exist('fileName','var')
    error '    - ERROR: fileName needed'
% elseif ~exist('fileName','file') % FIXME: it doesn't work... why?
%     error(['    - ERROR: ', fileName, ' does not exist']);
end

f = fopen(fileName,'r');
coord_regex = '\d+(\.\d+)?';

% parses the output of the c++ program, each line representes a feature in
% the form:
% #ImageFeatFirstAppears #ImagesFeatIsTracked #TimeToImpact [xValue yValue contrastValue ]+
feats = [];
tline = fgets(f);
while (tline~=-1)
    parsed = str2double(regexp(tline,coord_regex,'match'));
    new.start = parsed(1)+1;    % starting image. +1 since starts counting from 0
    new.num = parsed(2);    % number of frame tracked
    new.x = parsed(3:4:end)+1; new.y = parsed(4:4:end)+1; new.contr = parsed(5:4:end); new.tti = parsed(6:4:end); % x, y, contr and time-to-impact. +1 since starts from 0
%     new.pars = 0;
    new.start = new.start-new.num+1;
    feats = [feats, new]; %#ok
    tline = fgets(f);
end

fclose(f);

%% TODO: remove this when the c function will be fixed---------------------
% clears too-close tracking set
if cleanFeats
    ii=1;
    while ii<=size(feats,2)
        for jj=size(feats,2):-1:ii+1
            if(feats(ii).start==feats(jj).start && ...
                    feats(ii).num==feats(jj).num && ...
                    all(abs(feats(ii).x-feats(jj).x)<1) && ...
                    all(abs(feats(ii).y-feats(jj).y)<1))
                feats(jj) = []; % deleting the element
            end
        end
        ii=ii+1;
    end
    disp(['- After cleaning: ', num2str(size(feats,2)), ' feats']);
end

end