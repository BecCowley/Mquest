function profiledata_updated = update_profiledata(profiledata,pd)
% update the profiledata file with changes made in the GUI and recorded in
% pd structure.
% Bec Cowley, June, 2016

%pd contains the changed data
%Make sure that all the edits to pd are transferred to profiledata
%structure.
%update the profiledata structure with edits in the pd structure:

profiledata_updated = profiledata;

wd(1:4)=pd.year;
wd(5:6) = pd.month;
wd(7:8)= pd.day;
wt=pd.time;
profiledata_updated.woce_date = str2num(wd);
profiledata_updated.woce_time = str2double([wt(1:2) wt(4:5)])*100;

vars_in = {'latitude','longitude','ndep','depth','deep_depth','qc','depth_qc',...
    'temp','Flag_severity','numhists','nparms','QC_code','QC_depth','PRC_Date',...
    'PRC_Code','Version','Act_Parm','Previous_Val','Ident_Code','surfcode',...
    'surfparm','surfqparm','nsurfc'};
vars_out = {'latitude','longitude','No_Depths','Depthpress','Deep_Depth','ProfQP','DepresQ',...
    'Profparm','Flag_severity','Num_Hists','Nparms','Act_Code','Aux_ID','PRC_Date',...
    'PRC_Code','Version','Act_Parm','Previous_Val','Ident_Code','SRFC_Code',...
    'SRFC_Parm','SRFC_Q_Parm','Nsurfc'};

    %first, if nprof is more than one
    if profiledata.No_Prof > 1
        pd.depth = [pd.depth profiledata.Depthpress(:,2:end)];
        p = squeeze(profiledata.Profparm);
        pd.temp = [pd.temp p(:,2:end)];
        p=squeeze(profiledata.DepresQ);
        pd.depth_qc = [pd.depth_qc p(:,2:end)];
        p=squeeze(profiledata.ProfQP);
        pd.qc = [pd.qc p(:,2:end)];
        pd.ndep = [pd.ndep profiledata.No_Depths(2:end)];
        pd.deep_depth = [pd.deep_depth profiledata.Deep_Depth(2:end)];
    end        
    
for a = 1:length(vars_in)
    %need to orient correctly:
    d = size(profiledata.(vars_out{a}));
    d2 = size(pd.(vars_in{a}));
    dat = pd.(vars_in{a});
    if length(d) == length(d2) & any(d > 1)
        [c,ia,ib] = intersect(d,d2,'stable');
        dat = permute(dat,ib);
    else
        %reshape to order dimensions:
        dat = reshape(dat,d);
    end
    profiledata_updated.(vars_out{a}) = dat;
end
end