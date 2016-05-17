%write2m2decdata - this script takes the netcdf data and converts it to 2m,
%then outputs a space-separated variable list for Brian (or whomever).
%  this must only write GOOD data!!!

prefix=[handles.outputfile];

if(handles.first==0)
    fid2=fopen(prefix,'at');
else
    fid2=fopen(prefix,'wt')
end
if (fid2==-1)
    error=1
    return
end

g=find(profiledata.qc=='0' | profiledata.qc=='1' | profiledata.qc=='2'...
    | profiledata.qc=='5');

%create depth/temp arrays to 2m...
d=fix(profiledata.depth(max(g)));
pno=strmatch('TEMP',profiledata.ptype);
if(~isempty(pno))
    temp=profiledata.data(pno,:);
end
temp=temp(g);
depth=profiledata.depth(g);
kktmp=find(temp>99 & depth<5);
try
    temp(kktmp)=temp(kktmp(end)+1);
end
clear depth2m
clear temp2m

if(length(temp)>0)
    depth2m=0:2:d;

    temp2m(2:length(depth2m))=interp1(depth,temp,depth2m(2:end));
    if(length(depth2m)>=2)
        temp2m(1)=temp2m(2);
    end
    headerstring=[];
    endkk=length(depth2m);
    headerstring=[profiledata.Cruise_ID' ' '  num2str(profiledata.latitude)  ...
         ' ' num2str(profiledata.longitude) ' ' profiledata.year ' ' profiledata.month ' ' ...
          profiledata.date ' ' profiledata.time(1:2) profiledata.time(4:5)];
                     
        t2m=length(temp2m);
        d2m=length(depth2m);

        for ii=1:endkk
            ii=ii;
            tempstr=[headerstring ' ' num2str(temp2m(ii)) ' ' num2str(depth2m(ii))];
            fprintf(fid2,'%s\n',tempstr);
        end
            
end
            endkk=0;

    

fclose(fid2);
