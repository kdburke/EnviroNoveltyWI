function dist = pos2dist_vec(lat1,lon1,lat2,lon2)
% function dist = pos2dist(lat1,lon1,lat2,lon2)
% calculate distance between two points on earth's surface
% given by their latitude-longitude pair.
% Input lat1,lon1,lat2,lon2 are in degrees, without 'NSWE' indicators.
%
% Method calculates sphereic geodesic distance for points farther apart,
% but ignores flattening of the earth:
% d =
% R_aver * acos(cos(lat1)cos(lat2)cos(lon1-lon2)+sin(lat1)sin(lat2))
% Output dist is in km.
% Returns -99999 if input argument(s) is/are incorrect.
% Flora Sun, University of Toronto, Jun 12, 2004.
%
% Jack Williams:  Modified to allow lat1, lon1, lat2, lon2 to be vectors
% Original pos2dist included plane approximation, but I've taken this out.

if nargin < 4
    dist = -99999;
    disp('Number of input arguments error! distance = -99999');
    return;
end
if any(abs(lat1)>90) || any(abs(lat2)>90) || any(abs(lon1)>360) || any(abs(lon2)>360)
    dist = -99999;
    disp('Degree(s) illegal! distance = -99999');
    return;
end

if ( any(size(lat1)~=size(lat2)) || any(size(lat1)~=size(lon1)) || any(size(lat1)~=size(lon2)) )
    dist = -99999;
    disp('Input vectors not all same size')
    return
end%

%Change lon from -180 to 180 to 0 to 360
logvec = lon1<0;
lon1 = lon1+logvec*360;
logvec = lon2<0;
lon2 = lon2+360;

R_aver = 6371;
deg2rad = pi/180;
lat1 = lat1 * deg2rad;
lon1 = lon1 * deg2rad;
lat2 = lat2 * deg2rad;
lon2 = lon2 * deg2rad;

dist = R_aver * acos(cos(lat1).*cos(lat2).*cos(lon1-lon2) + sin(lat1).*sin(lat2));
