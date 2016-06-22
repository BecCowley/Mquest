% findrelativepath  - this script takes the starting directory and compares
% it to the new directory and sets up the relative path to get away from
% spaces in directory names on pcs.
%
% usage: relpath = findrelativepath(origdir,newdir);
%
% it needs the original directory (origdir)
% and it needs the new directory (newdir)
% these can be the same thing in which case the path is empty.

s=findstr(origdir,newdir);
relpath=[];
 if(~isempty(s))
     a=length(origdir);
     b=length(newdir);
     if(a==b)
         relpath=[];
     elseif (a>b)
         if(ispc)
             sl=findstr('\',origdir(b+1:end));
         else
             sl=findstr('/',origdir(b+1:end));
         end
         if(~isempty(sl))
             for i=1:length(sl)
                 if(ispc)
                     relpath=[relpath '..\'];
                 else
                     relpath=[relpath '../'];
                 end
             end
             relpath=[relpath];
         end
     else
     relpath=['.' newdir(a+1:end)];
     
     end
 end
 if(isempty(relpath));relpath='.';end