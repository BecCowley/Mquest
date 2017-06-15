function removeMquestFiles(dbname,uniqueid_list)
% function removeMquestFiles(dbname,uniquid_list)
% remove files added incorrectly
% for example:
%       uniqueid file used was incorrect
%       CONFIG.m file used was incorrect
%       Duplicates were added by mistake
% Inputs: database name (eg: GTSPPmer2017MQNC)
%       : uniqueid list for removal (eg: [3430,3431,3432] or [3430:3432])
%
%
% May need to edit this code to suit.
% Bec Cowley, 2017

%check nargin
if nargin < 2
    disp('Please try again with database name and uniqueids to remove')
    return
end

%load the keyslist:
fn = [dbname '_keys.nc'];
fnnew = [dbname '_keysnew.nc'];

try
    nci = ncinfo(fn);
catch Me
    disp(['No file ' dbname '_keys.nc found. Are you in the right directory?'])
    return
end

%make a new keys file:
createkeys(fnnew);

%identify the index where the uids appear
stn = str2num(ncread(fn,'stn_num')');
[~,ia,~] = intersect(stn,uniqueid_list);

%cycle through each variable and remove the uids
for a = 1:length(nci.Variables)
    dat = ncread(fn,nci.Variables(a).Name);
    if ~ischar(dat)
        dat(ia) = [];
    else
        dat(:,ia) = [];
        
    end
    ncwrite(fnnew,nci.Variables(a).Name,dat);
end

%Now remove the actual data files
for a = 1:length(ia)
    nss=num2str(stn(ia(a)));
    filenam = dbname;
    for j=1:2:length(nss);
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
    
    filenam1=[filenam 'ed.nc'];
    filenam2=[filenam 'raw.nc'];
    
    system(['rm ' filenam1]);
    system(['rm ' filenam2]);
    
end

    