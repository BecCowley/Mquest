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

%retain existing QC values 
oldqc = str2num(pd.qc);
%set quality to 0 so new qualities overwrite the original quality 
pd.qc(1:pd.ndep)=num2str(0);

if(pd.numhists>0)

% make an array of QC values for each flag applied
qcarr = zeros(length(pd.depth),pd.numhists);
    for i=1:pd.numhists        
        pdqcd=pd.QC_depth(i);
        idepth = find(pd.depth >= pdqcd-0.008);
        if(strmatch('CS',pd.QC_code(i,:)))
            qcarr(idepth(1),i)=3;
        elseif (~isempty(strmatch('SP',pd.QC_code(i,:))) | ...
                ~isempty(strmatch('IP',pd.QC_code(i,:)))) & ...
                pd.Flag_severity(i)<3  
            qcarr(idepth(1),i)=5;
            qcarr(idepth(2):end,i) = 2;
        elseif ~isempty(strmatch('HF',pd.QC_code(i,:))) 
            % HF is different, code is only on first point, but temp qc
            % needs to be 5 for interpolated parts. medianfilter.m writes
            % the QC codes for HF, therefore,
            % need to use the 'oldqc' to retain quality
            % for HF
            imatch = oldqc(idepth) == 5;
            qcarr(idepth(imatch),i)=5;
            imatch = oldqc(idepth) == 2;            
            qcarr(idepth(imatch),i) = 2;
            
        else
            qcarr(idepth(1):end,i)=pd.Flag_severity(i);
        end
    end
    % compare the arrays and don't overwrite bad flags (3, 4) with a changed
    % flag (5)
    allqcarr = qcarr;
    i5 = qcarr == 5;
    % change the 5 for 0 for now
    qcarr(i5) = 0;
    % find the worst data without the changed flags
    newqc=max(qcarr,[],2);
    % now put in the changed flags where quality is 1 or 2
    irep = newqc <= 2 & max(allqcarr,[],2) == 5;
    newqc(irep) = 5;
    % and if there are NaNs in the temperature (eg from PLA), replace QC with
    % zeros
    newqc(isnan(pd.temp)) = 0;
    pd.qc = num2str(newqc);
else
    %if there has been no QC done, the quality is "0"
    pd.qc(1:pd.ndep)=num2str(0);
end


handles.pd=pd;
%saveguidata
