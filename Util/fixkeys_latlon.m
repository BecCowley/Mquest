%% replace metadata in keys file with data from profile files.
% Somehow the keys file is corrupted with metdata from another file -
% overwritten somewhere. Profile file data is correct.

%Bec Cowley, May 2018

clear
prefix=input('enter the database prefix:','s')
stnnum = str2num(ncread([prefix '_keys.nc'],'stn_num')');
lt = ncread([prefix '_keys.nc'],'obslat');
ln = ncread([prefix '_keys.nc'],'obslng');
ln360 = ncread([prefix '_keys.nc'],'c360long');


%%
for aa=1:length(stnnum)
    %look at the ed file:
    raw=0;
    filen=getfilename(num2str(stnnum(aa)),raw);
    filenam=[prefix '/' filen];
    
    %update the keys file with the correct location information:
    lat = ncread(filenam,'latitude');
    lon = ncread(filenam,'longitude');
   
    if lat ~= lt(aa)
        lt(aa) = lat;
        ln(aa) = lon;
        ln360(aa) = lon;
    end
    
    
    
end
%write it back to the keys file
ncwrite([prefix '_keys.nc'],'obslat',lt);
ncwrite([prefix '_keys.nc'],'obslng',ln);
ncwrite([prefix '_keys.nc'],'c360long',ln360);

