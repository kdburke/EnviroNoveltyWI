%Matpar525 sets parameters for analog runs, batch files 525

%%RUN COMMENTS HERE
%PRISM Climate, veg and ag novelty for WI, aggregated to county level. 
%8 climate variables. 10 ag/landuse variables, 15 veg variables. 33 variables total
% Local analysis

%December 2018

%homedir='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/';    %location of analog program on mac
homedir='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/';    %location of analog program on laptop

%**********************************************************************
%Reference 'climate' file information ('reference' dataset used for analogue
%searches)
%**********************************************************************
%refdir='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/input/';    %location of analog program on mac
refdir='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/input/';    %location of analog program on laptop
                                    %directory path (must have slash at
                                    %end!)
                                    
reffile='XXSEEBATCH.txt' 	%file name
REFKEY=[1 2]  			    %May be more than one.  Keyfield values, after sorting, must match ModClim. Must be a unique key for each sample
REFENTITY=[2];              %indicates subset of key fields  that identifies an entity (e.g. site/gridpoint).  Entities may have >1 sample.
REFCOORD=[3 4];			    %locations of spatial (x/y; lat/lon) coordinates
REFKEEPERS=[3 4]; 	%locations of fields for outputting, not used otherwise
REFVAR1=5; 				    %location of first climate variable	
REFCOORDMULT=1;             %Multiplier to convert units to km or deg

%**********************************************************************
%Target 'climate' file information  ('reference' dataset used for analogue
%searches)  This information is not used if REFREFFLAG=1
%**********************************************************************
%tardir='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/input/';    %location of analog program on mac
tardir='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/input/';    %location of analog program on laptop
                                    %directory path (must have slash at
                                    %end!)
                                    
tarfile='XXSEEBATCH.txt'             %file name
TARKEY=[1 2];                     %May be more than one.  Keyfield values do not have to match other files. 
TARENTITY=[2];                      %indicates subset of key fields that identifies an entity (e.g. site/gridpoint).  Entities may have >1 sample.
TARCOORD=[3 4];                     %locations of spatial (x/y; lat/lon) coordinates
TARKEEPERS=[3 4]; 	%locations of fields for outputting, not used otherwise
TARVAR1=5;                         %location of first climate variable	 
TARCOORDMULT=1;                     %Multiplier to convert units to km or deg

%**********************************************************************
%Reference 'climate' file information (used only if analogue-based
%paleoenvironmental inferences are being made, i.e. if ASSIGNMOGFLAG=1)
%**********************************************************************
%refdirclim='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/input/';    %location of analog program on mac
refdirclim='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/input/';    %location of analog program on laptop

                                    %directory path (must have slash at
                                    %end!)
reffileclim='XXSEEBATCH.txt'	%file name
REFCLIMKEY=[1];                     %locations of key fields
REFCLIM=(7:90);                     %locations of climate variables
NODATA=[-9999]';                    %climatic values indicating no data - to be discarded

%**********************************************************************
%Reference 'climate' standard deviations (only needed if Standardized Euclidean 
%dissimilarity metric is being used; if none specified, runanalog will calc)
%**********************************************************************
LOAD_SD=1;                       %Flag:  0=do not load file with SD values.  Instead calc internally.  1=Load.
%refdirsd='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/input/';    %location of analog program on mac
refdirsd='/Users/kevinburke/Documents/Dissertation/WisconsinNovelty/Workshop/analog_fast/input/';    %location of analog program on laptop

						        %directory path
reffilesd='XXSEEBATCH.txt'            %file name
REFSDKEY=[1 2];                   %locations of key fields.  May be more than one.  Keyfield values, after sorting, must match ModPoll. 
REFSD1=3;				        %locations of climate variables

%**********************************************************************
%Matrices and Arrays for Grouping Pollen Data into PFT's 
%**********************************************************************
%1) Biomization arrays (biomes required for PFT assigments)
%Taxa x Biome matrix 
txbdir='\junk\';		
txbfile='txb6651.txt'			

%Cutoff values 
cutdir='\junk\';		
cutfile='Cut20.txt'				

%2) Taxa -> PFT matrices
t2pdir='\JackArg\matlab\tax2pft\';  %Location of taxa2pft script
t2pmatdir=[t2pdir 'input\matrix\'];   %Location of taxa2pft matrices
t2p_t2_file='Mat6651b.txt'			%Tier 2 Taxa-PFT matrix
t2p_t3_file='Mat66xx3.txt'			%Tier 3 Taxa-PFT matrix

%**********************************************************************
%Run Options
%**********************************************************************
%Choice of dissimilarity measure: 	1=Squared Chord
%						            2=Standardized Euclidean
	DISSIMTYPE=2
	
%'No-Analog' threshold for dissimilarities
	NOANALOG=10000

%Should no-analog samples be regrouped into PFT's and rerun (multitier approach)?
%(1)=yes, (0)=no
	MULTITIER=0

%Multitier:  Should all target samples be rerun for 2nd&3rd tier, or only the no-analogs?
%(1)=run all; (0)=run only no-analogs
      RUNALL=0;

%Is this a reference-reference (1) or reference-target(0) run?  
	REFREFFLAG=0	

%Set minimum and maximum geographic distance threshold.  Use -9999 to indicate that no threshold should be set
%(use [-9999 -9999] to indicate that neither threshold should be used)
%NOTE:  Minimum distance threshold should only be used for Mod-Mod runs.
    COORDTHRESH=[-9999 -9999]	%km 

%Are reference 'climate' variables being assigned to best analogs?
%(0)=no  (1)=yes
	ASSIGNREFFLAG=1;
    
%COORDTYPE:  1=LatDD/LonDD 2=X/Y -- must be same for all input files
%if Lat/Lon, then Lat must come first in field order!
    COORDTYPE=1;

%Should the 'climate' variables be simply averaged or weighted by the
%dissimilarities?
%(0)=simple avg. (1)=wtd by 1/d (2)= wtd by 1/d^2
    DWT=0;

%Are analog variables percents (1) or not (0)?  (climate variables=not)
%If MULTITIER=1, PCTFLAG must equal 1 -- multitier code written for climate/PFTs
	PCTFLAG=0

%Is the output 'climate' variable scalar (1) or categorical (0)?
	SCALAR=1

%Is this an all-reference-data analog run (0), or local-analog only (1)?
%  For local-analog runs, dissimilarities calculated only for reference records with 
%  identical key-field values to target record
%(0)=all reference, (1)=within-site only
	LOCALANALOG=1

%How many matches should be retained?
%[any positive integer] = retain that many
%(if all values > threshold, keep single best match)
%-1:  variation on Waelbroeck et al (1998):
%	a)Identified as 'no-analog' if minimum dissimilarity>NOANALOG threshold
%	b)If analogs exist, sorts analogs by dissimilarity and looks for 'jumps' 
%	  in dissimilarities among adjacent samples.  Jumps defined to occur
%	  when dissimilarity increase is larger than a fraction ALFA of next closest
%	  sample.
%	c)Program stops looking for jumps when dissimilarities exceed original NOANALOG threshold
%	d)Keeps all reference analogs with dissimilarities<jump value
%     e)If no jumps found, program keeps 10 best matchesls(
    NANALOG=1
%Parameters for Waelbroeck method
    ALFA=0.2
