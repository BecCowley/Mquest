% script to see what is in the surface codes fields for XBT netcdf files:

fname = '/Volumes/UOT-data/quest/RANdata/RANxbt14/RANxbt14/89/00/20/43ed.nc'

srfc = ncread(fname,'SRFC_Code')';
srfcp = ncread(fname,'SRFC_Parm')';

%display the values next to each other:
for a = 1:size(srfc,1)
    disp([srfc(a,:) ': ' srfcp(a,:)])
end