ss=88120259
testread


histdepth=110.

severity=4
numh=profiledata.numhists+1


profiledata.numhists=numh
profiledata.QC_code(numh,:)='FS';
histd=num2str(histdepth);
     profiledata.QC_depth(numh,1:8)='        ';
     profiledata.QC_depth(numh,1:length(histd))=histd;
        clo=datestr(clock,24);
     update=[clo(1:2) clo(4:5) clo(7:10)];
  
     profiledata.PRC_Date(numh,1:8)=update;
     profiledata.PRC_Code(numh,1:4)='CSCB';
     profiledata.Version(numh,1:4)=' 1.0';
     profiledata.Act_Parm(numh,1:4)='TEMP';
     profiledata.Previous_Val(numh,1:10)='999.99    ';
     profiledata.Ident_Code(numh,1:2)='CS';  
     profiledata.Flag_severity(numh)=severity;

     %need to sort the quality flags here: (so assigning quality works)
%guidata(gcbo,handles);   
clear hpd
for i=1:numh
    hpd(i)=str2num(profiledata.QC_depth(i,1:8));
end
     [holdold,indexsort]=sort(hpd);
%handles=guidata(gcbo);     
     profiledata.QC_depth(1:numh,:)=profiledata.QC_depth(indexsort,:);
     profiledata.QC_code(1:numh,:)=profiledata.QC_code(indexsort,:);
     profiledata.PRC_Date(1:numh,:)=profiledata.PRC_Date(indexsort,:);
     profiledata.PRC_Code(1:numh,:)=profiledata.PRC_Code(indexsort,:);
     profiledata.Version(1:numh,:)=profiledata.Version(indexsort,:);
     profiledata.Act_Parm(1:numh,:)=profiledata.Act_Parm(indexsort,:);
     profiledata.Previous_Val(1:numh,:)=profiledata.Previous_Val(indexsort,:);
     profiledata.Ident_Code(1:numh,:)=profiledata.Ident_Code(indexsort,:);  
     profiledata.Flag_severity(1:numh)=profiledata.Flag_severity(indexsort);
     

testwrite