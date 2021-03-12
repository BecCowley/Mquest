%  assign_quality_flags - this script takes the flags applied and their
%  severity and recalculates the quality flags for each depth/temperature level, 
%  then puts the new quality flags back into pd.qc and saves the
%  handles structure.
%
%       NOTE - this requires that the proper profiledata structure exists and 
%           you are in a gui environment with a handles structure.
%       It is NOT a function.
%
%  handles = guidata(gcbo);
%  profiledata=handles.profile_data;

global DATA_QC_SOURCE

%set quality to 0 so new qualities overwrite the original quality (bad
%qualities are coming in with some data sets)...
oldqc=pd.qc;
%kkold=find(oldqc=='5');
pd.qc(1:pd.ndep)=num2str(0);

if(pd.numhists>0)
    oldqual=0;
    jj=0;
    for i=1:pd.numhists
        %the depth of this QC flag:
        pdqcd=pd.QC_depth(i);
        
        if(strmatch('CS',pd.QC_code(i,:)))
            kk=find(pd.depth>=pdqcd-0.008);  % & pqd~='5');
            pd.qc(kk(1))='3';
        elseif((strmatch('SP',pd.QC_code(i,:)) | ...
                strmatch('IP',pd.QC_code(i,:))) & ...
                pd.Flag_severity(i)<3 & oldqual<3 )
            kk=find(pd.depth>=pdqcd-0.008);  % & pqd~='5');
            pd.qc(kk(1))='5';
        elseif(pd.Flag_severity(i)>oldqual & pd.Flag_severity(i)~=5)
            pqd=pd.qc';
            %find all depths greater than the QC flag depth and assign the
            %quality flag to those depths - but ONLY if the new quality is
            %greater than the old quality and NOT equal to "5" (i.e., the
            %data has been changed - these remain at 5, regardless of the
            %new flag's severity)...
            %        try
            %            kk=find(pd.depth>=pdqcd-0.001);   % & pqd~='5');
            %        catch
            %            pqd=pqd';
            kkl=find(pd.depth>=pdqcd-0.008);  % & pqd~='5');
            if(pd.Flag_severity(i)<3)
                kk=find(pqd(kkl)~='5');
            else
                kk=1:length(kkl);
            end
            %        end
            pd.qc(kkl(kk))=num2str(pd.Flag_severity(i));
            oldqual=pd.Flag_severity(i);
        end
    end
else
    %if there has been no QC done, the quality is "0"
    pd.qc(1:pd.ndep)=num2str(0);
end


handles.pd=pd;
%saveguidata
