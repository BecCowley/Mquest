% readnetcdfforexport - 
%
%   script to read the entire netcdf file so it can be
%   written in another fomat for data exchange or archiving.  Requires the
%   handles structure from the Mquest gui and fills profiledata with the
%   complete profile and all metadata.

clear data depth numhists qc QC_code QC_depth;

%retrieveguidata

%profiledata=handles.profile_data;
clear filenam;
keysdata2 = handles.keys2;

clear profiledata

filenam=keysdata2.prefix;
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

format short g;

profiledata.Mky=getnc(filenam,'Mky');
profiledata.One_Deg_Sq=getnc(filenam,'One_Deg_Sq');
profiledata.Cruise_ID=getnc(filenam,'Cruise_ID');
profiledata.Data_Type=getnc(filenam,'Data_Type');
profiledata.Iumsgno=getnc(filenam,'Iumsgno');
profiledata.Stream_Source=getnc(filenam,'Stream_Source');
profiledata.Uflag=getnc(filenam,'Uflag');
profiledata.MEDS_Sta=getnc(filenam,'MEDS_Sta');
profiledata.Q_Pos=getnc(filenam,'Q_Pos');
profiledata.Q_Date_Time=getnc(filenam,'Q_Date_Time');
profiledata.Q_Record=getnc(filenam,'Q_Record');
profiledata.Up_date=getnc(filenam,'Up_date');
profiledata.Bul_Time=getnc(filenam,'Bul_Time');
profiledata.Bul_Header=getnc(filenam,'Bul_Header');
profiledata.Source_ID=getnc(filenam,'Source_ID');
profiledata.Stream_Ident=getnc(filenam,'Stream_Ident');
profiledata.QC_Version=getnc(filenam,'QC_Version');
profiledata.Data_Avail=getnc(filenam,'Data_Avail');
profiledata.Dup_Flag=getnc(filenam,'Dup_Flag');
profiledata.Digit_Code=getnc(filenam,'Digit_Code');
profiledata.Standard=getnc(filenam,'Standard');
profiledata.Deep_Depth=getnc(filenam,'Deep_Depth');

profiledata.Nparms=getnc(filenam,'Nparms');
if(profiledata.Nparms>0)
    profiledata.Pcode=getnc(filenam,'Pcode');
    profiledata.Parm=getnc(filenam,'Parm');
    profiledata.Q_Parm=getnc(filenam,'Q_Parm');
end

profiledata.Nsurfc=getnc(filenam,'Nsurfc');
if(profiledata.Nsurfc>0)
    profiledata.SRFC_Code=getnc(filenam,'SRFC_Code');
    profiledata.SRFC_Parm=getnc(filenam,'SRFC_Parm');
    profiledata.SRFC_Q_Parm=getnc(filenam,'SRFC_Q_Parm');
end

profiledata.D_P_Code=getnc(filenam,'D_P_Code');

profiledata.latitude=getnc(filenam,'latitude',-1,-1,-1,-1,1);
profiledata.longitude=getnc(filenam,'longitude',-1,-1,-1,-1,1);
if profiledata.longitude < 0
    profiledata.longitude = -profiledata.longitude;
end
wd=num2str(getnc(filenam,'woce_date'));

profiledata.year=wd(1:4);
profiledata.month=wd(5:6);
profiledata.date=wd(7:8);

wt=(getnc(filenam,'woce_time'));

wt=floor(wt/100);
wt2=sprintf('%4i',wt);
jk=strfind(wt2,' ');
if(~isempty(jk))
    wt2(jk)='0';
end
%wt=num2str(getnc(filenam,'woce_time'));
%wt1='000000';
%if(length(wt)<6)
%    wt1(6-length(wt)+1:6)=wt(1:length(wt))
%end
%wt1=wt(1:min(length(wt),4));
%wt2='0000';
%wt2(4-(length(wt1)-1):4)=wt1;
%wt2=wt1(1:4);
profiledata.time=[wt2(1:2) ':' wt2(3:4)];
profiledata.ndep=getnc(filenam,'No_Depths');
profiledata.nprof=getnc(filenam,'No_Prof');

profiledata.ptype=getnc(filenam,'Prof_Type');
if(profiledata.nprof==1);profiledata.ptype=profiledata.ptype';end
pt=strmatch('TEMP',profiledata.ptype);
ps=strmatch('PSAL',profiledata.ptype);

h=single(getnc(filenam,'Profparm'));

de=single(getnc(filenam,'Depthpress'));
dnan=find(~isnan(de));
qc=getnc(filenam,'ProfQP');
depthqc=getnc(filenam,'DepresQ');

    
[m,n]=size(h);

if(n==profiledata.nprof)
     data=h';
     profiledata.depth=de';
     profiledata.qc=qc';
     profiledata.depthqc=depthqc';
else
     profiledata.depth=de;
     profiledata.depthqc=depthqc;
     data=h;
     profiledata.qc=qc;
end

%if(profiledata.nprof==1);profiledata.qc=profiledata.qc';end
profiledata.data=data ;  %;change(data,'>',99.,NaN);

%if(~isempty(ps))
%    profiledata.sal=sal ;  %;change(data,'>',99.,NaN);
%end

profiledata.numhists=getnc(filenam,'Num_Hists');

%if(profiledata.numhists>0)

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

%end

handles.profile_data=profiledata;
%saveguidata
