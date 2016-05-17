%interpolate spikes for csa, spa and ipa:
          
%       findindexhistdepth=find(profiledata.depth>=histdepth);
        findindexhistdepth=histindex;
        startpoint=findindexhistdepth(1);
        
        %retrieveguidata
        
        selectionstring=get(handles.depthdisplay,'String');
%         save selstring.mat selectionstring
        centering=get(handles.depthdisplay,'Value');
        startpoint=centering;
        ch = get(gcbo,'Userdata') ;
        %if key is 1, chop only one point:
        if(~strcmp(ch,'1'))
            endpoint=launchendindex('UserData',{centering selectionstring qualflag});
            if(endpoint==-1);
                return;
            end
        else
            endpoint=startpoint;
        end
        profiledata.numhists=max(0,profiledata.numhists);
        nn=profiledata.numhists;
        cind=startpoint;

        for i=nn+1:nn+abs(startpoint-endpoint)+1
            profiledata.numhists=profiledata.numhists+1;
            profiledata.QC_code(i,1:2)=qualflag(1:2);
            profiledata.QC_depth(i)=profiledata.depth(cind);
            profiledata.PRC_Date(i,1:8)=update;
            profiledata.PRC_Code(i,1:4)='CSCB';
            profiledata.Version(i,1:4)=' 1.0';
            profiledata.Act_Parm(i,1:4)='TEMP';
            oldt=num2str(profiledata.temp(cind));
            profiledata.Previous_Val(i,1:length(oldt))=oldt;
            profiledata.Ident_Code(i,1:2)=DATA_QC_SOURCE;  
            profiledata.Flag_severity(i)=severity;
            cind=cind+1;  
      
        end
        
        if(isfield(profiledata,'sal'))
            cind=startpoint;
            nn=profiledata.numhists;

            for i=nn+1:nn+abs(startpoint-endpoint)+1
                profiledata.numhists=profiledata.numhists+1;
                profiledata.QC_code(i,1:2)=qualflag(1:2);
                profiledata.QC_depth(i)=profiledata.depthsal(cind);
                profiledata.PRC_Date(i,1:8)=update;
                profiledata.PRC_Code(i,1:4)='CSCB';
                profiledata.Version(i,1:4)=' 1.0';
                profiledata.Act_Parm(i,1:4)='PSAL';
                oldt=num2str(profiledata.sal(cind));
                profiledata.Previous_Val(i,1:length(oldt))=oldt;
                profiledata.Ident_Code(i,1:2)=DATA_QC_SOURCE;
                profiledata.Flag_severity(i)=severity;
                cind=cind+1;
            end
        end 
        
            keysdata=handles.keys;
            
           if(strcmp(keysdata.datatype(handles.currentprofile,:),'BO') | ...
                   strcmp(keysdata.datatype(handles.currentprofile,:),'UN'))               
                profiledata.temp(startpoint:endpoint)=99.99;
           else 

                if(profiledata.temp(max(startpoint-1,1))>99 | profiledata.temp(min(endpoint+1,profiledata.ndep(1)))>99 | ...
                        startpoint==1 | endpoint==profiledata.ndep(1))
                    profiledata.temp(startpoint:endpoint)=99.99;
                else
            pd(1:2)=[profiledata.depth(startpoint-1) profiledata.depth(endpoint+1)];
            pt(1:2)=[profiledata.temp(startpoint-1) profiledata.temp(endpoint+1)];
                   profiledata.temp(startpoint:endpoint)=...
                   interp1(pd,pt,profiledata.depth(startpoint:endpoint));
               if(isfield(profiledata,'sal'))
             pd(1:2)=[profiledata.depthsal(startpoint-1) profiledata.depthsal(endpoint+1)];
            pt(1:2)=[profiledata.sal(startpoint-1) profiledata.sal(endpoint+1)];
                   profiledata.sal(startpoint:endpoint)=...
                   interp1(pd,pt,profiledata.depthsal(startpoint:endpoint));
               end
                end
           end

           handles.profile_data=profiledata;
    %saveguidata
    setdepth_tempbox
    