function quest(username,month,databaseprefix,questversion)

% usage: quest('username')
%        quest('username','mmm','databaseprefix','questversion') is optional in
%        thi5s order
%  This function is used to launch quest and initialize variables.
%  it sets up the preferences for the user (which can be iota or
%  ann or lisa or mership or argo or ....) and then asks you if 
%  you wish to change any parameters.

CONFIG

if(nargin<1)
    username='newuser'
%username='ann';
end
username=username;

% if(~ispc)
%     pathelements
% end

newuser=0;
[user,prefix,mm,yy,qc,auto,timewindow,sstyle]=textread('usersettings.txt','%s%s%s%s%s%s%s%s');

getuser=strmatch(username,user,'exact');

if(isempty(getuser))
    newuser=length(user)+1;
end

if(newuser==length(user)+1)
    
    user{newuser}=username;
    prefix{newuser}='unknown';
    mm{newuser}='All';
    yy{newuser}='All';
    qc{newuser}='1';
    auto{newuser}='1';
    timewindow{newuser}='1';
    sstyle{newuser}='unknown';
end    

getuser=strmatch(username,user,'exact');

% if(nargin>1)
%    mm{getuser}=month;
% end
% if(nargin>2)
%    prefix{getuser}=databaseprefix;
% end
% if(nargin>3)
%     sstyle{getuser}=questversion;
% end

%saveuserinfo
if(nargin==2)
    h=selectuser('usernumber',getuser,'users',user,'prefix',prefix,'month',mm,...
    'year',yy,'qcrequired',qc,'autoonly',auto,'timewindow',timewindow,'sortstyle',sstyle,...
    'showauto',1);
else
    h=selectuser('usernumber',getuser,'users',user,'prefix',prefix,'month',mm,...
    'year',yy,'qcrequired',qc,'autoonly',auto,'timewindow',timewindow,'sortstyle',sstyle,...
    'showauto',0);
end