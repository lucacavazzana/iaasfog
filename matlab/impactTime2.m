function [] = impactTime2(imPaths, feats, vp,  time, showPlot)

[NIMG NFEAT] = size(feats);

if (exist('showPlot','var') && (showPlot==1 || strcmp(showPlot,'true')))
    showPlot = 1;
else
    showPlot=0;
end

vp_st.x=vp(1); vp_st.y=vp(2); vp_st.z=vp(3);

fog_lev = zeros(NIMG,1);
for ii=1:NIMG
    if zoneHom(vp, imPaths(ii,:), 20, .895, .9, .3, 0) ~= -1
       fog_lev(ii) = MichelsonContrast(vp_st, imPaths(ii,:));
    end
end

if any(fog_lev>0)
    glob_fog = sum(fog_lev)/sum(fog_lev>0);
    disp(['Michelson contrast level over ', num2str(sum(fog_lev>0)),' vps: ', num2str(glob_fog)]);
else
    disp('Cannot find the contrast level of the vanishing point, inhomogeneous in each image');
    return;
end
clear fog_lev;


mCFeat = zeros(NIMG,NFEAT);
for ii=1:NIMG
    im = rgb2gray(imread(imPaths(ii,:)));
    for ff=1:NFEAT
        mCFeat(ii,ff) = MichelsonContrast(feats(ii,ff),im);
    end
end
clear im;

end
