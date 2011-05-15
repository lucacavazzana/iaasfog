function [] = printFrames(filename, first, last)

STEP = 1;

vid = mmreader(filename);

if nargin == 1
    for ii = 1:vid.NumberOfFrames
        imshow(rgb2gray(read(vid, ii)));
        title(['frame ',num2str(ii)]);
        pause();
    end
else
    p = 0;
    for ii = first:STEP:last
        frame = rgb2gray(read(vid, ii));
        imwrite(frame,['frame','0'*ones(1,4-size(num2str(p),2)), num2str(p),'.png'],'png');
        p = p+1;
    end
end

close all;
end