%delete the qc flag identified in deletionpoint...


       %delete the QC flag chosen here:
%       kk=strmatch(DATA_QC_SOURCE,profiledata.Ident_Code);
     kk=kkhist;
       profiledata.QC_code(kk(deletionpoint),:)=[];
       profiledata.QC_depth(kk(deletionpoint))=[];
       profiledata.PRC_Date(kk(deletionpoint),:)=[];
       profiledata.PRC_Code(kk(deletionpoint),:)=[];
       profiledata.Version(kk(deletionpoint),:)=[];
       profiledata.Act_Parm(kk(deletionpoint),:)=[];
       profiledata.Previous_Val(kk(deletionpoint),:)=[];
       profiledata.Ident_Code(kk(deletionpoint),:)=[];
       profiledata.Flag_severity(kk(deletionpoint))=[];
       profiledata.numhists=profiledata.numhists-length(deletionpoint);
       % now restore the 100th item:
       deletionpoint=length(profiledata.QC_depth)+1:100;
       for d=1:length(deletionpoint)
        profiledata.QC_code(deletionpoint(d),:)='  ';
        profiledata.QC_depth(deletionpoint(d))=0;
        profiledata.PRC_Date(deletionpoint(d),:)='        ';
        profiledata.PRC_Code(deletionpoint(d),:)='    ';
        profiledata.Version(deletionpoint(d),:)='    ';
        profiledata.Act_Parm(deletionpoint(d),:)='    ';
        profiledata.Previous_Val(deletionpoint(d),:)='          ';
        profiledata.Ident_Code(deletionpoint(d),:)='  ';
        profiledata.Flag_severity(deletionpoint(d))=9;
       end
        profiledata.qc(1:length(profiledata.qc))='0';
       handles.profile_data=profiledata;
       handles.changed='y';
       numh=profiledata.numhists;
       %saveguidata
       if(numh==0)
           assign_quality_flags;
           re_plotprofile;
       else
           sortandsave
           re_plotprofile;
       end
       
