%need to sort the quality flags here: (so assigning quality works)
%guidata(gcbo,handles); 

%retrieveguidata;

pd=handles.pd;
numh=pd.numhists;
clear h
for i=1:numh
    h(i)=pd.QC_depth(i);
end
clear indexsort holdold
if exist('h','var')
     [holdold,indexsort]=sort(h);
%handles=guidata(gcbo);     
     pd.QC_depth(1:numh)=pd.QC_depth(indexsort);
     pd.QC_code(1:numh,:)=pd.QC_code(indexsort,:);
     pd.PRC_Date(1:numh,:)=pd.PRC_Date(indexsort,:);
     pd.PRC_Code(1:numh,:)=pd.PRC_Code(indexsort,:);
     pd.Version(1:numh,:)=pd.Version(indexsort,:);
     pd.Act_Parm(1:numh,:)=pd.Act_Parm(indexsort,:);
     pd.Previous_Val(1:numh,:)=pd.Previous_Val(indexsort,:);
     pd.Ident_Code(1:numh,:)=pd.Ident_Code(indexsort,:);  
     pd.Flag_severity(1:numh)=pd.Flag_severity(indexsort);
     
end
%add any extra handling in here...


%finish and return

     handles.changed='Y';
     handles.pd=pd;

%     saveguidata
     
%this is a test - try to save the profile here but remove it and only save
%when necesary!!!!
    
assign_quality_flags ;  %go and assign the correct quality flags to each depth level...

%re_plotprofile;

%writenetcdf
   
 
        
