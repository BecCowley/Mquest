%  assign_quality_flags - this one takes the flags applied and their
%  severity and recalculates the quality flags for each level, then puts it
%  back into profiledata.qc


%handles = guidata(gcbo);
%profiledata=handles.profile_data;


if(profiledata.numhists>0)
    oldqual=0
    jj=0
    for i=1:profiledata.numhists
        pdqcd=str2num(profiledata.QC_depth(i));
        if(profiledata.Flag_severity(i)>oldqual)
            kk=find(profiledata.depth>=pdqcd);
            profiledata.qc(1,kk)=num2str(profiledata.Flag_severity(i));
            oldqual=profiledata.Flag_severity(i);
        end
    end
end

%guidata(gcbo,'handles');