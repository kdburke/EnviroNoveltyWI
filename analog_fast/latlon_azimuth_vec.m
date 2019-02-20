function azimuth = latlon_azimuth_vec(lat1,lon1,lat2,lon2)
% function azimuth = latlon_azimuth_vec(lat1,lon1,lat2,lon2)
% calculate azimuth between two points on earth's surface
% given by their latitude-longitude pair.
% Input lat1,lon1,lat2,lon2 are in degrees, without 'NSWE' indicators.
%
% Lat1/Lon1 are the coordinates of the starting point
% Lat2/Lon2 are the coordinates of the destination point
%
% Method calculates sphereic geodesic bearing,
% but ignores flattening of the earth:
% ? =  	atan2(  	sin(?long).cos(lat2),
%cos(lat1).sin(lat2) ? sin(lat1).cos(lat2).cos(?long) )
%
% This is the great-circle azimuth, not the rhumb-line azimuth
%
% Formula obtained from http://www.movable-type.co.uk/scripts/latlong.html
%
% Note from web searches:  bearing and azimuth are nearly interchangeable,
% but azimuth is always measured relative to true (or magnetic north)
% whereas 'bearing' can use difference reference lines.  
%
% lat1, lon1, lat2, lon2 can be vectors
%
%Azimuth value returned will range from -180 to 180

if nargin < 4
    dist = -99999;
    disp('Number of input arguments error! distance = -99999');
    return;
end
if any(abs(lat1)>90) | any(abs(lat2)>90) | any(abs(lon1)>360) | any(abs(lon2)>360)
    dist = -99999;
    disp('Degree(s) illegal! distance = -99999');
    return;
end

if size(lat1)~=size(lat2) | size(lat1)~=size(lon1) | size(lat1)~=size(lon2)
    dist = -99999;
    disp('Input vectors not all same size')
    return
end%

deg2rad = pi/180;
lat1 = lat1 * deg2rad;
lon1 = lon1 * deg2rad;
lat2 = lat2 * deg2rad;
lon2 = lon2 * deg2rad;

azimuth = atan2( ( sin(lon2-lon1).*cos(lat2) ), ((cos(lat1).*sin(lat2))-(sin(lat1).*(cos(lat2).*cos(lon2-lon1))) ) );

azimuth = azimuth*(1/deg2rad);