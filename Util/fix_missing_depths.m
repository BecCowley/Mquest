%% replace missing depth values 
% Some missing depth data in l'astrolabe 201805.
%Bec Cowley, Jan 2019

clear
prefix=input('enter the database prefix:','s');
stnnum = input('enter the station number:','s');

%%
%grab the depth data:
filenam = '/home/UOT-data/quest/antarctic/LA1805A/drop006.nc';
dep = ncread(filenam,'depth');
tim = squeeze(ncread(filenam,'sampleTime'));
%time in seconds:
tim = (tim-tim(1))*.001 + .1;
%depth equation is dep = at + bt2
%for deep blue, a = 6.691, b = -0.00225
dep2 = 6.691*tim - .00225*tim.^2;
    
for bb = 1:2 %ed and raw files
    
    raw=bb -1;
    filen=getfilename(num2str(stnnum),raw);
    filenam=[prefix '/' filen];
    
    ncwrite(filenam,'Depthpress',dep2);
    
end


