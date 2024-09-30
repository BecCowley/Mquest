% read in the list of databases made in January 2024 and output the
% directory names and database names to a text file:
clear
cd('/oa-decadal-climate/work/observations/oceanobs_data/UOT-data/quest')
load('allprobeserialinfo.mat', 'flist')

% cycle through the flist
fname = 'database_list_2024.txt';
fid = fopen(fname,"w");

for a = 1:length(flist)
    fprintf(fid,'%s,%s\n',flist(a).name,flist(a).folder);
end

fclose(fid);