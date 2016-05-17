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
nprof=getnc(filenam,'No_Prof');

ptype=getnc(filenam,'Prof_Type');
if(nprof==1);ptype=ptype';end

pt=strmatch('TEMP',ptype);

h=getnc(filenam,'Profparm');

de=getnc(filenam,'Depthpress');
tempqc=getnc(filenam,'ProfQP');

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
     for i=1:length(bqct)
         try
            bqc(i)=str2num(bqct(i));
         catch 
             bqc(i)=0;
         end
     end
else
     temp=h(pt,:);
     bdepth=de(pt,:);
     bqct=tempqc(pt,:);
     for i=1:length(bqct)
         try
            bqc(i)=str2num(bqct(i));
         catch 
             bqc(i)=0;
         end
     end
end

if(nprof==1);bqc=bqc';end

gg=find(temp>=99.);
btemp=temp ;  %;change(temp,'>',99.,NaN);
if(~isempty(gg))
    btemp(gg)=NaN;
    bdepth(gg)=NaN;
    bqc(gg)=NaN;
end


