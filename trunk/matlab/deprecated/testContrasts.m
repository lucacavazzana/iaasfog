function [] = testContrasts(imgPaths, feats)

%TESTCONTRAST
%
%   TestContrast(imgPaths, feats) this function was created to check if the
%   C++ one is doing it right

for ff = feats
    disp(' ');
    for ii = ff.num:-1:1
        coord.x=ff.x(ii);
        coord.y=ff.y(ii);
        coord.z=1;
        disp(['C++: ', num2str(ff.contr(ii)), ' - Matlab: ', num2str( 255*rmsContrast(coord,imgPaths(ff.start+ff.num-ii,:)))]);
    end
    pause;
end

end