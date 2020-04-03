%% replace missing depth or temperature values 
% Happens sometimes in Turo software
%Bec Cowley, Jan 2019

clear
prefix=input('enter the database prefix:','s');
stnnum = input('enter the station number:','s');
filenam = '/home/UOT-data/quest/antarctic/LA1901A1/drop044.nc';

%%
%grab the depth or temp data:
% temp = ncread(filenam,'temperature');
depth = ncread(filenam,'depth');
    
for bb = 1:2 %ed and raw files
    
    raw=bb -1;
    filen=getfilename(num2str(stnnum),raw);
    filenam=[prefix '/' filen];
%     temp2 = ncread(filenam,'Profparm');
    depth2 = ncread(filenam,'Depthpress');
    
%     ncwrite(filenam,'Profparm',temp);
    ncwrite(filenam,'Profparm',depth);
    
end
return
%% when we don't have the original file and depths are missing, make it up
clear
prefix=input('enter the database prefix:','s');
stnnum = input('enter the station number:','s');

for bb = 1:2 %ed and raw files
    
    raw=bb -1;
    filen=getfilename(num2str(stnnum),raw);
    filenam=[prefix '/' filen];
    depth2 = ncread(filenam,'Depthpress');
    
    inan = find(isnan(depth2));
    
    %use the fall rate equation:
    a = 6.691; b = -0.00225;
    t = 0.1:0.1:0.1+(0.1*(length(depth2)-1));
    
    dep = a*t +b*(t.^2);
    
    plot(depth2-dep')
    ncwrite(filenam,'Depthpress',dep');
    
end
return

