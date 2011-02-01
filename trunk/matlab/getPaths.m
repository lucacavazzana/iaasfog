function [paths] = getPaths(imFolder, imName, imNum)

% given the folder, the name of the first image and the number of the
% images to consider, returns a vector of paths containing the complete
% path of each image, after checking they are valid. Images name must be
% numbered sequentially, ending with a string of four digits

%   Copyright 2011 Stefano Cadario, Cavazzana Luca.
%   $Revision: xxxxx $  $Date: 2011/02/01 17:20:22 $

paths(1,:)=[imFolder,'/',imName];
first = regexp(paths(1,:),'[0-9]{4}(?=\.(jpg|png|tiff|bmp)$)');
last = regexp(paths(1,:),'[0-9]{4}(?=\.(jpg|png|tiff|bmp)$)','end');
start = str2double(paths(1,first:last));

for i = 1:imNum-1
    paths(i+1,:)=paths(1,:);
    paths(i+1,last-size(num2str(i+start),2)+1:last) = num2str(i+start);
    
    % Check
    if exist(paths(i+1,:),'file')~=2
        error(['    - Error: ', paths(i+1,:), ' does not exist. Better luck next time']);
%     else imshow(imread(paths(i+1,:))); title(paths(i+1,:)); disp([paths(i+1,:),': ok']); pause(.01);
    end
end