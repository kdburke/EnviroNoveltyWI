function bestdissim=choosebestanalogs(dissim,NOANALOG,NANALOG,ALFA)

%ChooseBestAnalogs(dissim,NOANALOG,NANALOG,ALFA)
%finds the best modern analogs for each fossil pollen sample.
%Assumes that dissimilarity value is in last field

nfield=size(dissim,2); nrec=size(dissim,1);

switch NANALOG
    case -1  %Waelbrock jump method
        dissim=sortrows(dissim,nfield);
        if dissim(1,nfield)>NOANALOG
            %keep single best match
            bestdissim=dissim(1,:);
        else
            diss0=dissim(1,nfield);
            bestdissim=[];
            for i=1:nrec
                diss1=dissim(i,nfield);
                if diss1>diss0*(1+ALFA)	%break if 'jump' between dissimilarity values
                    break
                end%if
                if diss1>NOANALOG, break	%if no jumps, break when dissimilarity>threshold
                end%if
                bestdissim=[bestdissim; dissim(i,:)];
                diss0=diss1;
            end%for
        end%if
    otherwise  %Use NANALOG to determine number of analogs retained
        bestdissim=zeros(NANALOG,nfield);
        for i=1:NANALOG
            [junk,I]=min(dissim(:,end));
            bestdissim(i,:)=dissim(I,:);
            dissim(I,end)=10000;  %overwrite minimum value in dissim with an arbitrarily large number
        end%for
        [junk,I]=sort(bestdissim(:,end));
        bestdissim=bestdissim(I,:);
end%switch

%         if dissim(1,nfield)>NOANALOG
%             %keep single best match
%             bestdissim=dissim(1,:);
%         else
%             %extract modern samples with dissimilarity<NOANALOG threshold
%             dissim=dissim((dissim(:,nfield)<NOANALOG),:);
%             %Keep [NANALOG] best matches
%             if(size(dissim,1))<NANALOG
%                 bestdissim=dissim;
%             else
%                 bestdissim=dissim(1:NANALOG,:);
%             end%if
%         end%if

