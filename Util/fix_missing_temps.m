%% replace missing depth values 
% Some missing depth data in l'astrolabe 201805.
%Bec Cowley, Jan 2019

clear
prefix=input('enter the database prefix:','s');
stnnum = input('enter the station number:','s');
filenam = '/home/UOT-data/quest/antarctic/LA1901A1/drop044.nc';

%%
%grab the depth data:
temp = ncread(filenam,'temperature');
    
for bb = 1:2 %ed and raw files
    
    raw=bb -1;
    filen=getfilename(num2str(stnnum),raw);
    filenam=[prefix '/' filen];
    temp2 = ncread(filenam,'Profparm');
    
    ncwrite(filenam,'Profparm',temp);
    
end


