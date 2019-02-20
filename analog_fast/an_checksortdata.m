function [refin,tarin,refinclim,refinsd,nkeyref,nkeytar,nkeyrefclim,ncoordref,ncoordtar,nkeepref,...
          nkeeptar,nvarref,nvartar,nvarclim]=...
     an_checksortdata(MULTITIER,ASSIGNREFFLAG,REFREFFLAG,COORDTHRESH,PCTFLAG,DISSIMTYPE,SCALAR,LOAD_SD,REFKEY,TARKEY,REFCLIMKEY,REFSDKEY,...
     REFCOORD,TARCOORD,REFKEEPERS,TARKEEPERS,REFVAR1,TARVAR1,REFCLIM,REFSD1,refin,tarin,refinclim,refinsd,t2p_t2,t2p_t3)
%Checks consistency of parameter file and input datafiles

%**********************************************************************
%Sort and measure input arrays
%**********************************************************************

%Count field numbers
nkeyref=length(REFKEY); nkeytar=length(TARKEY); nkeyrefclim=length(REFCLIMKEY);
ncoordref=length(REFCOORD); ncoordtar=length(TARCOORD);
nkeepref=length(REFKEEPERS); nkeeptar=length(TARKEEPERS);

%Reference Data:  sort data by key fields, count records and analog variables
refin=sortrows(refin,REFKEY);
nvarref=size(refin,2)-REFVAR1+1;
nrecref=size(refin,1);

%Target Data:  count records and analog variables
nvartar=size(tarin,2)-TARVAR1+1;		
nrectar=size(tarin,1);

%Reference Climate data (if included):  sort data by key fields, count #records
if ASSIGNREFFLAG==1
    REFCLIMKEY
    size(refinclim)
    refinclim=sortrows(refinclim,REFCLIMKEY);
    nvarclim=length(REFCLIM);	
    nrecrefclim=size(refinclim,1);
else
    refinclim=[];
    nvarclim=0;
    nrecrefclim=0;
end%if

%Standard deviation for variables at each reference locale (if included):  sort data by key fields, count #records
if LOAD_SD==1
    refinsd=sortrows(refinsd,REFSDKEY);
    nvarsd=size(refinsd,2)-REFSD1+1;	
    nrecsd=size(refinsd,1);
else
    refinsd=[];
    nvarsd=0;
    nrecsd=0;
end%if

%TxP lists
if MULTITIER==1
    ntax_t2pt2=size(t2p_t2,1);
    ntax_t2pt3=size(t2p_t3,1);
end%if

%**********************************************************************
%Data checks
%**********************************************************************
%Check for Flag & Option Incompatibilities
%1:  Warn user if he/she is using minimum Geographic Threshold option for a reference-target comparison
if (REFREFFLAG==0 & COORDTHRESH(1)~=-9999)
    disp('Warning:  This reference-target run is excluding spatially close analogs...')
    input('  (hit return)');
end%if

%2:  Check that COORDTHRESH is 1x2 array
if size(COORDTHRESH)~=[1 2], 
    COORDTHRESH
    error('COORDTHRESH SIZE IS NOT 1X2'), end%if

%3:  If MULTITIER=1, PCTFLAG must equal 1 -- multitier code written for pollen/PFTs
if MULTITIER==1 & PCTFLAG==0
    MULTITIER,PCTFLAG
    error('If MULTITIER=1, PCTFLAG must equal 1 -- multitier code written for pollen/PFTs')
end%if
%4:  If DISSIMTYPE=2 (SED), PCTFLAG must equal 0 -- standard deviations not converted to relative values)
if DISSIMTYPE==2 & PCTFLAG==1
    DISSIMTYPE,PCTFLAG
    error('IF DISSIMTYPE=2 (SED), PCTFLAG must equal 0 -- standard deviations not yet converted to relative values)')
end%if

%5:  IF SCALAR=0, remind user that all 'climate' variables will be rounded
%to 0.  
if SCALAR==0,
    disp('Warning:  Because the SCALAR flag has been set to ''categorical'',')
    disp('all climate variables will be rounded to integers')
end%if

%Check for Data Incompatibilities
%1:  Do the reference and target 'pollen' files have same number of pollen variables?
if nvarref~=nvartar
    nvarref,nvartar
    error('Reference and Target pollen files have different numbers of variables')
end%if

%2:  Do the pollen and taxa2pft arrays have the same number of pollen variables and biomes?
if MULTITIER==1
    if ntax_t2pt2~=ntax_t2pt3
        ntax_t2pt2,ntax_t2pt3
        error('Tier 2 & Tier3 and taxa2pft matrices have different numbers of variables')
    end%if
    
    if nvarref~=ntax_t2pt2
        nvarref,ntax_t2pt2
        error('Pollen and taxa2pft (Tier2) matrices have different number of variables')
    end%if
end%if

%3:  Do the (sorted) reference pollen and climate files have matching records?
if ASSIGNREFFLAG==1;
    if nrecref~=nrecrefclim
        nrecref,nrecrefclim
        error('Reference climate and pollen files have different number of records')
    end%if
    
    %~=command checks each element for mismatch. any(any) will return a value of one
    %if any mismatch occurs, regardless of nrow & ncol.
    %Thus, this is a stringent test that the rows of refin and refinclim match
    if any(any(refin(:,REFKEY)~=refinclim(:,REFCLIMKEY)))
        error('Reference climate and pollen files have different key-field values')
    end%if
end%if

%4:  Do the (sorted) reference data and sd files have matching records?
if LOAD_SD==1;
    if nrecref~=nrecsd
        nrecref,nrecsd
        error('Reference sd and data files have different number of records')
    end%if
    
    if nvarref~=nvarsd
        nvarref,nvarsd
        error('Reference sd and data files have different number of variables')
    end%if
    
    if any(any(refin(:,REFKEY)~=refinsd(:,REFSDKEY)))
        error('Reference sd and data files have different key-field values')
    end%if
end%if
