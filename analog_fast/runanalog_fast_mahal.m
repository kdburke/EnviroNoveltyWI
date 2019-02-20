%[outdat1,outdat2,outdat3,outdat4]=runanalog5(paramcode,batchcode)
%Analog.m
% Jack Williams 12/00
% Kevin D. Burke 8/16
%
%**********************************
%
%FUNCTION INPUTS:          paramcode -indicates parameter file to be used (string)
%                          batchcode -indicates batch file to be used (optional)
%
%REQUIRED DATA INPUTS:  	Parameter file (matparXX.m) -- user sets filenames and run options
%                           Reference climate datafile
%		                    Target climate datafile
%
%INPUT FORMAT REQUIREMENTS:  	1) Key fields must be in first columns (may have 1 to n key fields)
%                               2) Climate variables must be in last columns (may have 2 to n climate variables)
%					            3) Order of climate variables must be the same in the reference, target,
%						                and txp arrays.  AN EASY MISTAKE TO MAKE                               
%
%OUTPUT:
%       1) bdisXX.dat	Format:  tarkey fields, refkey fields, tarcoord, refcoord, dissim,
%                       geographic distance, azimuth
%
%       2) cdisXX.dat	-best-estimate reconstructions for target sites - conditional upon ASSIGNREFFLAG=1
%                       Format:  tarkey fields, 'tarkeepers' (eg lat/lon), bdissim, nbest, climvars mean/refe,
%                               climvars stdv/refecount, tier#
%
%       4) clim_diagXX.dat	-Diagnostic file with difference, stdevout, and individual variable contribution 
%                            Individual contribution of each variable = "indiv" = (difference/stdevout).^2                     
%                       Format:  tarkey fields, refkey fields, tarcoord,
%                       ref coord, dissim, difference, stdevout, indiv
%
%PROGRAM STRUCTURE
%   User Dialog
%   Open and run Parameter file
%   Open input files
%   Process input data
%   Calculate Dissimilarities and assign analogs -- 1st Pass (climate taxa)
%   Calculate Dissimilarities and assign analogs -- 2nd Pass (plant functional types)
%   Calculate Dissimilarities and assign analogs -- 3rd Pass (plant life forms)
%   Save output
%
%FIXES TO BE DONE
%-make it cleaner and leaner
%-homedir --> pwd
%-output files as dats & dins (or netcdfs?)
%-remove analog5 from within analog_tier, place back in main routine (better for maintenance)
%
%SUBROUTINE LIST & LOCATION

disp('WARNING:  Code changed on 8/26/05 to v7.  BESTMETHOD now read as NANALOG.  Beware param files <107')
disp('')

%disp('WARNING:  runanalogfast currently set to run REGIONALLY -- i.e. SOUTH AMERICA')
disp('WARNING:  runanalogfast currently set to run GLOBALLY -- i.e. SLOWLY')
dummy=input('hit return to continue')

%Alternate 1:  Run as function
%function [outdat1,outdat2,outdat3,outdat4]=runanalog(paramcode,batchcode)

%Alternate 2:  Run as script (ask for paramcode and batchcode)
clear
disp('Enter paramcode, using single quotes (e.g. ''150'') ');
paramcode=input('')
disp('Enter batchcode, using single quotes (e.g. ''150''  (optional)')
batchcode=input('')
if isempty(batchcode)
    nargin=1;
else
    nargin=2;
end%if

%**********************************************************************
%Startup
%**********************************************************************

%identify current (home) directory
homedir=pwd;	    %location of analog program


%**********************************************************************
%Open, run parameter M-file and/or batch file
%**********************************************************************
%The Parameter.m file is a pseudo M-file that sets default parameters for a
%single or set of analog runs.  If batch file is used, it overrides the
%parameters in the parameter file.

%CODING TO DO's
%-Make it possible to skip entries in batch file so that default values in
%param.m can be used.
%-Make more flexible the extraction of variables from 'bc'.

%call parameter M-file
disp('Opening parameter and/or batch file')
if ~isstr(paramcode),error('paramcode must be a string'),end%if
cd param %Changed by KDB 6/17
%cd '/Users/kevinburke/Documents/Dissertation/NoAnalog/analog_fast/analog_fast';
eval(['matpar' paramcode ';'])
cd ..

%start stopwatch
tic

%Call batch file, if any, and return cell-array with list of strings.
%an_readbat reads input batchfile, returns cell-array with list of strings:  parid, runcode (for output),
%reffile,reffileclim,reffilesd,t2p_t2file,t2p_t2_file
if nargin<2
    nbatch=1;
    runcode=paramcode;
    bc={};
else
    bc=an_readbat(batchcode)
    nbatch=size(bc,1);
end%if

%Run RunAnalog either once (if no batch file used) or as many lines as in cell-array
for q=1:nbatch
    %Get file names and parameters from batchcell
    if ~isempty(bc)
        runcode=char(bc(q,1));
        reffile=char(bc(q,2));
        tarfile=char(bc(q,3));
        reffileclim=char(bc(q,4));
        reffilesd=char(bc(q,5));
        t2p_t2_file=char(bc(q,6));
        t2p_t3_file=char(bc(q,7));
        NOANALOG=str2num(char(bc(q,8)))
        NANALOG=str2num(char(bc(q,9)))
        DWT=str2num(char(bc(q,10)))
        disp(['Batch line ' num2str(q) '; Runcode=' runcode]);
    end%if
    %**********************************************************************
    %Open Input Data
    %**********************************************************************
    disp('Opening input datafiles')

    %Count field numbers
    nkeyref=length(REFKEY); nkeytar=length(TARKEY); nkeyrefclim=length(REFCLIMKEY); nkeysd=length(REFSDKEY);
    ncoordref=length(REFCOORD); ncoordtar=length(TARCOORD);
    nkeepref=length(REFKEEPERS); nkeeptar=length(TARKEEPERS);

    %Open reference 'climate' datafile
    refin=load([refdir reffile]);
    nvarref=size(refin,2)-REFVAR1+1;
    nrecref=size(refin,1);

    %Open target 'climate' datafile
    tarin=load([tardir tarfile]);
    nvartar=size(tarin,2)-TARVAR1+1;
    nrectar=size(tarin,1);

    %Open datafile of reference standard deviations - optional; only needed if SED's calculated
    if LOAD_SD==1
        refinsd=load([refdirsd reffilesd]);
        nvarsd=size(refinsd,2)-REFSD1+1;
        nrecsd=size(refinsd,1);
    else
        refinsd=[];
        nvarsd=0;
        nrecsd=0;
    end%if

    %**********************************************************************
    %Check input data for consistency
    %This will fail if input datasets have different numbers of rows and/or
    %are in different sort orders.
    %**********************************************************************
    disp('Checking input consistency')
    %Check for Data Incompatibilities
    %1:  Do the reference and target 'climate' files have same number of variables?
    if nvarref~=nvartar
        nvarref,nvartar
        error('Reference and Target climate files have different numbers of variables')
    end%if

    %2:  Do the reference data and sd files have matching records?
    if LOAD_SD==1;
%         if nrecref~=nrecsd
%             nrecref,nrecsd
%             error('Reference sd and data files have different number of records')
%         end%if   commented 4/17

        if nvarref~=nvarsd
            nvarref,nvarsd
            error('Reference sd and data files have different number of variables')
        end%if

%         if any(any(refin(:,REFKEY)~=refinsd(:,REFSDKEY)))
%             error('Reference sd and data files have different key-field values')
%         end%if     commented 4/17
    end%if

    %3:  (Only for local-analog checks):  Do the reference and target files
    %have matchign records?
    %2:  Do the reference data and sd files have matching records?
    if LOCALANALOG==1;
        if nrecref~=nrectar
            nrecref,nrectar
            error('Reference and target data files have different number of records -- not allowed for localanalog')
        end%if

        if any(any(refin(:,REFKEY)~=refinsd(:,REFSDKEY)))
            error('Reference and target data files have different key-field values')
        end%if
    end%if

    %**********************************************************************
    %Data Preparation
    %**********************************************************************
    %Produces 	Reference file (refdat) containing 1) key fields 2) coordinates 3) climate vars 4) climate vars
    %		    Target file (tardat) containing 1) key fields 2) coordinates 3) climate vars
    %		    Reference file (refvar) climate vars only
    %		    Target file (tarvar) climate vars only

    disp('Preparing datafiles')

    %Compile matrices for program use:  Key fields, coordinates, climate variables, and (maybe) climate
    refdat=[refin(:,REFKEY) refin(:,REFCOORD) refin(:,(REFVAR1:end))];
    tardat=[tarin(:,TARKEY) tarin(:,TARCOORD) tarin(:,(TARVAR1:end))];

    %Extract keyfield standard deviations from refinsd (if being used)
    if LOAD_SD==1
        refstdev=refinsd(:,[REFSDKEY REFSD1:end]);
    else
        refstdev=[];
    end%if

    %Calculate locations of fields for refdat, tardat
    DREFKEY=(1:nkeyref);
    DREFENTITY=DREFKEY(REFENTITY);
    DREFCOORD=(nkeyref+1:nkeyref+ncoordref);
    DREFVAR=( (nkeyref+ncoordref+1):(nkeyref+ncoordref+nvarref) );
    DREFSDKEY=(1:nkeysd);
    DREFSDVAR=(nkeysd+1:nkeysd+nvarsd);
    DTARKEY=(1:nkeytar);
    DTARENTITY=DTARKEY(TARENTITY);
    DTARCOORD=(nkeytar+1:nkeytar+ncoordtar);
    DTARVAR=( (nkeytar+ncoordtar+1) : (nkeytar+ncoordtar+nvartar) );

    %Implemented for runs 150-152:  sampling 'reference' dataset to reduce size
    %from 600,000 to 6000
    %Advantages:  Speeds up run time by 100x.  Disadvantage:  Sampling of
    %climate raises risk of not finding best analog.  This could be a real
    %problem when trying to find the direction of the best analog.
    %     %%NEW ADDITION -- SAMPLE THE REFERENCE DATASET TO REDUCE THE EFFECTIVE
    %     %%SIZE.  AM USING A FIXED STRATIFIED SAMPLING PROCEDURE IN WHICH ONLY
    %     %%1 OUT OF 100 REFERENCE SAMPLES ARE USED.  DONE BECAUSE THE RUNTIME, EVEN
    %     %%WITH ALL ATTEMPTED SPEED INCREASES, IS WAY TOO SLOW -- GIVEN 600,000
    %     %%RECORDS IN 10-MIN GLOBAL DATA, IT WILL TAKE 300 HOURS TO DO THE FULL
    %     %%NOVEL/DISAPPEARING COMPARISONS.
    %     %%BOTH REFDAT AND REFSD ARE SUBSAMPLED
    %     %%DONE ONLY IF LOCALANALOG=0
    %     if LOCALANALOG==0
    %         %Build a vector of 1's and 0's that will be used to sample from
    %         %refdat, refstdev
    %         %99 zeros and 1 one -- the one is placed in the middle
    %         samplevec=zeros(nrecref,1);
    %         vec100=[zeros(49,1); 1 ; zeros(50,1)];
    %
    %         %repeat this vector to match the number of records in refdat
    %         nrep=floor(nrecref/100);
    %         samplevec(1:(nrep*100))=repmat(vec100,nrep,1);
    %
    %         %If there are any leftover records, throw in one more sampled data
    %         %point.
    %         extra=rem(nrecref,100);
    %         if extra==0
    %             %do nothing
    %         elseif extra>=50
    %             veclast=[zeros(49,1); 1; zeros((extra-50),1)];
    %             samplevec((nrep*100+1):end)=veclast;
    %         else
    %             veclast=[zeros((extra-1),1); 1];
    %             remstart=nrep*100+1;
    %             samplevec((nrep*100+1):end)=veclast;
    %         end%if
    %
    %         %Subsample the refdat and refstdev matrices
    %         samplevec=logical(samplevec);
    %         refdat=refdat(samplevec,:);
    %         refstdev=refstdev(samplevec,:);
    %     end%if


    %**********************************************************************
    %Run Analog.m
    %For each target climate vector:
    %	if this is a local-analog run, find the reference sample with matching key-fieldvalues
    %	calculate dissimilarities between target vector and all reference data vectors
    %	if this is a reference-reference run, drop best match
    %	choose the reference samples with lowest dissimilarity values
    %
    %DATA INPUTS:	refdat	- refkey, refcoord, refvar, refclim
    %			    tardat	- tarkey, tarcoord, tarvar
    %
    %FIELD INPUTS:  REFKEY,REFCOORD,REFVAR,REFCLIM,TARKEY,TARCOORD,TARVAR
    %FLAG INPUTS:	LOCALANALOG
    %			    DISSIMTYPE
    %			    REFREFFLAG
    %			    COORDTHRESH
    %			    LOCALANALOG
    %			    NOANALOG
    %			    NANALOG
    %			    ALFA
    %			    SCALAR
    %OUTPUTS:	    bdis_all	tarkey fields, refkey fields, tarcoord, refcoord, dissim, geog distance, azimuth  (only 1 analog/target record)
    %		        cdis_all	tarkey fields, refkey fields, dissim, geog distance, azimuth  (only 1 analog/target record)
    %               clim_diag   tarkey fields, refkey fields, tarcoord, refcoord, dissim, difference, stdevout, indiv
    %**********************************************************************
    disp('Calculating dissimilarities')

    %run analog
    [bdis_all,cdis_all,clim_diag]=analog_fast_mahal(refdat,tardat,refstdev,DREFENTITY,DREFKEY,...
        DREFCOORD,DREFVAR,DREFSDKEY,DREFSDVAR,DTARENTITY,DTARKEY,DTARCOORD,DTARVAR,...
        COORDTHRESH,COORDTYPE,LOCALANALOG,NOANALOG);
 
    %**********************************************************************
    %Save Output
    %**********************************************************************
    disp ('Saving Output')

    %bdis_all->bdis.dat	(only 1 analog/target record)
    %   Format:  tarkey fields, refkey fields, tarcoord, refcoord, dissim,
    %   geographic distance azimuth
    %cdis_all->cdis.dat	(only 1 analog/target record)
    %   Format:  tarkey fields, refkey fields, tarcoord, refcoord, dissim,
    %   geographic distance azimuth
    %clim_diag->clim_diag.dat
    %   Format: tarkey fields, refkey fields, tarcoord, refcoord, dissim, difference, stdevout, indiv
    cd './output'
    disp ('  bdis')
    dlmwrite(['bdis' runcode '.txt'],bdis_all,'delimiter',' ','precision','%.3f')
    disp ('  cdis')
    dlmwrite(['cdis' runcode '.txt'],cdis_all,'delimiter',' ','precision','%.3f')
    disp ('  clim_diag')
    dlmwrite(['clim_diag' runcode '.txt'],clim_diag,'delimiter',' ','precision','%.3f')
    cd ..

end%MASSIVE-FOR
%Report length of time needed to run program
toc;

disp('WARNING:  Code changed on 8/26/05 to v7.  BESTMETHOD now read as NANALOG.  Beware param files <107')
