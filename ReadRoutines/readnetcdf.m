function profiledata = readnetcdf(ss)
%readnetcdf - this script reads the profile data from the file - 
%       currently it reads only the variables required for Mquest.
%   The entire file is read in the script "readnetcdfforexport".
%
%  Updated to read netcdf using Matlab tools. 
%   Also to be a function.
%  May 2016, Bec Cowley.
% And to allow optional passing of the profile id in.
global handles

keysdata = handles.keys;

filenam=keysdata.prefix;
if nargin == 0
    ss = handles.ss;
end
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
%keep the full path name (without the ed/raw.nc):
handles.fullpath = filenam;

if(rawfile)
    filenam=[filenam 'raw.nc'];
    handles.changed='Y';
%    saveguidata
else
    filenam=[filenam 'ed.nc'];
end


% read in the entire profile netcdf file variables:
profiledata = nc2struct(filenam);

format short g;
%extract some extra information and keep separate:
pd.nss = nss;
pd.outputfile = keysdata.prefix;
wd=num2str(profiledata.woce_date);
pd.latitude = profiledata.latitude;
pd.longitude = profiledata.longitude;
pd.year=wd(1:4);
pd.month=wd(5:6);
pd.day=wd(7:8);
pd.ndep = profiledata.No_Depths(1);

wt=profiledata.woce_time;
wt=floor(wt/100);
wt2=sprintf('%4i',wt);
jk=strfind(wt2,' ');
if(~isempty(jk))
    wt2(jk)='0';
end
pd.time=[wt2(1:2) ':' wt2(3:4)];

pt=strmatch('TEMP',profiledata.Prof_Type');
ps=strmatch('PSAL',profiledata.Prof_Type');

de = profiledata.Depthpress;
pd.depth = de;
dpcode=profiledata.D_P_Code;

ij = strfind('P',dpcode);
if ~isempty(ij)
    try
        de(ij,1:profiledata.ndep)=-gsw_z_from_p(de(ij,1:profiledata.ndep),profiledata.latitude(1));
    catch
        de(1:profiledata.ndep,ij)=-gsw_z_from_p(de(1:profiledata.ndep,ij)',profiledata.latitude(1));
    end
end

h = squeeze(profiledata.Profparm);
qc = squeeze(profiledata.ProfQP);
dqc = squeeze(profiledata.DepresQ);
[mm,nn]=size(dqc);
[ii,jj] = sort([mm,nn],'descend');
dqc = permute(dqc,jj);
[m,n]=size(h);

if(n==profiledata.No_Prof)
    temp=h(:,pt);
    pd.depth=de(:,pt);
    pd.qc=qc(:,pt);
    pd.depth_qc=dqc(:,pt);
    if ~isempty(ps)
        sal=h(:,ps);
        pd.depthsal=de(:,ps);
        pd.salqc=qc(:,ps)';
    end
else
    temp=h(pt,:);
    pd.depth=de(pt,:);
    pd.qc=qc(pt,:)';
    pd.depth_qc=dqc(pt,:)';
    if ~isempty(ps)
        sal=h(ps,:);
        pd.depthsal=de(ps,:);
        pd.salqc=qc(ps,:);
        if(pd.nprof==1);pd.salqc=pd.qc';end
    end
end

pd.temp=temp ;

if(~isempty(ps))
    pd.sal=sal ;
end

try
    pd.Flag_severity=profiledata.Flag_severity;
catch
    pd.Flag_severity(profiledata.Num_Hists)=0;   %indicates this is unknown at present
end
if ~isempty(ij)
    pd.QC_depth(1:profiledata.Num_Hists)=...
        -gsw_z_from_p(profiledata.Aux_ID(1:profiledata.Num_Hists),profiledata.latitude(1));
end

pd.numhists=profiledata.Num_Hists;
pd.nparms=profiledata.Nparms;
pd.deep_depth = profiledata.Deep_Depth(1);
pd.QC_code=profiledata.Act_Code';
pd.QC_depth=double(profiledata.Aux_ID);
pd.PRC_Date=profiledata.PRC_Date';
pd.PRC_Code=profiledata.PRC_Code';
pd.Version=profiledata.Version';
pd.Act_Parm=profiledata.Act_Parm';
pd.Previous_Val=profiledata.Previous_Val';
pd.Ident_Code=profiledata.Ident_Code';

pd.surfcode = profiledata.SRFC_Code';
pd.surfparm = profiledata.SRFC_Parm';
pd.surfqparm = profiledata.SRFC_Q_Parm;
pd.nsurfc = profiledata.Nsurfc;

handles.profile_data=profiledata;
handles.pd = pd;
end
