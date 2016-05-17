%% fixeverything_cells
% put all fixes in here and use cell mode to run individual bits...

%list of processes so far : (sequence, process, description, author, date)
% 1 (line 33) - set up databases - input keysdata - run this first (AT)
%% 1 first, set up the  databases - assume using quest...  This cell runs
%first.

prefix=input('enter the database prefix:','s')
p={prefix};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(p,m,y,q,a,tw,sstyle);

% end of keys setup

% use "filename=getfilename(stnnum,raw)" to return the filename if you
% don't want to read the entire file using readnetcdf

% eg:  for i=1:length(keysdata.stnnum)
%        raw=0;
%        filen=getfilename(num2str(keysdata.stnnum(i)),raw);
%        if(ispc)
%           filenam=[prefix '\' filen];
%        else
%           filenam=[prefix '/' filen];
%        end
%           ...
