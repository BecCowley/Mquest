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
    global MQUEST_DIRECTORY_PC
    fnm=[ MQUEST_DIRECTORY_PC '\ships.txt'];
else
    global MQUEST_DIRECTORY_UNIX
    fnm=[ MQUEST_DIRECTORY_UNIX '/ships.txt'];
end

fid = fopen(fnm,'at');

fprintf(fid,'%s,%s\n',longshipname,shortname);
disp('ships.txt updated!');

fclose(fid);

S=getshipnames;

