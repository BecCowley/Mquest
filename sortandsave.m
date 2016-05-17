%need to sort the quality flags here: (so assigning quality works)
%guidata(gcbo,handles); 

%retrieveguidata;

profiledata=handles.profile_data;
numh=profiledata.numhists;
clear h
for i=1:numh
    h(i)=profiledata.QC_depth(i);
end
clear indexsort holdold
if exist('h','var')
     [holdold,indexsort]=sort(h);
%handles=guidata(gcbo);     
     profiledata.QC_depth(1:numh)=profiledata.QC_depth(indexsort);
     profiledata.QC_code(1:numh,:)=profiledata.QC_code(indexsort,:);
     profiledata.PRC_Date(1:numh,:)=profiledata.PRC_Date(indexsort,:);
     profiledata.PRC_Code(1:numh,:)=profiledata.PRC_Code(indexsort,:);
     profiledata.Version(1:numh,:)=profiledata.Version(indexsort,:);
     profiledata.Act_Parm(1:numh,:)=profiledata.Act_Parm(indexsort,:);
     profiledata.Previous_Val(1:numh,:)=profiledata.Previous_Val(indexsort,:);
     profiledata.Ident_Code(1:numh,:)=profiledata.Ident_Code(indexsort,:);  
     profiledata.Flag_severity(1:numh)=profiledata.Flag_severity(indexsort);
     
end
%add any extra handling in here...


%finish and return

     handles.changed='Y';
     handles.profile_data=profiledata;

%     saveguidata
     
%this is a test - try to save the profile here but remove it and only save
%when necesary!!!!
    
assign_quality_flags ;  %go and assign the correct quality flags to each depth level...

%re_plotprofile;

%writenetcdf
   
 
        
