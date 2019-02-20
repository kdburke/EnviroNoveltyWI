function dissim_j=squarechord_j(mod,fosvec)

%squarechord_j (mod,fosvec) calculates the squared-chord distance 
%between all pollen taxa in a fossil sample (vector) and all samples 
%in modern array but does NOT perform final summation.
%Returns an n-length vector of dissimilarities (n=#taxa)
%calculation:  SCD=( sqrt(mod)-sqrt(fos) )**2
%
%
%NOTE 1:  mod,fosvec contain no key fields - comparison variables only
%NOTE 2:  pollen data should be fractions, not percents

%check to make sure that mod and fos arrays have same number of columns
    if size(mod,2)~=size(fosvec,2) 
        error('Error:  Modern and fossil arrays have different number of columns')
        end%if

%Check that fossil array is a vector
    if size(fosvec,1)~=1
        error('Error:  Squarechord expects fossil data to be a vector')
        end%if

%Duplicate fossil vector --> same number as modern vectors
    nmod=size(mod,1);
    fos=duprowvector(fosvec,nmod);

%Calculate square chord dissimilarity
    dissim_j=(sqrt(mod)-sqrt(fos)).^2;
