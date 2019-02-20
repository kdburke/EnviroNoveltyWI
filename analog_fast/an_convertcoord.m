function coordkm=analog_convertcoord(coordin,COORDUNITS)

%function coordkm=analog_convertcoord(coordin,COORDUNITS)
%Converts coordinates into albers X/Y (km units).  Could call lat2alb directly, but this routine
%used to handle variety of units for original coordinates.
%OBSOLETE -- DROPPED in V5

%HARDWIRING LAT/LON and X/Y field order.
    LAT=1; LON=2;
    X=1; Y=2;

%Check input formats
    if size(coordin,2)~=2
       error('input coordinates must have two columns (x,y)')
       end%if

%Set Albers parameters 
    earthrad=6370; %km
    s1=66.667; s2=33.333; 
    ln0=-100; lt0=70;

%Switch through COORDUNITS options
    switch COORDUNITS
        case 1	%LatDD/LonDD
            [x,y]=lat2alb(coordin(:,LAT),coordin(:,LON),earthrad,s1,s2,ln0,lt0);
            coordkm=[x y];

        case 2	%AlbX/Y (unitless)
            coordkm=coordin*earthrad;

        otherwise
            error('incorrect value for COORDUNITS')
       
    end%switch