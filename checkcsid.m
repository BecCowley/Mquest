% checkcsid - compares csid with the file name and if they differ, stops
% execution with an error message.

srfcp=getnc(filenam,'SRFC_Parm');
srfcc=getnc(filenam,'SRFC_Code');

kcsid=strmatch('CSID',srfcc);
sp=str2num(srfcp(kcsid,:));
%stnn=str2num(ss);
stnn=ss;
if(sp~=stnn)
    errordlg(['these stations numbers do not match!:' srfcp(kcsid,:) ' ' num2str(ss)...
        ' enter <cr> to continue - with caution!!!!'])
%%% warning - remove this when done with chilean data!!!
fixcsid

 % and put this back in:   
%    pause
end
