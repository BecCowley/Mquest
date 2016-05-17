% load RAN callsigns for devil data:
%
% used by both input and output routines to get ship names from shortened
% versions (10 char)
%
% note - data file must be CSV to work!
%
% USAGE : C = getcalls
%

function C = getcalls

global CALLS

%  call it something short while loading:  'S'


if(ispc)
    global MQUEST_DIRECTORY_PC
    fnm=[ MQUEST_DIRECTORY_PC '\calls.txt'];
else
    global MQUEST_DIRECTORY_UNIX
    fnm=[ MQUEST_DIRECTORY_UNIX '/calls.txt'];
end

fid = fopen(fnm,'r');
j=0;
    tmpdb = textscan(fid,'%s','delimiter',',','bufsize',10000);
    tmpdb = tmpdb{1};
for i=1:3:length(tmpdb)
    j=j+1
    C.shipname{j}=tmpdb{i};
    C.calls{j}=tmpdb{i+1};
end

CALLS = C;

fclose(fid);

