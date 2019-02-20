function [moddatpft,fosdatpft,MODPFT,FOSPFT,MODCLIM]=an_pol2pft(moddat,fosdat,...
    t2p,MODKEY,MODCOORD,MODVAR,MODCLIM,FOSKEY,FOSCOORD,FOSVAR);

%analogX_tier converts pollen taxa to PFT's, then runs analogX.m

%0) Measure arrays
nkeymod=length(MODKEY);		nkeyfos=length(FOSKEY);
ncoordmod=length(MODCOORD);	ncoordfos=length(FOSCOORD);
nvarclim=length(MODCLIM);

%1) Check:  do any fossil pollen records exist?
if isempty(fosdat) %CREATE EMPTY OUTPUTS & BAIL OUT
    bestdissim_all=[]; gooddissim_all=[]; fosclim_all=[];
else %continue
    
    %2) Extract modern and fossil pollen variables
    modvar=moddat(:,MODVAR); 
    fosvar=fosdat(:,FOSVAR);
    
    %3) Convert modern and fossil pollen to PFTs 
    disp('  Converting fossil pollen to PFTs')
    fospft=tax2pftnb(t2p,fosvar);
    
    disp('  Converting modern pollen to PFTs')
    modpft=tax2pftnb(t2p,modvar);
    
    %5) Rerun Analog.m   
    disp('  Calculating dissimilarities')
    
    %Prepare data:  assemble key fields, coordinates, pft values, & climate data
    moddatpft=[moddat(:,MODKEY) moddat(:,MODCOORD) modpft moddat(:,MODCLIM)];
    fosdatpft=[fosdat(:,FOSKEY) fosdat(:,FOSCOORD) fospft];
    
    %Prepare data:  Field Identifiers
    %1)Count number of PFT's by finding min, max values and taking difference.  Ignore 0's.
    maxpft=max(max(t2p));
    t2pnot0=t2p(t2p>0);
    minpft=min(min(t2pnot0));
    npft=maxpft-minpft+1;
    
    MODPFT=( (nkeymod+ncoordmod+1):(nkeymod+ncoordmod+npft) );
    FOSPFT=( (nkeyfos+ncoordfos+1):(nkeyfos+ncoordfos+npft) );
    MODCLIM=( (nkeymod+ncoordmod+npft+1):(nkeymod+ncoordmod+npft+nvarclim) );
    
end%if isempty(fosdat)
