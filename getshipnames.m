% load ships database for devil data:
%
% used by both input and output routines to get ship names from shortened
% versions (10 char)
%
% note - data file must be CSV to work!
%
% USAGE : S = getshipnames
%

function S = getshipnames

global SHIP_NAMES

%  call it something short while loading:  'S'


if(ispc)
    global MQUEST_DIRECTORY_PC
    fnm=[ MQUEST_DIRECTORY_PC '\ships.txt'];
else
    global MQUEST_DIRECTORY_UNIX
    fnm=[ MQUEST_DIRECTORY_UNIX '/ships.txt'];
end

fid = fopen(fnm,'r');
j=0;
    tmpdb = textscan(fid,'%s','delimiter',',');
    tmpdb = tmpdb{1};
for i=1:2:length(tmpdb)
    j=j+1;
    S.fullname{j}=tmpdb{i};
    S.shortname{j}=tmpdb{i+1};
end

SHIP_NAMES = S;

fclose(fid);

