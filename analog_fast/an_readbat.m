function batchcell2=an_readbat(batchcode)
    
cd param
%[runcode reffile reffileclim reffilesd t2p_t2_file t2p_t3_file]=textread(['matbat' batchcode '.txt',
batchcell=textread(['matbat' batchcode '.txt'],'%s','whitespace',' ','headerlines',2);
cd ..

%textread returns a vector cell-string (length M*N+1.  Rearrange to a MxN array where M=nruns & N=filenames.
%Last value read in is N -- the number of variables (NOTE:  not M).  
nstr=str2num(char(batchcell(end)));
batchcell=batchcell(1:end-1);
ncell=length(batchcell);
nrow=ncell/nstr;

batchcell2=cell(nrow,nstr);
k=0;
for i=1:nrow
    for j=1:nstr
        k=k+1;
        batchcell2(i,j)=batchcell(k);
    end%for
end%for