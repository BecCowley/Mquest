% filename=getfilename(stationnum,raw)
%   where stationnum is the CHARACTER string containing the station number of
%       the profile required and
%   raw is a logical variable that identifies whether you want the 'raw.nc' or
%       'ed.nc' suffix on the filename
%
%   currently used only in the buddy read script but will be expanded if it
%       proves efficient.

function filename=getfilename(stationnum,raw)
stationnum = strjust(stationnum,'left');

stnl=strfind(stationnum,' ')-1;
if(isempty(stnl))
    stnl=length(stationnum);
end
n=stnl(1)+fix((stnl(1)-1)/2);
clear filename

if(ispc)
    filename(1:n)='\';
else
    filename(1:n)='/';
end

charpos=[1,2,4,5,7,8,10,11,13,14];
filename(charpos(1:stnl(1)))=stationnum(1:stnl(1));


if(raw)
    filename=[filename 'raw.nc'];
else
    filename=[filename 'ed.nc'];
end
return