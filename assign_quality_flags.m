%  assign_quality_flags - this script takes the flags applied and their
%  severity and recalculates the quality flags for each depth/temperature level, 
%  then puts the new quality flags back into profiledata.qc and saves the
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
oldqc=profiledata.qc;
%kkold=find(oldqc=='5');
profiledata.qc(1:profiledata.ndep)=num2str(0);

if(profiledata.numhists>0)
    oldqual=0;
    jj=0;
    for i=1:profiledata.numhists
        %the depth of this QC flag:
        pdqcd=profiledata.QC_depth(i);
        
        if(strmatch('CS',profiledata.QC_code(i,:)))
            kk=find(profiledata.depth>=pdqcd-0.008);  % & pqd~='5');
            profiledata.qc(kk(1))='5';
        elseif((strmatch('SP',profiledata.QC_code(i,:)) | ...
                strmatch('IP',profiledata.QC_code(i,:))) & ...
                profiledata.Flag_severity(i)<3 & oldqual<3 )
            kk=find(profiledata.depth>=pdqcd-0.008);  % & pqd~='5');
            profiledata.qc(kk(1))='5';
        elseif(profiledata.Flag_severity(i)>oldqual & profiledata.Flag_severity(i)~=5)
            pqd=profiledata.qc';
            %find all depths greater than the QC flag depth and assign the
            %quality flag to those depths - but ONLY if the new quality is
            %greater than the old quality and NOT equal to "5" (i.e., the
            %data has been changed - these remain at 5, regardless of the
            %new flag's severity)...
            %        try
            %            kk=find(profiledata.depth>=pdqcd-0.001);   % & pqd~='5');
            %        catch
            %            pqd=pqd';
            kkl=find(profiledata.depth>=pdqcd-0.008);  % & pqd~='5');
            if(profiledata.Flag_severity(i)<3)
                kk=find(pqd(kkl)~='5');
            else
                kk=1:length(kkl);
            end
            %        end
            profiledata.qc(kkl(kk))=num2str(profiledata.Flag_severity(i));
            oldqual=profiledata.Flag_severity(i);
        end
    end
else
    %if there has been no QC done, the quality is "0"
    profiledata.qc(1:profiledata.ndep)=num2str(0);
end
%            profiledata.qc(kkold)='5';

% ensure CSA flags have a '5' quality and haven't been overwritten by
% another. Bec Cowley, August, 2012
kk = strmatch('CS',profiledata.QC_code);
if ~isempty(kk)
    dd = profiledata.QC_depth(kk);
    for i = 1:length(dd)
        jj = find(profiledata.depth >= dd(i)-0.008);
        %check that the flags are 5
        profiledata.qc(jj(1)) = '5';
    end
    
end


handles.profile_data=profiledata;
%saveguidata
