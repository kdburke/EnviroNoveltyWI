function dissim=stndeuclid(mod,fosvec,modstdev)

%StndEuclid(mod,fosvec,modstdev) calculates the Standardized Euclidean Distance 
%between a fossil sample (vector) and all samples in a modern array
%StEu= sqrt ( SUM ( sqrt(mod)-sqrt(fos) )**2 )
%NOTE 1:  mod,fosvec contain no key fields - comparison variables only
%NOTE 2:  pollen data should be fractions, not percents
%INPUT: Mod -- MxN array of modern pollen abundances  M=samples  N=variables
%       Fos -- 1xN row-vector of fossil pollen abundances
%       stdev (optional) -- standard deviations to be applied to data.  Usually obtained from modern data, 
%                           assumed to apply to fossil data.  Three options:
%           MxN -- unique standard deviation for each modern record.  
%           Nx1,1xN -- vector of standard deviations for each variable (i.e. globally applied to samples)
%           empty -- default -- subroutine will calcuate standard deviation for each variable

%check to make sure that mod and fos arrays have same number of columns
if size(mod,2)~=size(fosvec,2) 
    error('Modern and fossil arrays have different number of columns')
end%if

%Handle standard deviation input
%1) is there no argument?  if so create empty matrix.
if nargin<3
    modstdev=[];
end%if
%2) is modstdev empty?  if so calc stdev for all variables
if isempty(modstdev)  
    modstdev=std(mod);
end%if
%3) is modstdev a column vector?  if so transform to row vector.
if (size(modstdev,2))==1
    modstdev=modstdev';
end%if 
%4) is modstdev a row vector?  If so duplicate into a MxN matrix
if min(size(modstdev,1))==1  
    nmod=size(mod,1);
    modstdev=repmat(modstdev,nmod,1);
end%if
%5) is modstdev MxN?  if not, return error and quit.
if size(modstdev) ~= size(mod)
    error(['Modern array and mod stdev are not same size.'])
end%if

%Delete variables (columns) with a standard deviation of 0 for all values -- with real data,
%this only happens if all values in modern dataset=0.

no0=modstdev~=0;  %a MxN binary array

%Trap cases where no0 is already a 1xN vector
if size(no0,1)>1
    no0col=any(no0);  % a 1xN binary vector, where 1 indicates at least one non-zero sd value in a column
else
    no0col=no0;
end%if

modcut=mod(:,no0col);
modstdevcut=modstdev(:,no0col);
fosveccut=fosvec(no0col);

%If any zeros remain in the standard deviations, print warning and replace
%with column averages
if ~all(all(modstdevcut))  %this will trigger if any zeros exist
    warning('zeros found in modstdev.  Resolved (not ideally) by replacing with regional avg stdev')
    for j=1:size(modstdevcut,2)
        avsd=mean(modstdevcut(:,j));
        k=modstdevcut(:,j)==0;
        modstdevcut(k,j)=avsd;
    end%for
end%if

%Duplicate fossil vector  --> same number as modern vectors
nmod=size(modcut,1);
fos=repmat(fosveccut,nmod,1);

%Calculate squared standardized Euclidean Distance
dissim=sum( (((modcut-fos)./modstdevcut).^2) ,2 );

%Calculate standardized Euclidean Distance
dissim=sqrt(dissim);



