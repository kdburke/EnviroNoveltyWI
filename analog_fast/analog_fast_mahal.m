function [bdis_all,cdis_all,clim_diag]=analog_fast_mahal(refdat,tardat,stdevref,REFENTITY,REFKEY,...
    REFCOORD,REFVAR,REFSDKEY,REFSDVAR,TARENTITY,TARKEY,TARCOORD,TARVAR,...
    COORDTHRESH,COORDTYPE,LOCALANALOG,NOANALOG)

%analog_fast -- pared this WAY back -- tried to optimize for speed.  Only
%bdis and cdis is outputted  Now bdis includes tar & ref coords

%**********************************************************************
%Giant For-Loop
%For each target climate vector:
%	if this is a local-analog run, find the reference sample with matching key-fieldvalues
%	calculate dissimilarities between target vector and all reference data vectors
%	if this is a reference-reference run, drop best match
%	choose the reference samples with lowest dissimilarity values
%**********************************************************************
%DATA INPUTS:	refdat	- refkey, refcoord, refvar, refclim
%			    tardat	- tarkey, tarcoord, tarvar
%NOTE:  ANALOG ASSUMES THAT REFERENCE & TARGET FILE SETS ARE INTERNALLY CONSISTENT
%WITH RESPECT TO MATCHING ROWS.
%
%FIELD INPUTS:	REFKEY,REFCOORD,REFVAR,REFCLIM,TARKEY,TARCOORD,TARVAR
%FLAG INPUTS:	ASSIGNREFFLAG
%			DISSIMTYPE
%			REFREFFLAG
%			REMOVECOORD
%			COORDTHRESH
%           COORDTYPE
%			LOCALANALOG
%			NOANALOG
%			NANALOG
%			ALFA
%			SCALAR
%OUTPUTS:	bdis_all	tarkey fields, refkey fields, tarcoord, refcoord, dissim, geographic
%		                distance, azimuth  (only 1 analog/target record)
%		    cdis_all	tarkey fields, refkey fields, dissim, geographic
%		                distance, azimuth
%		    clim_diag   tarkey fields, refkey fields, tarcoord, refcoord,
%		                dissim, difference, stdevout, indiv 
%**********************************************************************

%**********************************************************************
%Prepare data
%**********************************************************************

%measure array dimensions
nrecref=size(refdat,1);		nrectar=size(tardat,1);
nentref=length(REFENTITY);  nenttar=size(TARENTITY);
nkeyref=length(REFKEY);		nkeytar=length(TARKEY);
ncoordref=length(REFCOORD);	ncoordtar=length(TARCOORD);
nvarref=length(REFVAR);		nvartar=length(TARVAR);

%**********************************************************************
%Run For-Loop
%**********************************************************************
%Initialize variables
bdis_all=zeros(nrectar,(nkeytar+nkeyref+ncoordtar+ncoordref+3));
clim_diag=zeros(nrectar,(nkeytar+nkeyref+ncoordtar+ncoordref+1+38)); %for mahal the last number = # variables

if LOCALANALOG==1
    cdis_all=[];
else
    %cdis_all=zeros(nrectar,(nkeytar+nkeyref+ncoordtar+ncoordref+3));
    %%Commented March 2018 to remove useless cdis file
end%if

%Start loop
for i=1:nrectar
    %Visual counter
    if rem(i,100)==1
        disp(['tarrec' num2str(i)])
        tic
    end%if

    %Local Analog Analyses (each sample matches to itself at other time
    %period)
    %Note:  This code assumes that refdat,refstd and tardat are exactly in same
    %sequence -- this should have been checked in an_checksortdata
    if LOCALANALOG==1
        refi=refdat(i,REFVAR);
        refsdi=stdevref(i,REFSDVAR);
        tari=tardat(i,TARVAR);

        dissim=sqrt (sum( (((refi-tari)./refsdi).^2) ,2 ) );
        bdis_all(i,:)=[tardat(i,TARKEY) refdat(i,REFKEY) tardat(i,TARCOORD) refdat(i,REFCOORD) dissim 0 0];
        %Standard dissim analyses in which each target sample is compared to
        %all reference samples.  (LOCALANALOG==0)
        %(attempts for speed by minimizing for-loops -- but
        %repmat is likely a huge slow-down)
    else
        taridup=repmat(tardat(i,:),nrecref,1);
        tarsdup=repmat(stdevref(i,:),nrecref,1); %tile and repeat sd as well 4/17
        
        %Mahalanobis time!
        
        reftardat = [refdat(:,REFVAR);tardat(:,TARVAR)]; %combine tar and ref data to calculate covariance matrix
        S = cov(reftardat);
        
        %dissim calculation is element wise for each focal cell in target
        %period (i = 1 ... size(target period data,1))
        tardatsub = tardat(i,TARVAR);
        dimrefdat = size(refdat);
        
        anomref = refdat(:,REFVAR) - repmat(tardatsub,dimrefdat(1),1); %center the data
        covmat = inv(S); %solve the matrix
        mahal_dist = sqrt(sum(anomref * covmat .* anomref,2)); %calculate distance
        %mahal_dist = sqrt(sum(anomref \ S .* anomref,2)); %calculate distance

        
        logvec=true(nrecref,1);
        
        %Extract the single best dissimilarity and record the row index for
        %refdat
        bdisi=min(mahal_dist(logvec));
        refindex=(1:nrecref)';
        bestI=refindex(mahal_dist==bdisi);
       
     
        %Calculate geographic distance and azimuth between target grid cell
        %and best analog
        reflat=refdat(bestI(1),REFCOORD(1));
        reflon=refdat(bestI(1),REFCOORD(2));
        tarlat=tardat(i,TARCOORD(1));
        tarlon=tardat(i,TARCOORD(2));

        if COORDTYPE==1 %Lat/LonDD
            %pos2dist -- got this from an online search.  Based on spherical law of
            %cosines.  Modified code to handle vector inputs.  Distance in km.
            Dbest=pos2dist_vec(tarlat,tarlon,reflat,reflon);
        elseif COORDTYPE==2 %X/Y
            Dbest=sqrt( (reflat-tarlat).^2 + ...
                (reflon-tarlon).^2 );
        else
            error('unexpected value for coordtype')
        end%if
        azibest = latlon_azimuth_vec(tarlat,tarlon,reflat,reflon);
        
        difference = (refdat(bestI(1),REFVAR)-taridup(bestI(1),TARVAR)) ;
        %stdevout = tarsdup(bestI(1),REFSDVAR) ; %changed stdevref to tarsdup
        %indiv = (difference./stdevout).^2 ; 

        %Assemble output for bdis_all (note that either full refdat or
        %pared-down refdati will be used, depending on whether geographic
        %constraint is placed
        bdis_all(i,:)=[tardat(i,TARKEY) refdat(bestI(1),REFKEY) tardat(i,TARCOORD) refdat(bestI(1),REFCOORD) bdisi Dbest azibest];
        clim_diag(i,:)=[tardat(i,TARKEY) refdat(bestI(1),REFKEY) tardat(i,TARCOORD) refdat(bestI(1),REFCOORD) bdisi difference] ;
        %Find cdis -- the geographically closest reference analog with a
        %dissimilarity that is acceptable (i.e.<threshold)
        %
        %a) find all analogs <threshold
        %WARNING:  as written, cdis_all code IGNORES user-set restrictions
        %on geographic distance
        logvec2=mahal_dist<=NOANALOG;
        ngood=sum(logvec2);

        if ngood~=0 %at least one good analog exists
            %b) extract coordinates from refdat and tardat (and create an
            %index that can link back to the original refdat records)
            reflat=refdat(logvec2,REFCOORD(1));
            reflon=refdat(logvec2,REFCOORD(2));
            refindex2=refindex(logvec2);
            Dindex=(1:ngood)';
            tarlat=repmat(tardat(i,TARCOORD(1)),[ngood,1]);
            tarlon=repmat(tardat(i,TARCOORD(2)),[ngood,1]);
            %c) calculate geographic distance
            if COORDTYPE==1 %Lat/LonDD
                D=pos2dist_vec(tarlat,tarlon,reflat,reflon);
            elseif COORDTYPE==2 %X/Y
                D=sqrt( (reflat-tarlat).^2 + ...
                    (reflon-tarlon).^2 );
            else
                error('unexpected value for coordtype')
            end%if
            %d) find smallest distance and refdat information for
            %geographically-closest good analog
            logvec3=(D==min(D));
            Igood=refindex2(logvec3);
            IgoodD=Dindex(logvec3);
            %e) calculate azimuth between target and geographically closest
            %good analog
            azi = latlon_azimuth_vec(tardat(i,TARCOORD(1)),tardat(i,TARCOORD(2)),refdat(Igood(1),REFCOORD(1)),refdat(Igood(1),REFCOORD(2)));
            %f) compile data into cdis_all  (note that Igood might have
            %more than one entry, if two acceptable analogs are at equal
            %distance from target gridcell.  So am arbitrarily picking
            %first match)
            cdis_all(i,:)=[tardat(i,TARKEY) refdat(Igood(1),REFKEY) tardat(i,TARCOORD) refdat(Igood(1),REFCOORD) mahal_dist(Igood(1)), D(IgoodD(1)), azi];
        else %No good analogs exist --> use the best analog identified from bdis
            cdis_all(i,:)=[tardat(i,TARKEY) refdat(bestI(1),REFKEY) tardat(i,TARCOORD) refdat(bestI(1),REFCOORD) bdisi Dbest azibest];
        end%if (ngood)

    end%if (LOCALANALOG)

    %time counter (every 100)
    if rem(i,100)==0
        toc
    end%if
end %for-i

%Remove unused (empty) rows from storage arrays
bdis_all=bdis_all(bdis_all(:,1)~=0,:);
clim_diag=clim_diag(clim_diag(:,1)~=0,:);