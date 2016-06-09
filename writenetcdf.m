% write the edited data to the MQNC (Matlab-Quest-NetCdf) file
% this contains corrected data if available,
% if not, the uncorrected data
% note - this only writes variables that might have changed in quest as
% opposed to the script writeMQNCfiles which writes the entire MQNC
% structure when importing data.

%retrieveguidata

%update to suit changes to pd structure vs profile_data structure. pd
%structure should contain changes and flags from qc process

keysdata = handles.keys;
profiledata=handles.profile_data;
pd = handles.pd;

%construct the filename of the data file from the unique id and the
%database prefix

ss=pd.nss;
clear filenam
filenam=pd.outputfile;
nss=num2str(ss);
for j=1:2:length(num2str(ss));
    
    if(j+1>length(nss))
        if(ispc)
            filenam=[filenam '\' nss(j)];
        else
            filenam=[filenam '/' nss(j)];
        end
    else
        if(ispc)
            filenam=[filenam '\' nss(j:j+1)];
        else
            filenam=[filenam '/' nss(j:j+1)];
        end
    end
end

filenam=[filenam 'ed.nc'];

%get the complete arrays from the originalfile and replace with the edited
%values...  Only variables that are likely to have changed are
%rewritten:

checkcsid   %check that csid has not been corrupted somehow...


%if there are more than 100 histories, need to remove duplicates to reduce
%the size.
if(pd.numhists>100)
    elimdupehistories
end
%not sure why this is here. Very not good, removed for now.
% if(profiledata.numhists>100)
%     profiledata.numhists=75;
% end

% need depth data to recalc history depths if is P instead of D:
dpcode=ncread(filenam,'D_P_Code');
clear data2
clear depth2
clear qcdata2
data2=profiledata.Profparm;
depth2=profiledata.Depthpress;
qcdata2=profiledata.ProfQP;
qcdepth2=profiledata.DepresQ;
[m,n]=size(depth2);

if(pd.numhists>=1)
    if dpcode=='P'
        pd.QC_depth(1:pd.numhists)=sw_pres(pd.QC_depth(1:pd.numhists),pd.latitude(1));
        for i=1:pd.numhists
            dd=abs(depth2(1,:)-pd.depth(1,i));
            igood = find(dd==min(dd));
            pd.QC_depth(i)=depth2(1,igood);
        end
    end
end

%save temperature profile (and salinity profile if present): These are
%the only two that can be changed by quest:  If other parameters are
%present, they are also saved automatically as part of the data2 array.

kk=find(isnan(pd.temp));
if(~isempty(kk))
    pd.temp(kk)=-99.99;
end
try
    kk=find(isnan(pd.sal));
    if(~isempty(kk))
        pd.sal(kk)=-99.99;
    end
end
kk=find(isnan(pd.depth));
if(~isempty(kk))
    pd.depth(kk)=-99.99;
end

pt=strmatch('TEMP',pd.ptype);
ps=strmatch('PSAL',pd.ptype);


kk=find(isnan(depth2));
if(~isempty(kk))
    depth2(kk)=-99.99;
end

if(dpcode=='P')
    % need to convert D back to P:
    %this process seems silly, why not just replace the profile depths with
    %the original pressures in one line? Not sure of the logic of going
    %through and matching individual ones. Think about it.
    pd.depth(1:pd.ndep)=sw_pres(pd.depth(1:pd.ndep),pd.latitude(1));
    for i=1:pd.ndep
        dd=abs(depth2(1,:)-pd.depth(1,i));
        igood = find(dd==min(dd));
        pd.depth(i)=depth2(1,igood);
    end
end

%now write all the edits to the file:
%pd contains the changed data
%Make sure that all the edits to pd are transferred to profiledata
%structure.
%update the profiledata structure with edits in the pd structure:
wd(1:4)=num2str(pd.year);
wd(5:6) = num2str(pd.month,'%02f');
wd(7:8)= num2str(pd.day,'%02f');
wt=pd.time;
profiledata.woce_date = wd;
profiledata.woce_time = str2double([wt(1:2) wt(4:5)])*100;

vars_in = {'latitude','longitude','ndep','depth','deep_depth','qc','depth_qc',...
    'temp','Flag_Severity','numhists','nparms','QC_code','QC_depth','PRC_Date',...
    'PRC_Code','Version','Act_Parm','Previous_Val','Ident_Code','surfcode',...
    'surfparm','surfqparm','nsurfc'};
vars_out = {'latitude','longitude','No_Depths','Depthpress','Deep_Depth','ProfQP','DepresQ',...
    'Profparm','Flag_Severity','Num_Hists','Nparms','Act_Code','Aux_ID','PRC_Date',...
    'PRC_Code','Version','Act_Parm','Previous_Val','Ident_Code','SRFC_Code',...
    'SRFC_Parm','SRFC_Q_Parm','Nsurfc'};

for a = 1:length(vars_in)
    profiledata.(vars_out{a}) = pd.(vars_in{a});
end

%record today's date
update = datestr(now,'yyyymmdd');
ncwrite(filenam,'Up_date',update')

%and write out the profiledata structure
flds = fieldnames(profiledata);
for a = 1:length(flds)
    try
    if ~isempty(profiledata.(flds{a}))
        %     write edited file
        ncwrite(filenam,flds{a},profiledata.(flds{a}));
    end
    catch
        disp(['writeMQNCfiles: Unable to write item: ' num2str(a) ' ' flds{a}])
        continue
    end
end
