function checkMquestFilesVsKeys(dbname)
% function removeMquestFiles(dbname)
% check a keys file and the list of profiles in the database to find
% mismatches
%
%
% May need to edit this code to suit.
% Bec Cowley, 2025

%check nargin
if nargin == 0
    disp('Please try again with database name for checking')
    return
end

%load the keyslist:
fn = [dbname '_keys.nc'];

try
    nci = ncinfo(fn);
catch Me
    disp(['No file ' dbname '_keys.nc found. Are you in the right directory?'])
    return
end

stn = str2num(ncread(fn,'stn_num')');
% list the unique ids
[uniqueid_list,ia,ib] = unique(stn);

%check the data files to see what ids we have in the database
d = genpath(database);
ii = strfind(d,':');
pth{1} = d(1:ii(1)-1);
for a = 2:length(ii)-1
    pth{a} = d(ii(a)+1:ii(a+1)-1);
end

file_uids = [];
for a = 1:length(pth)
    % compile a list of unique ids from each path
    str = strsplit(pth{a}, '/');
    % combine all the values from the second index on
    uid = [];
    for b = 2:length(str)
        uid = [uid, str{b}];
    end
    if ~isempty(uid)
        % get a list of *ed.nc files in this folder
        flist = dir([pth{a}, '/*ed.nc']);
        for c = 1:length(flist)
            edfile = [uid, flist(c).name(1:2)];
            file_uids = [file_uids; str2num(edfile)];
        end
    end
end


% report the two lists
whos uniqueid_list file_uids