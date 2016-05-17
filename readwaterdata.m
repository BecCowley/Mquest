clear temp depth numhists qc QC_code QC_depth;

%retrieveguidata

%profiledata=handles.profile_data;
clear filenam
keysdata = handles.keys;

filenam=keysdata.prefix;
nss=num2str(ss);
raw=0;

filen=getfilename(nss,raw);

filenam=[filenam '\' filen];
if(ispc)
    findslash=strfind(filenam,'/');
    if(~isempty(findslash))
        filenam(findslash)='\';
    end
else
    findslash=strfind(filenam,'\');
    if(~isempty(findslash))
        filenam(findslash)='/';
    end
end

format short g;
waterdata.ndep=getnc(filenam,'No_Depths');
waterdata.nprof=getnc(filenam,'No_Prof');

waterdata.ptype=getnc(filenam,'Prof_Type');
if(waterdata.nprof==1);waterdata.ptype=waterdata.ptype';end

pt=strmatch('TEMP',waterdata.ptype);
ps=strmatch('PSAL',waterdata.ptype);

h=getnc(filenam,'Profparm');

de=getnc(filenam,'Depthpress');
dnan=find(~isnan(de));
%de=de(dnan);
%h=h(dnan);
qc=getnc(filenam,'ProfQP');

[m,n]=size(h);

if(n==waterdata.nprof)
     temp=h(:,pt);
     waterdata.depth=de(:,pt);
     waterdata.qc=qc(:,pt);
else
     temp=h(pt,:);
     waterdata.depth=de(pt,:);
     waterdata.qc=qc(pt,:);
end

if(waterdata.nprof==1);waterdata.qc=waterdata.qc';end

gg=find(temp>=99.);
waterdata.temp=temp ;  %;change(temp,'>',99.,NaN);
if(~isempty(gg))
   waterdata.temp(gg)=NaN;
   waterdata.depth(gg)=NaN;   
end

%get rid of bad data from the waterfall plot...

qcdata=waterdata.qc';
gg=strmatch('3',qcdata);
if(~isempty(gg))
    waterdata.temp(gg)=NaN;
    waterdata.depth(gg)=NaN;
end
gg=strmatch('4',qcdata);
if(~isempty(gg))
    waterdata.temp(gg)=NaN;
    waterdata.depth(gg)=NaN;
end

handles.waterdata=waterdata;

%saveguidata
