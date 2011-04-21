function [] = testContrasts(imgPaths, feats)

%% TESTCONTRAST
% TESTCONTRAST(imgPaths, feats) this function was created to check if the
% C++ one is doing it right

edit outFile.txt

for ff = feats
    disp(' ');
    for ii = 1:ff.num
        disp(imgPaths(ii+ff.start-1,:));
        coord.x=ff.x(ii);
        coord.y=ff.y(ii);
        coord.z=1;
        disp(['C++: ', num2str(ff.contr(ii)), ' - Matlab: ', num2str( 255*rmsContrast(coord,imgPaths(ii+ff.start-1,:)))] );
    end
    pause;
end

end