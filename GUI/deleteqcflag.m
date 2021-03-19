%delete the qc flag identified in deletionpoint...


%delete the QC flag chosen here:
%       kk=strmatch(DATA_QC_SOURCE,pd.Ident_Code);
%if the flag changed was PER or TER, restore the Q-Pos /Q_date_time flags
kk=kkhist;
if ~isempty(strfind('PE',pd.QC_code(kk(deletionpoint),:)))
    if pd.Flag_severity(kk(deletionpoint)) == 3
        pd.pos_qc = '1';
    end
end
if ~isempty(strfind('TE',pd.QC_code(kk(deletionpoint),:)))
    if pd.Flag_severity(kk(deletionpoint)) == 3
        pd.juld_qc = '1';
    end
end
pd.QC_code(kk(deletionpoint),:)=[];
pd.QC_depth(kk(deletionpoint))=[];
pd.PRC_Date(kk(deletionpoint),:)=[];
pd.PRC_Code(kk(deletionpoint),:)=[];
pd.Version(kk(deletionpoint),:)=[];
pd.Act_Parm(kk(deletionpoint),:)=[];
pd.Previous_Val(kk(deletionpoint),:)=[];
pd.Ident_Code(kk(deletionpoint),:)=[];
pd.Flag_severity(kk(deletionpoint))=[];
pd.numhists=pd.numhists-length(deletionpoint);

% now restore the 100th item:
deletionpoint=length(pd.QC_depth)+1:100;
for d=1:length(deletionpoint)
    pd.QC_code(deletionpoint(d),:)='  ';
    pd.PRC_Date(deletionpoint(d),:)='        ';
    pd.PRC_Code(deletionpoint(d),:)='    ';
    pd.Version(deletionpoint(d),:)='    ';
    pd.Act_Parm(deletionpoint(d),:)='    ';
    pd.Previous_Val(deletionpoint(d),:)='          ';
    pd.Ident_Code(deletionpoint(d),:)='  ';
    if deletionpoint(d) < 101
        pd.Flag_severity(deletionpoint(d))=pd.Flag_severity(deletionpoint(d)-1);
        pd.QC_depth(deletionpoint(d))=pd.QC_depth(deletionpoint(d)-1);
   else
       pd.Flag_severity(deletionpoint(d))=NaN;
       pd.QC_depth(deletionpoint(d))=0;
    end
end
pd.qc(1:length(pd.qc))='0';
handles.pd=pd;
handles.changed='y';
numh=pd.numhists;
%saveguidata
if(numh==0)
    assign_quality_flags;
    re_plotprofile;
else
    sortandsave
    re_plotprofile;
end

