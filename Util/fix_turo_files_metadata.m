%% update metadata for turo netcdf files 
%Bec Cowley, September, 2020

clear
% foldn = '/Users/cow074/CSIRO/XBT SOOP Team - General/Ships/Seatrade Red/September 2020/XBT Data Return/SR3001/';
foldn = '/oa-decadal-climate/work/observations/oceanobs_data/UOT-data/quest/mer/PE3401/';
files = dir([foldn '*.nc']);
%% Update the metadata in each file

for a = 1:length(files)
    filenam = [foldn files(a).name];
    ncwriteatt(filenam,'/','LineNo','PX32');
%     ncwriteatt(filenam,'/','Ship','Seatrade Red');
%     ncwriteatt(filenam,'/','CallSign','D5LR9');
%     ncwriteatt(filenam,'/','DropHeight','4.0');
%     ncwriteatt(filenam,'/','BatchDate','04/15/2015');
    ncwriteatt(filenam,'/','Voyage','PE3201');
%      ncwriteatt(filenam,'/','IMO', '9616888');
    % sn = ncreadatt(filenam,'/','SerialNo');
    % bd = ncreadatt(filenam,'/','BatchDate');
    % lat = ncread(filenam,'latitude');
    % lon = ncread(filenam,'longitude');
    
    % disp([filenam ', ' sn ', ' bd ', ' num2str(lat) ', ' num2str(lon)])
%     str = input('Update? ','s');
%     if str == 'y'
%         str = input('Serial: ','s');
%         if ~isempty(str)
%             sn = str;
%         end
%         str = input('Batch date: ','s');
%         if ~isempty(str)
%             bd = str;
%         end
%         str = input('latitude: ','s');
%         if ~isempty(str)
%             lat = str2num(str);
%         end
%        
%         str = input('longitude: ','s');
%         if ~isempty(str)
%             lon = str2num(str);
%         end
%         
%     end
%     ncwriteatt(filenam,'/','BatchDate',bd)
%     ncwriteatt(filenam,'/','SerialNo',sn)
%     ncwrite(filenam,'latitude',lat)
%     ncwrite(filenam,'longitude',lon)
%     ncwriteatt(filenam,'latitude','data_min',lat)
%     ncwriteatt(filenam,'latitude','data_max',lat)
%     ncwriteatt(filenam,'longitude','data_min',lon)
%     ncwriteatt(filenam,'longitude','data_max',lon)
    
end

