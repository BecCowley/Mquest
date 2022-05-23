% checkcsid - compares csid with the file name and if they differ, stops
% execution with an error message.

srfcp=ncread(filenam,'SRFC_Parm')';
srfcc=ncread(filenam,'SRFC_Code')';

kcsid=strmatch('CSID',srfcc);
sp=str2num(srfcp(kcsid,:));
%stnn=str2num(ss);
stnn=ss;
if(sp~=stnn)
    errordlg(['these stations numbers do not match!:' srfcp(kcsid,:) ' ' num2str(ss)...
        ' Nothing is being done to rectify this, need to investigate'])
%%% warning - remove this when done with chilean data!!!
% fixcsid
%Can't find this code, June, 2016.

 % and put this back in:   
%    pause
end
