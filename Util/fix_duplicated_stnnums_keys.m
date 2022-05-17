% remove duplicated station numbers from the keys file
% Bec Cowley 2022

clear
prefix=input('enter the database prefix:','s')
keysold = [prefix '_keys.nc'];
stnnum = str2num(ncread(keysold,'stn_num')');

%% find the duplicate station numbers
[c,ia,ib] = unique(stnnum);

if length(c) == length(stnnum)
    disp('No duplicated station numbers in this keys file');
    return
end

%else, there are duplicated station numbers, let's make an updated keys
%file

keysfile = [prefix '_keysnew.nc'];
createkeys(keysfile)

% now populate all the fields with the unique information
%read all the data in
keys = nc2struct(keysold);

%cycle through the fields and re-size
flds = fieldnames(keys);
for a = 1:length(flds)
    dat = keys.(flds{a});
    [m,n]=size(dat);
    if ischar(dat) %character fields
       if m == length(stnnum)
           keysnew.(flds{a}) = dat(ia,:);
       else
           keysnew.(flds{a}) = dat(:,ia);
       end
    else % numerical fields, they are all arrays
        keysnew.(flds{a}) = dat(ia);
    end
end

%% now write it out
ncwrite(keysfile,'obslat',keysnew.obslat)
ncwrite(keysfile,'obslng',keysnew.obslng);
ncwrite(keysfile,'c360long',keysnew.c360long);
ncwrite(keysfile,'autoqc',keysnew.autoqc);
ncwrite(keysfile,'stn_num',keysnew.stn_num);
ncwrite(keysfile,'callsign',keysnew.callsign);
ncwrite(keysfile,'obs_y',keysnew.obs_y);
ncwrite(keysfile,'obs_d',keysnew.obs_d);
ncwrite(keysfile,'obs_m',keysnew.obs_m);
ncwrite(keysfile,'obs_t',keysnew.obs_t);
ncwrite(keysfile,'data_t',keysnew.data_t);
ncwrite(keysfile,'data_source',keysnew.data_source);
ncwrite(keysfile,'priority',keysnew.priority);
