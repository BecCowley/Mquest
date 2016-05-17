%% subset the dataset
clear
% set up some stuff:
prefix = input('Enter the database prefix: ','s');
var = input('Enter the variable to subset by (eg ''obs_m''): ','s');
% var2 = input('Enter the variable to subset by (eg ''obs_m''): ','s');
% var3= input('Enter the variable to subset by (eg ''obs_m''): ','s');

nk = input('Create a new subset of keys? y = delete existing subset keys, n = add to existing subset keys: ','s');

if ~isempty(strmatch('y',nk))
    keysfile = [prefix 'subset_keys.nc'];
    % Create a new set of keys:
    eval(['!rm ' keysfile])
    %keys:
    createkeys;
    outp = [prefix 'subset'];
else
    pref = input('Enter existing database subset prefix (without subset_keys.nc ext): ','s');
    keysfile = [pref 'subset_keys.nc'];
    outp = [pref 'subset'];
end

%get info:
nc = ncinfo(keysfile);

oldkeys = netcdf.open([prefix '_keys.nc'],'nc_nowrite');
%get subset:
varid = netcdf.inqVarID(oldkeys,var);
dat = netcdf.getVar(oldkeys,varid);
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%edit this part as required:
% dat1 = dat';
% idat = find(str2num(dat1) == 1 | str2num(dat1) == 2 | str2num(dat1) == 3 | ...
%     str2num(dat1) == 6);
% varid = netcdf.inqVarID(oldkeys,var2);
% dat2 = netcdf.getVar(oldkeys,varid);
% varid = netcdf.inqVarID(oldkeys,var3);
% dat3 = netcdf.getVar(oldkeys,varid);

% dat = str2num(dat');
str = dat';
% dat2 = str2num(dat2');
% dat3 = str2num(dat3');
% str = [dat' dat2' dat3'];
% for a=1:length(str)
%     iz = findstr(' ',str(a,:))
%     str(a,iz) = '0';
% end
% ti = datenum(str,'yyyymmdd');
% idat = find(ti > 735138);
idat = strmatch('VLHF',str);
if isempty(idat)
    disp('No data found')
    return
end
% valy = min(dat):4:max(dat);
% yy = min(dat):max(dat);
% c = setdiff(yy,valy);
% idat = [];
% for a = 1:length(c)
%     idat = [idat;find(dat == c(a))];
% end

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
%write it out:
for a = 1:length(nc.Variables)
    varid = netcdf.inqVarID(oldkeys,nc.Variables(a).Name);
    dat = netcdf.getVar(oldkeys,varid);
    if length(dat) < length(idat)
        vardata = dat;
    else
        if ischar(dat)
            vardata = dat(:,idat);
        else
            vardata = dat(idat);
        end
    end
    if ~isempty(strmatch('n',nk))
        %append the new data to the old:
        dat2 = ncread(keysfile,nc.Variables(a).Name);
        if ischar(dat)
            if a == 1
                vardata = [dat2,vardata];
            else
                dat2(:,end-size(vardata,2)+1:end) = vardata;
                vardata = dat2;
            end
        else
            if a == 1
                vardata = [dat2;vardata];
            else
                dat2(end-size(vardata,1)+1:end) = vardata;
                vardata = dat2;
            end
        end
    end
    varname = nc.Variables(a).Name;
    ncwrite(keysfile,varname,vardata)
end
netcdf.close(oldkeys)
 
 %% Now extract the database:
stn = ncread(keysfile,'stn_num');
stn = stn';
 for a = 1:length(stn)
    for b = 1:2
        raw=b-1;
        filen=getfilename(stn(a,:),raw)
        filenam=[prefix '/' filen];
        fn = [outp '/' filen];
        
        if b == 1
            eval(['mkdir ' fn(1:end -7)])
        else
            eval(['mkdir ' fn(1:end -8)])
        end
        eval(['!cp ' filenam ' ' fn])
        
    end
end