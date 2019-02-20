function [dissimout,logvec]=analog_removegeog(dissimin,modcoord,foscoord,COORDTHRESH,COORDTYPE)

%Analog_RemoveGeog removes analogs if they are too close or too far spatially to
%fossil sample.
%Removal of too-close samples intended to strengthen mod-mod tests, by removing analogs
%within pollen source area.
%Removal of too-far samples removes spurious long-distance matches.  Use with caution -- may not
%be appropriate for older fossil samples.
%
%INPUTS
%   dissimin    =   [fosvecdup2 moddati(:,MODKEY) dissim];
%   modcoord    =   x/y coordinates for modern dataset
%   foscoord    =   x/y coordinates for single fossil sample (repeated many times; must be same length as modcoord)
%   COORDTHRESH =   [MINTHRESH MAXTHRESH]
%                   -9999 indicates that no threshold should be set
%                   [-9999 -9999] indicates that neither threshold should be used
%   COORDTYPE   =   1 if Lat/Lon DD; 2 if X/Y 
%
%FIXED PARAMETERS
%   R           =   radius of earth (6370.997km)
%
%OUTPUTS
%    dissimout  =   the trimmed list of dissimilarities
%    logvec     =   logical vector indicating which samples were retained
%                   and which discarded.  Can be used with the original data array from
%                   which dissimout2 was extracted

MINTHRESH=COORDTHRESH(1);
MAXTHRESH=COORDTHRESH(2);
R=6370.997;

%Calculate distances (D)
if COORDTYPE==1 %Lat/LonDD
    D=pos2dist_vec(modcoord(:,1),modcoord(:,2),foscoord(:,1),foscoord(:,2));
    %Older formula (used for runs<155).  This function did not account for
    %curvature of earth
    %D=spheredist(modcoord,foscoord,R);
elseif COORDTYPE==2 %X/Y
    D=sqrt( (modcoord(:,1)-foscoord(:,1)).^2 + ...
        (modcoord(:,2)-foscoord(:,2)).^2 );
else
    error('unexpected value for coordtype')
end%if

if MINTHRESH~=-9999
    %Remove modern samples that are too close to fossil sample
    logvec1=D>COORDTHRESH(1);
else
    logvec1=logical(ones(size(D)));
end%if

if MAXTHRESH~=-9999
    %Remove modern samples that are too far to fossil sample
    logvec2=D<COORDTHRESH(2);
else
    logvec2=logical(ones(size(D)));
end%if

logvec=(logvec1 & logvec2);
dissimout=dissimin(logvec,:);