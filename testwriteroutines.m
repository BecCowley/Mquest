
%routine to test the writing routines - reads a netcdf file into the matlab
%workspace for checking that it has been properly stored within quest.

nss=num2str(ss);
ss=ss
clear filenam
filenam='./newchinesedata'
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
latitude=getnc(filenam,'latitude',1,1,1,1,1);
longitude=getnc(filenam,'longitude',1,1,1,1,1);
wd=num2str(getnc(filenam,'woce_date'));

year=wd(1:4);
month=wd(5:6);
date=wd(7:8);

wt=num2str(getnc(filenam,'woce_time'));
wt2='000000';
wt2(6-(length(wt)-1):end)=wt;
time=[wt2(1:2) ':' wt2(3:4)];
ndep=getnc(filenam,'No_Depths');
nprof=getnc(filenam,'No_Prof');

ptype=getnc(filenam,'Prof_Type');

pt=find(ptype(1,:)=='T');
ps=strmatch(ptype(1:2,:),'PS');
h=getnc(filenam,'Profparm');

de=getnc(filenam,'Depthpress');
dnan=find(~isnan(de));
%de=de(dnan);
%h=h(dnan);
[m,n]=size(h);

if(n==nprof)
     temp=h(:,pt);
     depth=de(:,pt);
    if(~isempty(ps))
        sal=h(:,ps);
    end
else
     temp=h(pt,:);
     depth=de(pt,:);
    if(~isempty(ps))
         sal=h(ps,:);
    end
end
gg=find(temp>=99.);
temp=temp ;  %;change(temp,'>',99.,NaN);
if(~isempty(gg))
   temp(gg)=NaN;
end
if(~isempty(ps))
    gg=find(sal>=99.);
    sal=sal ;  %;change(temp,'>',99.,NaN);
    if(~isempty(gg))
        sal(gg)=NaN;
    end 
end

qc=getnc(filenam,'ProfQP');

numhists=getnc(filenam,'Num_Hists');

if(numhists>0)

     QC_code=getnc(filenam,'Act_Code');
     QC_depth=getnc(filenam,'Aux_ID');
     PRC_Date=getnc(filenam,'PRC_Date');
     PRC_Code=getnc(filenam,'PRC_Code');
     Version=getnc(filenam,'Version');
     Act_Parm=getnc(filenam,'Act_Parm');
     Previous_Val=getnc(filenam,'Previous_Val');
     Ident_Code=getnc(filenam,'Ident_Code');
%     try
         Flag_severity=getnc(filenam,'Flag_severity');
%     catch
%         for kk=1:100
%             Flag_severity(kk)=0   %indicates this is unknown at present
%         end
%     end

end
