function addMquestFiles(dbname1,dbname2)
% function addMquestFiles(dbname1,dbname2)
% add two databases together
%
% Inputs: database name to add to (eg: GTSPPmer2017MQNC)
%       : database name we are adding (eg: CSIROXBT2018)
%
%
% May need to edit this code to suit.
% Bec Cowley, 2018

%check nargin
if nargin < 2
    disp('Please try again with two database names')
    return
end

%load the keyslist:
fn1 = [dbname1 '_keys.nc'];
fn2 = [dbname2 '_keys.nc'];
fnnew = [dbname1 '_keysnew.nc'];
%get a list of stations we are adding
stn = ncread(fn2,'stn_num');

try
    nci1 = ncinfo(fn1);
    nci2 = ncinfo(fn2);
catch Me
    disp(['No file ' dbname1 '_keys.nc or ' dbname2 '_keys.nc found. Are you in the right directory?'])
    return
end

%make a new keys file:
createkeys(fnnew);

%cycle through each variable to add the new data
for a = 1:length(nci1.Variables)
    dat = ncread(fn1,nci1.Variables(a).Name);
    dat2 = ncread(fn2,nci2.Variables(a).Name);
    if ~ischar(dat)
        dat = [dat; dat2];
    else
        dat = [dat, dat2];
    end
    ncwrite(fnnew,nci1.Variables(a).Name,dat);
end

%Now copy over the actual data files
for a = 1:size(stn,2)
    nss=strtrim(stn(:,a)');
    filenam = [];
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
    
    filenam1=[dbname1 filenam 'ed.nc'];
    filenam2=[dbname1 filenam 'raw.nc'];
    filenam3=[dbname2 filenam 'ed.nc'];
    filenam4=[dbname2 filenam 'raw.nc'];
    
    if exist(filenam1(1:end-7),'dir') ~= 7
        mkdir(filenam1(1:end-7))
    end
    
    system(['cp ' filenam3 ' ' filenam1 ]);
    system(['cp ' filenam4 ' ' filenam2]);
    
end

    