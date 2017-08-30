% append new ships details to database for devil data:
%
% used by readDEVIL.m to insert ship names when exact match (or any match) not found
%
% note - data file must be CSV to work!
%
% USAGE : S = writeshipnames(longshipname,shortname)
%

function S = writeshipnames(longshipname,shortname)

if(ispc)
    global UNIQUE_ID_PATH_PC
    fnm=[ UNIQUE_ID_PATH_PC 'ships.txt'];
else
    global UNIQUE_ID_PATH_UNIX
    fnm=[ UNIQUE_ID_PATH_UNIX '/ships.txt'];
end

fid = fopen(fnm,'a');

fprintf(fid,'%s,%s\n',longshipname,shortname)
disp('ships.txt updated!');

fclose(fid);

S=getshipnames;