% readbuddynetcdf - 
%
% reads the buddy profiles so they can be plotted.  You must supply "ss"
% which is the unique id of the profile to be retrieved and "filenam" which 
% is the database prefix.
%  
%   Outputs are btemp, bdepth and bqc which can then be plotted.


clear temp depth qc ;

%profiledata=handles.profile_data;

nss=num2str(ss);
if(exist('raw','var'))
    if(raw)
    else
        raw=0;
    end
else
    raw=0;
end
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

format short g

nprof=ncread(filenam,'No_Prof');
ptype=ncread(filenam,'Prof_Type');

if(nprof==1);ptype=ptype';end

%if(nprof==1);ptype=ptype';end

pt=strmatch('TEMP',ptype);

h=squeeze(ncread(filenam,'Profparm'));

dpcode=ncread(filenam,'D_P_Code');
de=ncread(filenam,'Depthpress');
if dpcode=='P' %convert to depth if necessary
    %change to teos-10 on 17 Sept 2014
%     de=sw_dpth(de,profiledata.latitude(1));
    de=-gsw_z_from_p(de,profiledata.latitude(1));
end

tempqc=squeeze(ncread(filenam,'ProfQP'));

dnan=find(~isnan(de));
%de=de(dnan);
%h=h(dnan);
[m,n]=size(h);
clear bqc
clear bqct
if(n==nprof)
     temp=h(:,pt);
     bdepth=de(:,pt);
     bqct=tempqc(:,pt);
     bb=find(bqct=='3' | bqct=='4');
     bqc=zeros(size(bqct));
     bqc=bqc+1;
     bqc(bb)=4;
     
else
     temp=h(pt,:);
     bdepth=de(pt,:);
     bqct=tempqc(pt,:);
     bb=find(bqct=='3' | bqct=='4');
     bqc=zeros(size(bqct));
     bqc=bqc+1;
     bqc(bb)=4;
end

%if(nprof==1);bqc=bqc';end

gg=find(temp>=99. | temp <-99.);
btemp=temp ;  %;change(temp,'>',99.,NaN);
if(~isempty(gg))
    btemp(gg)=NaN;
    bdepth(gg)=NaN;
    bqc(gg)=NaN;
end


