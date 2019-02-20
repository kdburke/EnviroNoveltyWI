function dissim=canberra(mod,fosvec)

%function dissim=canberra(mod,fosvec)
%Canberra.m calculates the Canberra distance
%between a fossil sample (vector) and all samples in modern array
%calculation:  D= SUM ((abs(mod-fos))./(mod+fos))
%NOTE 1:  mod,fosvec contain no key fields - comparison variables only
%NOTE 2:  pollen data should be fractions, not percents
%
%NOTE 3:  instances where both pik=0 and pjk =0 are defined as 0

%check to make sure that mod and fos arrays have same number of columns
if size(mod,2)~=size(fosvec,2)
    error('Modern and fossil arrays have different number of columns')
end%if

%Check that fossil array is a row vector
if size(fosvec,1)~=1
    error('Error:  Canberra expects fossil data to be a row vector')
end%if

%Iterate through samples in modern array, calculating dissimilarities
[nrow,ncol]=size(mod);
dissim=zeros(nrow,1);
for i=1:nrow
    for j=1:ncol
        if (mod(i,j) + fosvec(j))==0
            dij=0;
        else
            dij=(abs(mod(i,j)-fosvec(j)))/(mod(i,j)+fosvec(j));
        end%if
        dissim(i)=dissim(i)+dij;
    end%for-j

end%for-i


