%readnetcdf - this script reads the profile data from the file - 
%       currently it reads only the variables required for Mquest.
%   The entire file is read in the script "readnetcdfforexport".
%
%  The profiledata structure for Mquest is:



clear temp 
clear depth 
clear numhists 
clear qc 
clear QC_code 
clear QC_depth 
clear profiledata;

%retrieveguidata

clear filenam;
keysdata = handles.keys;

filenam=keysdata.prefix;
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
if(~exist('rawfile'))
    rawfile=0;
end
if(rawfile)
    filenam=[filenam 'raw.nc'];
    handles.changed='Y';
%    saveguidata
else
    filenam=[filenam 'ed.nc'];
end

% setup the profile structure by filling it from the edited data file:

format short g;
profiledata.latitude=getnc(filenam,'latitude',-1,-1,-1,-1,1);
profiledata.longitude=getnc(filenam,'longitude',-1,-1,-1,-1,1);
wd=num2str(getnc(filenam,'woce_date'));

profiledata.year=wd(1:4);
profiledata.month=wd(5:6);
profiledata.date=wd(7:8);
profiledata.pos_qc=getnc(filenam,'Q_Pos');
profiledata.juld_qc=getnc(filenam,'Q_Date_Time');

wt=(getnc(filenam,'woce_time'));
wt=floor(wt/100);
wt2=sprintf('%4i',wt);
jk=strfind(wt2,' ');
if(~isempty(jk))
    wt2(jk)='0';
end
%wt=wt(1:min(4,length(wt)));
%wt2='000000';
%wt2='0000';
%wt2(4-(length(wt)-1):4)=wt;
profiledata.time=[wt2(1:2) ':' wt2(3:4)];
profiledata.ndep=getnc(filenam,'No_Depths');
profiledata.nprof=getnc(filenam,'No_Prof');
profiledata.deep_depth=getnc(filenam,'Deep_Depth');

profiledata.ptype=getnc(filenam,'Prof_Type');
if(profiledata.nprof==1);profiledata.ptype=profiledata.ptype';end
pt=strmatch('TEMP',profiledata.ptype);
ps=strmatch('PSAL',profiledata.ptype);

h=getnc(filenam,'Profparm');
profiledata.profparm = h;

de=getnc(filenam,'Depthpress');
profiledata.depth = de;
dpcode=getnc(filenam,'D_P_Code');

dnan=find(~isnan(de));
qc=getnc(filenam,'ProfQP');
profiledata.profQparm = qc;
dqc=getnc(filenam,'DepresQ');
profiledata.depresQ = dqc;

if dpcode=='P'
    try
        %change to teos-10 function on 17 Sept 2014. Bec Cowley
%         de(:,1:profiledata.ndep)=sw_dpth(de(:,1:profiledata.ndep),profiledata.latitude(1));
        de(:,1:profiledata.ndep)=-gsw_z_from_p(de(:,1:profiledata.ndep),profiledata.latitude(1));
    catch
%         de(1:profiledata.ndep,:)=sw_dpth(de(1:profiledata.ndep,:)',profiledata.latitude(1));
        de(1:profiledata.ndep,:)=-gsw_z_from_p(de(1:profiledata.ndep,:)',profiledata.latitude(1));

    end
end
[m,n]=size(h);

if(n==profiledata.nprof)
    temp=h(:,pt);
    profiledata.deptht=de(:,pt);
    profiledata.qc=qc(:,pt);
    profiledata.depth_qc=dqc(:,pt);
    if(~isempty(ps))
        sal=h(:,ps);
        profiledata.depthsal=de(:,ps);
        profiledata.salqc=qc(:,ps);
        if(profiledata.nprof==1);profiledata.salqc=profiledata.qc';end
    end
else
    temp=h(pt,:);
    profiledata.depth=de(pt,:);
    profiledata.qc=qc(pt,:);
    profiledata.depth_qc=dqc(pt,:);
    if(~isempty(ps))
        sal=h(ps,:);
        profiledata.depthsal=de(ps,:);
        profiledata.salqc=qc(ps,:);
        if(profiledata.nprof==1);profiledata.salqc=profiledata.qc';end
    end
end

if(profiledata.nprof==1);profiledata.qc=profiledata.qc';profiledata.depth_qc=profiledata.depth_qc';end

profiledata.temp=temp ;

if(~isempty(ps))
    profiledata.sal=sal ;
end

profiledata.numhists=getnc(filenam,'Num_Hists');
profiledata.nparms=getnc(filenam,'Nparms');

     profiledata.QC_code=getnc(filenam,'Act_Code');
     profiledata.QC_depth=getnc(filenam,'Aux_ID');
     profiledata.PRC_Date=getnc(filenam,'PRC_Date');
     profiledata.PRC_Code=getnc(filenam,'PRC_Code');
     profiledata.Version=getnc(filenam,'Version');
     profiledata.Act_Parm=getnc(filenam,'Act_Parm');
     profiledata.Previous_Val=getnc(filenam,'Previous_Val');
     profiledata.Ident_Code=getnc(filenam,'Ident_Code');
     try
         profiledata.Flag_severity=getnc(filenam,'Flag_severity');
     catch
         for kk=1:profiledata.numhists
             profiledata.Flag_severity(kk)=0;   %indicates this is unknown at present
         end
     end
if dpcode=='P'
%     profiledata.QC_depth(1:profiledata.numhists)=sw_dpth(profiledata.QC_depth(1:profiledata.numhists),profiledata.latitude(1));
    profiledata.QC_depth(1:profiledata.numhists)=-gsw_z_from_p(profiledata.QC_depth(1:profiledata.numhists),profiledata.latitude(1));
end

% get the SRFC information - for the fish tag display in setprofileinfo.m
% Bec Cowley 24 March 2010
profiledata.surfcode = getnc(filenam,'SRFC_Code');
profiledata.surfparm = getnc(filenam,'SRFC_Parm');
profiledata.surfqparm = getnc(filenam,'SRFC_Q_Parm');
profiledata.nsurfc = getnc(filenam,'Nsurfc');

%get comments if available:
ncid = netcdf.open(filenam,'NOWRITE');
try
    gid = netcdf.inqVarID(ncid,'PreDropComments');
catch
    gid = [];
end
netcdf.close(ncid);
if ~isempty(gid)
    profiledata.comments_pre = getnc(filenam,'PreDropComments');
    profiledata.comments_post = getnc(filenam,'PostDropComments');
end

handles.profile_data=profiledata;

            
%saveguidata

