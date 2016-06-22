%delete the qc flag identified in deletionpoint...


       %delete the QC flag chosen here:
%       kk=strmatch(DATA_QC_SOURCE,pd.Ident_Code);
     kk=kkhist;
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
        pd.QC_depth(deletionpoint(d))=0;
        pd.PRC_Date(deletionpoint(d),:)='        ';
        pd.PRC_Code(deletionpoint(d),:)='    ';
        pd.Version(deletionpoint(d),:)='    ';
        pd.Act_Parm(deletionpoint(d),:)='    ';
        pd.Previous_Val(deletionpoint(d),:)='          ';
        pd.Ident_Code(deletionpoint(d),:)='  ';
        pd.Flag_severity(deletionpoint(d))=9;
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
       
