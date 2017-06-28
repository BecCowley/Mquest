%interpolate spikes for csa, spa and ipa:

%       findindexhistdepth=find(pd.depth>=histdepth);
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
    if ~isnumeric(endpoint)
        return;
    end
else
    endpoint=startpoint;
end
pd.numhists=max(0,pd.numhists);
nn=pd.numhists;
cind=startpoint;

for i=nn+1:nn+abs(startpoint-endpoint)+1
    pd.numhists=pd.numhists+1;
    pd.QC_code(i,1:2)=qualflag(1:2);
    pd.QC_depth(i)=pd.depth(cind);
    pd.PRC_Date(i,1:8)=update;
    pd.PRC_Code(i,1:4)='CSCB';
    pd.Version(i,1:4)=' 1.0';
    pd.Act_Parm(i,1:4)='TEMP';
    oldt=num2str(pd.temp(cind));
    pd.Previous_Val(i,1:length(oldt))=oldt;
    pd.Ident_Code(i,1:2)=DATA_QC_SOURCE;
    pd.Flag_severity(i)=severity;
    cind=cind+1;
    
end

if(isfield(pd,'sal'))
    cind=startpoint;
    nn=pd.numhists;
    
    for i=nn+1:nn+abs(startpoint-endpoint)+1
        pd.numhists=pd.numhists+1;
        pd.QC_code(i,1:2)=qualflag(1:2);
        pd.QC_depth(i)=pd.depthsal(cind);
        pd.PRC_Date(i,1:8)=update;
        pd.PRC_Code(i,1:4)='CSCB';
        pd.Version(i,1:4)=' 1.0';
        pd.Act_Parm(i,1:4)='PSAL';
        oldt=num2str(pd.sal(cind));
        pd.Previous_Val(i,1:length(oldt))=oldt;
        pd.Ident_Code(i,1:2)=DATA_QC_SOURCE;
        pd.Flag_severity(i)=severity;
        cind=cind+1;
    end
end

keysdata=handles.keys;

if(strcmp(keysdata.datatype(handles.currentprofile,:),'BO') | ...
        strcmp(keysdata.datatype(handles.currentprofile,:),'UN'))
    pd.temp(startpoint:endpoint)=99.99;
else
    
    if(pd.temp(max(startpoint-1,1))>99 | pd.temp(min(endpoint+1,pd.ndep(1)))>99 | ...
            startpoint==1 | endpoint==pd.ndep(1))
        pd.temp(startpoint:endpoint)=99.99;
    else
        dd(1:2)=[pd.depth(startpoint-1) pd.depth(endpoint+1)];
        pt(1:2)=[pd.temp(startpoint-1) pd.temp(endpoint+1)];
        pd.temp(startpoint:endpoint)=...
            interp1(dd,pt,pd.depth(startpoint:endpoint));
        if(isfield(pd,'sal'))
            pd(1:2)=[pd.depthsal(startpoint-1) pd.depthsal(endpoint+1)];
            pt(1:2)=[pd.sal(startpoint-1) pd.sal(endpoint+1)];
            pd.sal(startpoint:endpoint)=...
                interp1(dd,pt,pd.depthsal(startpoint:endpoint));
        end
    end
end

handles.pd=pd;
%saveguidata
setdepth_tempbox
