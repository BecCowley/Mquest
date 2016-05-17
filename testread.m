clear temp depth numhists qc QC_code QC_depth;

%handles = guidata(hObject);
%profiledata=handles.profile_data;
%keysdata = handles.keys;

%filenam=keysdata.prefix;
clear filenam
filenam='.\chinese2'

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
format short g
profiledata.latitude=getnc(filenam,'latitude',1,1,1,1,1);
profiledata.longitude=getnc(filenam,'longitude',1,1,1,1,1);
wd=num2str(getnc(filenam,'woce_date'));

profiledata.year=wd(1:4);
profiledata.month=wd(5:6);
profiledata.date=wd(7:8);

wt=num2str(getnc(filenam,'woce_time'));
wt2='000000';
wt2(6-(length(wt)-1):end)=wt;
profiledata.time=[wt2(1:2) ':' wt2(3:4)];
profiledata.ndep=getnc(filenam,'No_Depths');
profiledata.nprof=getnc(filenam,'No_Prof');

profiledata.ptype=getnc(filenam,'Prof_Type');
pt=strmatch('TEMP',profiledata.ptype);
ps=strmatch('PSAL',profiledata.ptype);
h=getnc(filenam,'Profparm');

de=getnc(filenam,'Depthpress');
dnan=find(~isnan(de));
%de=de(dnan);
%h=h(dnan);
[m,n]=size(h);

if(n==profiledata.nprof)
     temp=h(:,pt);
     profiledata.depth=de(:,pt);
    if(~isempty(ps))
        sal=h(:,ps);
    end
else
     temp=h(pt,:);
     profiledata.depth=de(pt,:);
    if(~isempty(ps))
         sal=h(ps,:);
    end
end
gg=find(temp>=99.);
profiledata.temp=temp ;  %;change(temp,'>',99.,NaN);
if(~isempty(gg))
   profiledata.temp(gg)=NaN;
end
if(~isempty(ps))
    gg=find(sal>=99.);
    profiledata.sal=sal ;  %;change(temp,'>',99.,NaN);
    if(~isempty(gg))
        profiledata.sal(gg)=NaN;
    end
end

profiledata.qc=getnc(filenam,'ProfQP');

profiledata.numhists=getnc(filenam,'Num_Hists');

if(profiledata.numhists>0)

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
         for kk=1:100
             profiledata.Flag_severity(kk)=0;   %indicates this is unknown at present
         end
%add the field to the nc file:
nc = netcdf([filenam],'write');
nc{'Flag_severity'}=ncfloat('Num_Hists');
close(nc);
     end

end

%handles.profile_data=profiledata;
%guidata(hObject,handles);