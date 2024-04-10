% compare the files at AODN to the Mquest files and remove any files that 
% aren't included in keys files.
% Then let AODN know to remove these files.
%Bec Cowley, 20 March 2024

clear
% Let's do the antarctic first for Matthis' work.
homedir = '/Users/cow074/Documents/IX28_CH14/';
locdir = [homedir 'IX28_H94/'];

%original files:
mqdir = '/Volumes/UOT-data/quest/antarctic/';

%get all the unique ids from all the antarctic keys files:
kfiles = dir([mqdir '*ant*keys.nc']);


%% now let's read all the keys stnnums in
stn = [];
for a = 1:length(kfiles)
    %skip if name isn't a database:
    disp(kfiles(a).name)
    if (contains(kfiles(a).name,'antarctic') & contains(kfiles(a).name,'MQNC')) ...
            | contains(kfiles(a).name, 'CSIROXBT')

        stn = [stn;str2num(ncread([kfiles(a).folder '/' kfiles(a).name],'stn_num')')];
    else
        disp('skipping')
    end
end

% check for uniqueness
[C, ia, ic] = unique(stn);
if length(C) ~= length(stn)
    disp('Non-unqiue station numbers')
    return
end

%% now check the files at AODN and retain the ones that aren't to be kept
afiles = dir([locdir '*.nc']);
fordeletion = [];
% print these out to send to AODN
fid = fopen([homedir '/aodnfilestodelete.txt'],'w');
for a = 1:length(afiles)
    nn = strsplit(afiles(a).name,'-');
    nn = strsplit(nn{end},'.');
    uid = str2num(nn{1});
    if ismember(uid,stn)
        continue
    else
        disp(afiles(a).name)
        fordeletion = [fordeletion;a];
        fprintf(fid,'%s\n',afiles(a).name);
    end
end

fclose(fid);

%% and now, for the IX28 data, let's get rid of these files
for a = 1:length(fordeletion)
    filename = [afiles(fordeletion(a)).folder '/' afiles(fordeletion(a)).name];
%     delete(filename);
    filename = ['/Users/cow074/Documents/IX28_CH14/CH14corrected/' afiles(fordeletion(a)).name];
    filename = strrep(filename,'FV01', 'FV02');
    delete(filename);
end

%% remove these ones specifically as they still have bad data in them
% will update these at AODN
delf = {'IMOS_SOOP-XBT_T_20081215T210100Z_IX28_FV02_ID-88604734.nc',...
'IMOS_SOOP-XBT_T_20100222T090300Z_IX28_FV02_ID-88940067.nc',...
'IMOS_SOOP-XBT_T_20101225T000700Z_IX28_FV02_ID-88971457.nc',...
'IMOS_SOOP-XBT_T_20101225T080300Z_IX28_FV02_ID-88971465.nc',...
'IMOS_SOOP-XBT_T_20130105T144200Z_IX28_FV02_ID-88987325.nc',...
'XBT_T_19991110T070000Z_IX28_FV02_ID-88125303.nc',...
'XBT_T_20070221T112300Z_IX28_FV02_ID-88163590.nc'};

for a=1:length(delf)
    filename = ['/Users/cow074/Documents/IX28_CH14/CH14corrected/' delf{a}];
    delete(filename);
    filename = ['/Users/cow074/Documents/IX28_CH14/IX28_H94/' delf{a}];
    filename = strrep(filename,'FV02', 'FV01');
    delete(filename);
end