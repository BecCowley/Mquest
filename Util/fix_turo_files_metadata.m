%% update metadata for turo netcdf files 
%Bec Cowley, September, 2020

clear
foldn = '/Users/cow074/CSIRO/XBT SOOP Team - General/Ships/Seatrade Red/September 2020/XBT Data Return/SR3001/';
% foldn = '/Users/cow074/CSIRO/XBT SOOP Team - General/XBT Data Returns/Investigator XBT Voyages/xbt/in2020_v09_updated/';
files = dir([foldn '*.nc']);
%% Update the metadata in each file

for a = 3:length(files)
    filenam = [foldn files(a).name];
%     ncwriteatt(filenam,'/','LineNo','IX28');
%     ncwriteatt(filenam,'/','Ship','Seatrade Red');
%     ncwriteatt(filenam,'/','CallSign','D5LR9');
    ncwriteatt(filenam,'/','DropHeight','30');
%     ncwriteatt(filenam,'/','Voyage','SR3001');
%      ncwriteatt(filenam,'/','IMO', '9616888');
end

